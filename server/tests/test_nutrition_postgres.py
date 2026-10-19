from datetime import date, timedelta
from uuid import uuid4
import os
import pytest
from sqlalchemy import create_engine, select, text
from sqlalchemy.engine import make_url
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from app.models import User
from app.nutrition_contracts import ProductData, ProductSnapshot, MealData, EntryData
from app.nutrition_models import NutritionProduct, NutritionMeal, NutritionEntry
from app.nutrition_repository import NutritionRepository, NutritionNotFound, NutritionVersionConflict

@pytest.fixture
def session():
    url = os.getenv('TEST_DATABASE_URL')
    if not url:
        pytest.skip('Set TEST_DATABASE_URL to a migrated, isolated PostgreSQL fitness_test database')
    parsed = make_url(url)
    if parsed.drivername != 'postgresql+psycopg' or parsed.database != 'fitness_test':
        pytest.fail('Integration tests require PostgreSQL fitness_test; refusing another database')
    engine = create_engine(url)
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection, join_transaction_mode='create_savepoint')
    try:
        assert int(connection.scalar(text('SHOW server_version_num'))) >= 180000
        yield session
    finally:
        session.close(); transaction.rollback(); connection.close(); engine.dispose()

@pytest.fixture
def setup_diary(session):
    user = User(id=uuid4(), email=f'{uuid4()}@example.test', password_hash='test-only-hash')
    stranger = User(id=uuid4(), email=f'{uuid4()}@example.test', password_hash='test-only-hash')
    session.add_all([user, stranger]); session.flush()
    repository = NutritionRepository(session, user.id)
    data = ProductData(name='Рис', calories=130, protein=2.7, fat=.3, carbs=28)
    product = repository.save_product(uuid4(), data, 0)
    meal = repository.save_meal(uuid4(), MealData(day=date(2026, 12, 31), kind='lunch'), 0)
    entry = repository.save_entry(uuid4(), EntryData(meal_id=meal.id, product_id=product.id, grams=125,
      snapshot=ProductSnapshot(id=product.id, **data.model_dump())), 0)
    return repository, stranger, product, meal, entry

def test_postgres_crud_persistence_snapshots_and_versions(session, setup_diary):
    repo, stranger, product, meal, entry = setup_diary
    product_id, entry_id = product.id, entry.id
    repo.save_product(product.id, ProductData(name='Новый рис', calories=300, protein=10, fat=1, carbs=60), 1)
    session.expire_all()
    saved = session.get(NutritionEntry, entry_id)
    assert saved.product_name == 'Рис'
    assert saved.calories * saved.grams / 100 == 162.5
    with pytest.raises(NutritionVersionConflict):
        repo.save_product(product_id, ProductData(name='stale', calories=0, protein=0, fat=0, carbs=0), 1)
    repo.delete('product', product_id, 2)
    assert repo.products() == []
    # Updating grams after catalog deletion keeps the old snapshot.
    updated = repo.save_entry(entry_id, EntryData(meal_id=meal.id, product_id=product_id, grams=200,
      snapshot=ProductSnapshot(id=product_id, name='ignored new label', calories=1, protein=0, fat=0, carbs=0)), 1)
    assert updated.calories == 130
    assert updated.version == 2
    assert len(repo.diary(date(2026, 12, 28), date(2027, 1, 4))) == 1
    repo.delete('entry', entry_id, 2)
    assert repo.diary(date(2026, 12, 28), date(2027, 1, 4)) == []

def test_postgres_user_isolation_and_composite_fk(session, setup_diary):
    repo, stranger, product, meal, entry = setup_diary
    other = NutritionRepository(session, stranger.id)
    assert other.products() == []
    assert other.diary(date(2026, 12, 28), date(2027, 1, 4)) == []
    with pytest.raises(NutritionNotFound):
        other.delete('product', product.id, 1)
    with pytest.raises(NutritionNotFound):
        other.save_entry(uuid4(), EntryData(meal_id=meal.id, product_id=product.id, grams=100,
          snapshot=ProductSnapshot(id=product.id, name='rice', calories=130, protein=2.7, fat=.3, carbs=28)), 0)
    # Database itself protects cross-owner references, even bypassing repositories.
    with pytest.raises(IntegrityError), session.begin_nested():
        session.add(NutritionEntry(id=uuid4(), user_id=stranger.id, meal_id=meal.id,
          product_id=product.id, grams=100, product_name='rice', calories=130, protein=2.7, fat=.3, carbs=28))
        session.flush()

