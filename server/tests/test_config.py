import pytest
from pydantic import ValidationError
from sqlalchemy.schema import CreateTable
from sqlalchemy.dialects import postgresql

from app.config import Settings
from app.database import Base
from app import models  # noqa: F401


def test_secrets_are_redacted():
    settings = Settings(_env_file=None, database_url="postgresql+psycopg://user:secret@localhost/fitness_test")
    assert "user:secret" not in repr(settings)
    assert settings.jwt_secret.get_secret_value() not in repr(settings)


@pytest.mark.parametrize("url", ["sqlite:///test.db", "postgresql://localhost/fitness_dev"])
def test_wrong_database_driver_is_rejected(url):
    with pytest.raises(ValidationError):
        Settings(_env_file=None, database_url=url)


@pytest.mark.parametrize('secret', ['short', 'REPLACE_WITH_AT_LEAST_48_RANDOM_CHARACTERS_FROM_GENERATOR'])
def test_weak_or_placeholder_jwt_secret_is_rejected(secret):
    with pytest.raises(ValidationError):
        Settings(_env_file=None, database_url='postgresql+psycopg://localhost/fitness_test', jwt_secret=secret)


def test_models_compile_for_postgresql():
    assert set(Base.metadata.tables) == {
        "users", "devices", "refresh_tokens",
        "nutrition_products", "nutrition_meals", "nutrition_entries",
        "sync_entities", "sync_changes", "sync_receipts", "products", "exercises",
    }
    for table in Base.metadata.sorted_tables:
        sql = str(CreateTable(table).compile(dialect=postgresql.dialect()))
        assert "CREATE TABLE" in sql
    token_table = Base.metadata.tables["refresh_tokens"]
    assert "token_hash" in token_table.c
    assert "token" not in token_table.c
