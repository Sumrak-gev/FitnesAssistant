import pytest
from pydantic import ValidationError
from sqlalchemy.schema import CreateTable
from sqlalchemy.dialects import postgresql

from app.config import Settings
from app.database import Base
from app import models  # noqa: F401


def test_secrets_are_redacted():
    settings = Settings(_env_file=None, database_url="postgresql+psycopg://user:secret@localhost/fitness_test")
    assert "secret" not in repr(settings)


@pytest.mark.parametrize("url", ["sqlite:///test.db", "postgresql://localhost/fitness_dev"])
def test_wrong_database_driver_is_rejected(url):
    with pytest.raises(ValidationError):
        Settings(_env_file=None, database_url=url)


def test_models_compile_for_postgresql():
    assert set(Base.metadata.tables) == {"users", "devices", "refresh_tokens",
      "nutrition_products", "nutrition_meals", "nutrition_entries"}
    for table in Base.metadata.sorted_tables:
        sql = str(CreateTable(table).compile(dialect=postgresql.dialect()))
        assert "CREATE TABLE" in sql
    token_table = Base.metadata.tables["refresh_tokens"]
    assert "token_hash" in token_table.c
    assert "token" not in token_table.c
