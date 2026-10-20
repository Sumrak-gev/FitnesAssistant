from functools import lru_cache
from pathlib import Path

from pydantic import SecretStr, Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy.engine import make_url


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=Path(__file__).resolve().parents[1] / ".env",
        env_file_encoding="utf-8", extra="ignore",
        hide_input_in_errors=True,
    )
    database_url: SecretStr
    jwt_secret: SecretStr
    access_minutes: int = Field(default=15, ge=10, le=15)
    refresh_days: int = Field(default=30, ge=1, le=30)
    cors_origins: list[str] = []
    auth_limit: int = 20
    auth_window_seconds: int = 60

    @field_validator("jwt_secret")
    @classmethod
    def strong_secret(cls, value: SecretStr) -> SecretStr:
        raw = value.get_secret_value()
        if len(raw) < 48 or "REPLACE" in raw or "CHANGE_ME" in raw:
            raise ValueError("JWT_SECRET must contain at least 48 random characters")
        return value

    @field_validator("access_minutes", "refresh_days", "auth_limit", "auth_window_seconds")
    @classmethod
    def positive(cls, value: int) -> int:
        if value < 1:
            raise ValueError("Must be positive")
        return value

    @field_validator("database_url")
    @classmethod
    def postgres_only(cls, value: SecretStr) -> SecretStr:
        url = make_url(value.get_secret_value())
        if url.drivername != "postgresql+psycopg" or not url.database:
            raise ValueError("DATABASE_URL must use postgresql+psycopg and name a database")
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()