def test_postgres_delete_meal_tombstones_children(session, setup_diary):
    repo, _, _, meal, entry = setup_diary
    entry_id = entry.id
    repo.delete('meal', meal.id, 1)
    session.expire_all()
    assert session.get(NutritionEntry, entry_id).deleted_at is not None
    assert session.get(NutritionEntry, entry_id).version == 2
    assert repo.diary(date(2026, 12, 28), date(2027, 1, 4)) == []

@pytest.mark.parametrize('field,value', [('grams', 0), ('grams', -1), ('grams', float('nan')),
  ('calories', float('inf')), ('protein', 101)])
def test_postgres_constraints_reject_invalid_data(session, setup_diary, field, value):
    repo, _, _, _, entry = setup_diary
    entry_id = entry.id
    with pytest.raises(IntegrityError), session.begin_nested():
        session.execute(NutritionEntry.__table__.update().where(NutritionEntry.id == entry_id).values({field: value}))

def test_postgres_unique_meal_per_day_and_kind(session, setup_diary):
    repo, _, _, meal, _ = setup_diary
    with pytest.raises(IntegrityError), session.begin_nested():
        repo.save_meal(uuid4(), MealData(day=meal.day, kind=meal.kind), 0)

def test_postgres_commit_survives_new_connection(session):
    # The fixture verifies database name and server version before this test runs.
    engine = create_engine(os.environ['TEST_DATABASE_URL'])
    owner_id, product_id, meal_id, entry_id = uuid4(), uuid4(), uuid4(), uuid4()
    try:
        with Session(engine) as writer, writer.begin():
            writer.add(User(id=owner_id, email=f'{owner_id}@example.test', password_hash='test-only'))
            writer.flush()
            repo = NutritionRepository(writer, owner_id)
            data = ProductData(name='Сохранённый рис', calories=130, protein=2.7, fat=.3, carbs=28)
            repo.save_product(product_id, data, 0)
            repo.save_meal(meal_id, MealData(day=date(2026, 10, 18), kind='dinner'), 0)
            repo.save_entry(entry_id, EntryData(meal_id=meal_id, product_id=product_id, grams=125,
              snapshot=ProductSnapshot(id=product_id, **data.model_dump())), 0)
        with Session(engine) as reader:
            repo = NutritionRepository(reader, owner_id)
            assert repo.products()[0].name == 'Сохранённый рис'
            persisted = repo.diary(date(2026, 10, 18), date(2026, 10, 19))[0][0]
            assert persisted.calories * persisted.grams / 100 == 162.5
    finally:
        with engine.begin() as cleanup:
            cleanup.execute(User.__table__.delete().where(User.id == owner_id))
        engine.dispose()

def test_postgres_stale_session_cannot_overwrite_newer_commit(session):
    engine = create_engine(os.environ['TEST_DATABASE_URL'])
    owner_id, product_id = uuid4(), uuid4()
    data = ProductData(name='original', calories=100, protein=1, fat=1, carbs=20)
    try:
        with Session(engine) as writer, writer.begin():
            writer.add(User(id=owner_id, email=f'{owner_id}@example.test', password_hash='test-only'))
            writer.flush()
            NutritionRepository(writer, owner_id).save_product(product_id, data, 0)
        with Session(engine) as stale_reader:
            cached = stale_reader.get(NutritionProduct, product_id)
            assert cached.version == 1
            with Session(engine) as writer, writer.begin():
                NutritionRepository(writer, owner_id).save_product(product_id,
                  data.model_copy(update={'name': 'newer commit'}), 1)
            assert cached.version == 1  # stale identity-map object
            with pytest.raises(NutritionVersionConflict):
                NutritionRepository(stale_reader, owner_id).save_product(product_id, data, 1)
            stale_reader.rollback()
        with Session(engine) as reader:
            assert reader.get(NutritionProduct, product_id).name == 'newer commit'
    finally:
        with engine.begin() as cleanup:
            cleanup.execute(User.__table__.delete().where(User.id == owner_id))
        engine.dispose()
