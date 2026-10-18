"""Nutrition tables with per-user ownership, snapshots and sync tombstones."""
from alembic import op
import sqlalchemy as sa

revision = "0002_nutrition"
down_revision = "0001_auth_foundation"
branch_labels = None
depends_on = None

def _meta():
    return [sa.Column("user_id", sa.Uuid(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
      sa.Column("version", sa.Integer(), server_default="1", nullable=False),
      sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
      sa.Column("deleted_at", sa.DateTime(timezone=True))]

def _values():
    return [sa.Column(name, sa.Float(), nullable=False) for name in ("calories", "protein", "fat", "carbs")]

_values_check = "calories BETWEEN 0 AND 900 AND protein BETWEEN 0 AND 100.1 AND fat BETWEEN 0 AND 100.1 AND carbs BETWEEN 0 AND 100.1 AND protein + fat + carbs <= 100.1"

def upgrade():
    op.create_table("nutrition_products", sa.Column("id", sa.Uuid(), primary_key=True),
      sa.Column("name", sa.String(120), nullable=False), *_values(), *_meta(),
      sa.UniqueConstraint("id", "user_id", name="uq_nutrition_product_owner"),
      sa.CheckConstraint("length(trim(name)) BETWEEN 1 AND 120", name="ck_nutrition_product_name"),
      sa.CheckConstraint(_values_check, name="ck_nutrition_product_values"),
      sa.CheckConstraint("version > 0", name="ck_nutrition_product_version"))
    op.create_index("ix_nutrition_products_owner_name", "nutrition_products", ["user_id", "deleted_at", "name"])
    op.create_table("nutrition_meals", sa.Column("id", sa.Uuid(), primary_key=True),
      sa.Column("day", sa.Date(), nullable=False), sa.Column("kind", sa.String(16), nullable=False), *_meta(),
      sa.UniqueConstraint("id", "user_id", name="uq_nutrition_meal_owner"),
      sa.UniqueConstraint("user_id", "day", "kind", name="uq_nutrition_meal_day_kind"),
      sa.CheckConstraint("kind IN ('breakfast','lunch','dinner','snack')", name="ck_nutrition_meal_kind"),
      sa.CheckConstraint("day BETWEEN DATE '1900-01-01' AND DATE '2100-12-31'", name="ck_nutrition_meal_day"),
      sa.CheckConstraint("version > 0", name="ck_nutrition_meal_version"))
    op.create_index("ix_nutrition_meals_owner_day", "nutrition_meals", ["user_id", "day", "deleted_at"])
    op.create_table("nutrition_entries", sa.Column("id", sa.Uuid(), primary_key=True),
      sa.Column("meal_id", sa.Uuid(), nullable=False), sa.Column("product_id", sa.Uuid(), nullable=False),
      sa.Column("grams", sa.Float(), nullable=False), sa.Column("product_name", sa.String(120), nullable=False),
      *_values(), *_meta(),
      sa.ForeignKeyConstraint(["meal_id", "user_id"], ["nutrition_meals.id", "nutrition_meals.user_id"], name="fk_nutrition_entry_meal_owner"),
      sa.ForeignKeyConstraint(["product_id", "user_id"], ["nutrition_products.id", "nutrition_products.user_id"], name="fk_nutrition_entry_product_owner"),
      sa.CheckConstraint("grams > 0 AND grams <= 10000", name="ck_nutrition_entry_grams"),
      sa.CheckConstraint(_values_check, name="ck_nutrition_entry_values"),
      sa.CheckConstraint("length(trim(product_name)) BETWEEN 1 AND 120", name="ck_nutrition_entry_name"),
      sa.CheckConstraint("version > 0", name="ck_nutrition_entry_version"))
    op.create_index("ix_nutrition_entries_meal", "nutrition_entries", ["user_id", "meal_id", "deleted_at"])
    op.create_index("ix_nutrition_entries_product", "nutrition_entries", ["user_id", "product_id"])

def downgrade():
    op.drop_table("nutrition_entries")
    op.drop_table("nutrition_meals")
    op.drop_table("nutrition_products")
