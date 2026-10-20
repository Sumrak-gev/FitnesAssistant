"""Reconcile auth metadata; add rotation, other fitness entities, journal and catalogs."""
from alembic import op
import sqlalchemy as sa

revision = "0003_sessions_sync_catalogs"
down_revision = "0002_nutrition"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("display_name", sa.String(100), nullable=False, server_default=""))
    op.add_column("users", sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()))
    op.add_column("users", sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()))
    op.add_column("users", sa.Column("deleted_at", sa.DateTime(timezone=True)))
    op.create_index("uq_users_email_lower", "users", [sa.text("lower(email)")], unique=True, postgresql_where=sa.text("deleted_at IS NULL"))
    op.add_column("devices", sa.Column("last_sync_at", sa.DateTime(timezone=True)))
    op.add_column("refresh_tokens", sa.Column("family_id", sa.Uuid(), nullable=True))
    # Existing sessions each start their own rotation family; no token material is needed.
    op.execute("UPDATE refresh_tokens SET family_id = id")
    op.alter_column("refresh_tokens", "family_id", nullable=False)
    op.create_index("ix_refresh_tokens_family_id", "refresh_tokens", ["family_id"])
    op.create_table("sync_entities",
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("entity", sa.String(32), primary_key=True), sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("version", sa.Integer(), nullable=False), sa.Column("data", sa.JSON()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True)), sa.CheckConstraint("version > 0", name="ck_sync_version"))
    op.create_table("sync_changes",
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("sequence", sa.Integer(), primary_key=True), sa.Column("record", sa.JSON(), nullable=False))
    op.create_table("sync_receipts",
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("mutation_id", sa.Uuid(), primary_key=True),
        sa.Column("device_id", sa.Uuid(), sa.ForeignKey("devices.id", ondelete="CASCADE"), nullable=False),
        sa.Column("entity", sa.String(32), nullable=False), sa.Column("entity_id", sa.Uuid(), nullable=False),
        sa.Column("client_revision", sa.Integer(), nullable=False), sa.Column("digest", sa.String(64), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.UniqueConstraint("user_id", "device_id", "entity", "entity_id", "client_revision", name="uq_sync_revision"))
    for name in ("products", "exercises"):
        op.create_table(name, sa.Column("id", sa.Uuid(), primary_key=True),
            sa.Column("source_id", sa.String(128), unique=True, nullable=False),
            sa.Column("name", sa.String(120), nullable=False), sa.Column("data", sa.JSON(), nullable=False),
            sa.Column("source_url", sa.String(512), nullable=False), sa.Column("license", sa.String(120), nullable=False))
        op.create_index(f"ix_{name}_name", name, ["name"])
    _bootstrap_nutrition_journal()


def _bootstrap_nutrition_journal():
    # Existing v2 diaries must be visible to a new phone. Baseline records also
    # materialize deleted parents, which still back live entry snapshots via FKs.
    payloads = {
        "product": "json_build_object('name',name,'calories',calories,'protein',protein,'fat',fat,'carbs',carbs)",
        "meal": "json_build_object('day',day,'kind',kind)",
        "entry": "json_build_object('mealId',meal_id,'productId',product_id,'grams',grams,'snapshot',"
                 "json_build_object('id',product_id,'name',product_name,'calories',calories,'protein',protein,'fat',fat,'carbs',carbs))",
    }
    queries = []
    for order, (entity, payload) in enumerate(payloads.items()):
        table = {"product": "nutrition_products", "meal": "nutrition_meals", "entry": "nutrition_entries"}[entity]
        common = f"'entity','{entity}','id',id,'updatedAt',updated_at"
        if entity in ("product", "meal"):
            queries.append(f"SELECT user_id,id,{order * 2} AS entity_order,json_build_object({common},"
                f"'version',greatest(1,version-1),'deletedAt',NULL,'data',{payload}) AS record FROM {table} WHERE deleted_at IS NOT NULL")
        queries.append(f"SELECT user_id,id,{order * 2 + 1} AS entity_order,json_build_object({common},"
            f"'version',version,'deletedAt',deleted_at,'data',CASE WHEN deleted_at IS NULL THEN {payload} ELSE NULL END) AS record FROM {table}")
    op.execute("WITH imported AS (" + " UNION ALL ".join(queries) + ") "
        "INSERT INTO sync_changes(user_id,sequence,record) SELECT user_id,"
        "row_number() OVER(PARTITION BY user_id ORDER BY entity_order,id),record FROM imported")


def downgrade():
    for table in ("exercises", "products", "sync_receipts", "sync_changes", "sync_entities"):
        op.drop_table(table)
    op.drop_index("ix_refresh_tokens_family_id", table_name="refresh_tokens")
    op.drop_column("refresh_tokens", "family_id")
    op.drop_column("devices", "last_sync_at")
    op.drop_index("uq_users_email_lower", table_name="users")
    for column in ("deleted_at", "updated_at", "is_active", "display_name"):
        op.drop_column("users", column)
