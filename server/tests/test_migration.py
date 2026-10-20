"""Upgrade a populated v2 schema without touching the surrounding test database."""
import os
from pathlib import Path
import subprocess
import sys
from uuid import uuid4
import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.engine import make_url
from sqlalchemy.schema import CreateSchema, DropSchema


def test_v2_diary_is_backfilled_with_deleted_product_parent():
    url = os.environ.get('TEST_DATABASE_URL')
    if not url:
        pytest.skip('Requires PostgreSQL fitness_test')
    parsed = make_url(url)
    if parsed.database != 'fitness_test':
        pytest.fail('Refusing non-test database')
    schema = f'migration_{uuid4().hex}'
    admin = create_engine(parsed)
    scoped_url = parsed.update_query_dict({'options': f'-csearch_path={schema}'})
    scoped = create_engine(scoped_url)
    environment = {**os.environ, 'DATABASE_URL': scoped_url.render_as_string(hide_password=False)}
    server = Path(__file__).resolve().parents[1]
    def migrate(revision):
        subprocess.run([sys.executable, '-m', 'alembic', 'upgrade', revision], cwd=server,
                       env=environment, check=True, capture_output=True)
    try:
        with admin.begin() as connection:
            connection.execute(CreateSchema(schema))
        migrate('0002_nutrition')
        owner, product, meal, entry = (uuid4() for _ in range(4))
        with scoped.begin() as connection:
            connection.execute(text("INSERT INTO users(id,email,password_hash) VALUES(:id,:email,'test-hash')"),
                               {'id': owner, 'email': f'{owner}@example.com'})
            connection.execute(text("INSERT INTO nutrition_products(id,user_id,name,calories,protein,fat,carbs,version,deleted_at) "
                                    "VALUES(:id,:owner,'Rice',130,2.7,0.3,28,2,now())"), {'id': product, 'owner': owner})
            connection.execute(text("INSERT INTO nutrition_meals(id,user_id,day,kind) VALUES(:id,:owner,'2026-10-20','lunch')"),
                               {'id': meal, 'owner': owner})
            connection.execute(text("INSERT INTO nutrition_entries(id,user_id,meal_id,product_id,grams,product_name,calories,protein,fat,carbs) "
                                    "VALUES(:id,:owner,:meal,:product,125,'Rice',130,2.7,0.3,28)"),
                               {'id': entry, 'owner': owner, 'meal': meal, 'product': product})
        migrate('head')
        with scoped.connect() as connection:
            records = list(connection.execute(text('SELECT record FROM sync_changes ORDER BY sequence')).scalars())
            assert [r['entity'] for r in records] == ['product', 'product', 'meal', 'entry']
            assert records[0]['deletedAt'] is None and records[0]['version'] == 1
            assert records[1]['deletedAt'] is not None and records[1]['data'] is None
            assert records[-1]['data']['snapshot']['id'] == str(product)
            assert records[-1]['data']['grams'] == 125
    finally:
        scoped.dispose()
        assert schema.startswith('migration_') and len(schema) == 42
        with admin.begin() as connection:
            connection.execute(DropSchema(schema, cascade=True))
        admin.dispose()
