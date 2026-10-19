from datetime import date, datetime
from uuid import UUID, uuid4
from sqlalchemy import CheckConstraint, Date, DateTime, Float, ForeignKey, ForeignKeyConstraint, Index, Integer, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base

class NutritionMeta:
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    version: Mapped[int] = mapped_column(Integer, nullable=False, default=1, server_default="1")
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now())
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

class NutritionProduct(NutritionMeta, Base):
    __tablename__ = "nutrition_products"
    __table_args__ = (
        UniqueConstraint("id", "user_id", name="uq_nutrition_product_owner"),
        CheckConstraint("length(trim(name)) BETWEEN 1 AND 120", name="ck_nutrition_product_name"),
        CheckConstraint("calories BETWEEN 0 AND 900 AND protein BETWEEN 0 AND 100.1 AND fat BETWEEN 0 AND 100.1 AND carbs BETWEEN 0 AND 100.1 AND protein + fat + carbs <= 100.1", name="ck_nutrition_product_values"),
        CheckConstraint("version > 0", name="ck_nutrition_product_version"),
        Index("ix_nutrition_products_owner_name", "user_id", "deleted_at", "name"),
    )
    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    name: Mapped[str] = mapped_column(String(120))
    calories: Mapped[float] = mapped_column(Float)
    protein: Mapped[float] = mapped_column(Float)
    fat: Mapped[float] = mapped_column(Float)
    carbs: Mapped[float] = mapped_column(Float)

class NutritionMeal(NutritionMeta, Base):
    __tablename__ = "nutrition_meals"
    __table_args__ = (
        UniqueConstraint("id", "user_id", name="uq_nutrition_meal_owner"),
        UniqueConstraint("user_id", "day", "kind", name="uq_nutrition_meal_day_kind"),
        CheckConstraint("kind IN ('breakfast','lunch','dinner','snack')", name="ck_nutrition_meal_kind"),
        CheckConstraint("day BETWEEN DATE '1900-01-01' AND DATE '2100-12-31'", name="ck_nutrition_meal_day"),
        CheckConstraint("version > 0", name="ck_nutrition_meal_version"),
        Index("ix_nutrition_meals_owner_day", "user_id", "day", "deleted_at"),
    )
    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    day: Mapped[date] = mapped_column(Date)
    kind: Mapped[str] = mapped_column(String(16))

class NutritionEntry(NutritionMeta, Base):
    __tablename__ = "nutrition_entries"
    __table_args__ = (
        ForeignKeyConstraint(["meal_id", "user_id"], ["nutrition_meals.id", "nutrition_meals.user_id"], name="fk_nutrition_entry_meal_owner"),
        ForeignKeyConstraint(["product_id", "user_id"], ["nutrition_products.id", "nutrition_products.user_id"], name="fk_nutrition_entry_product_owner"),
        CheckConstraint("grams > 0 AND grams <= 10000", name="ck_nutrition_entry_grams"),
        CheckConstraint("calories BETWEEN 0 AND 900 AND protein BETWEEN 0 AND 100.1 AND fat BETWEEN 0 AND 100.1 AND carbs BETWEEN 0 AND 100.1 AND protein + fat + carbs <= 100.1", name="ck_nutrition_entry_values"),
        CheckConstraint("length(trim(product_name)) BETWEEN 1 AND 120", name="ck_nutrition_entry_name"),
        CheckConstraint("version > 0", name="ck_nutrition_entry_version"),
        Index("ix_nutrition_entries_meal", "user_id", "meal_id", "deleted_at"),
        Index("ix_nutrition_entries_product", "user_id", "product_id"),
    )
    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    meal_id: Mapped[UUID] = mapped_column()
    product_id: Mapped[UUID] = mapped_column()
    grams: Mapped[float] = mapped_column(Float)
    product_name: Mapped[str] = mapped_column(String(120))
    calories: Mapped[float] = mapped_column(Float)
    protein: Mapped[float] = mapped_column(Float)
    fat: Mapped[float] = mapped_column(Float)
    carbs: Mapped[float] = mapped_column(Float)
