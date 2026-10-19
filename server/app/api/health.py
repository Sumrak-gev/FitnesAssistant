from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.db import get_db

router = APIRouter(tags=["health"])


@router.get("/health")
def health(db: Session = Depends(get_db)) -> dict[str, str]:
    """Проверка, что сервер жив и видит базу. Телефон дергает её перед синхронизацией."""
    try:
        db.execute(text("SELECT 1"))
    except Exception:
        return {"status": "ok", "db": "unavailable"}
    return {"status": "ok", "db": "ok"}
