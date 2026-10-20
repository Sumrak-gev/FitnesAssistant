from functools import lru_cache

from sqlalchemy import create_engine, text
from sqlalchemy.orm import DeclarativeBase, Session

from app.config import get_settings


class Base(DeclarativeBase):
    pass


@lru_cache
def get_engine():
    return create_engine(
        get_settings().database_url.get_secret_value(),
        pool_pre_ping=True, connect_args={"connect_timeout": 3},
    )


def check_database() -> None:
    with get_engine().connect() as connection:
        connection.execute(text("SELECT 1"))


def get_session():
    with Session(get_engine(), expire_on_commit=False) as session:
        yield session
