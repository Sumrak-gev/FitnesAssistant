# Импорт всех моделей нужен, чтобы Alembic увидел таблицы в Base.metadata.
from app.models.device import Device  # noqa: F401
from app.models.refresh_token import RefreshToken  # noqa: F401
from app.models.user import User  # noqa: F401
from app import nutrition_models  # noqa: F401
from app import sync_models  # noqa: F401
