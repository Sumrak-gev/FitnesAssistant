"""Durable sync journal. User row locks serialize cursor allocation and commits."""
from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String, UniqueConstraint, CheckConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class SyncEntity(Base):
    __tablename__ = "sync_entities"
    __table_args__ = (CheckConstraint("version > 0", name="ck_sync_version"),)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    entity: Mapped[str] = mapped_column(String(32), primary_key=True)
    id: Mapped[UUID] = mapped_column(primary_key=True)
    version: Mapped[int] = mapped_column(Integer)
    data: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class SyncChange(Base):
    __tablename__ = "sync_changes"
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    sequence: Mapped[int] = mapped_column(Integer, primary_key=True)
    record: Mapped[dict] = mapped_column(JSON)


class SyncReceipt(Base):
    __tablename__ = "sync_receipts"
    __table_args__ = (UniqueConstraint("user_id", "device_id", "entity", "entity_id", "client_revision", name="uq_sync_revision"),)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    mutation_id: Mapped[UUID] = mapped_column(primary_key=True)
    device_id: Mapped[UUID] = mapped_column(ForeignKey("devices.id", ondelete="CASCADE"))
    entity: Mapped[str] = mapped_column(String(32))
    entity_id: Mapped[UUID] = mapped_column()
    client_revision: Mapped[int] = mapped_column(Integer)
    digest: Mapped[str] = mapped_column(String(64))
    version: Mapped[int] = mapped_column(Integer)


class CatalogProduct(Base):
    __tablename__ = "products"
    id: Mapped[UUID] = mapped_column(primary_key=True)
    source_id: Mapped[str] = mapped_column(String(128), unique=True)
    name: Mapped[str] = mapped_column(String(120), index=True)
    data: Mapped[dict] = mapped_column(JSON)
    source_url: Mapped[str] = mapped_column(String(512))
    license: Mapped[str] = mapped_column(String(120))


class CatalogExercise(Base):
    __tablename__ = "exercises"
    id: Mapped[UUID] = mapped_column(primary_key=True)
    source_id: Mapped[str] = mapped_column(String(128), unique=True)
    name: Mapped[str] = mapped_column(String(120), index=True)
    data: Mapped[dict] = mapped_column(JSON)
    source_url: Mapped[str] = mapped_column(String(512))
    license: Mapped[str] = mapped_column(String(120))
