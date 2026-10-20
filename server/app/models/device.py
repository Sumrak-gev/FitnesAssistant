import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, Uuid, func, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Device(Base):
    """Телефон пользователя. id генерирует приложение при первом запуске."""

    __tablename__ = "devices"
    __table_args__ = (UniqueConstraint("id", "user_id", name="uq_device_owner"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True)
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    name: Mapped[str] = mapped_column(String(120), default="Android")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    last_sync_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
