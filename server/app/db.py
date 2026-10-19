from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.config import settings

# Engine держит пул соединений с PostgreSQL.
engine = create_engine(settings.database_url, pool_pre_ping=True)

SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)


class Base(DeclarativeBase):
    """Базовый класс всех таблиц (модели появятся на следующем шаге)."""


def get_db() -> Iterator[Session]:
    """Зависимость FastAPI: даёт сессию на время запроса и закрывает её после."""
    with SessionLocal() as session:
        yield session
