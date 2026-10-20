from datetime import datetime, timezone
from hashlib import sha256
import hmac
import json
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select, or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.auth import current_session
from app.config import get_settings
from app.database import get_session
from app.models import User
from app.nutrition_models import NutritionProduct, NutritionMeal, NutritionEntry
from app.nutrition_repository import NutritionRepository, NutritionNotFound, NutritionVersionConflict
from app.sync_contracts import SyncPush, SyncPushResult, SyncPullResult, Applied
from app.sync_models import SyncEntity, SyncChange, SyncReceipt, CatalogProduct, CatalogExercise

router = APIRouter(tags=["sync"])
nutrition_models = {"product": NutritionProduct, "meal": NutritionMeal, "entry": NutritionEntry}


def error(code, detail, **extra):
    return HTTPException(409, {"code": code, "detail": detail, **extra})


def cursor(user_id, sequence):
    signature = hmac.new(get_settings().jwt_secret.get_secret_value().encode(),
                         f"sync:{user_id}:{sequence}".encode(), sha256).hexdigest()
    return f"{sequence}.{signature}"


def parse_cursor(user_id, value):
    if value in (None, "", "0"):
        return 0
    try:
        sequence = int(value.split(".")[0])
        if sequence < 0 or not hmac.compare_digest(cursor(user_id, sequence), value):
            raise ValueError()
        return sequence
    except (ValueError, AttributeError):
        raise HTTPException(410, {"code": "cursor_expired", "detail": "Invalid cursor; request a full pull"}) from None


def record(entity, row):
    data = None
    if row.deleted_at is None:
        if entity == "product":
            data = {key: getattr(row, key) for key in ("name", "calories", "protein", "fat", "carbs")}
        elif entity == "meal":
            data = {"day": row.day.isoformat(), "kind": row.kind}
        elif entity == "entry":
            data = {"mealId": str(row.meal_id), "productId": str(row.product_id), "grams": row.grams,
                    "snapshot": {"id": str(row.product_id), "name": row.product_name,
                                 **{k: getattr(row, k) for k in ("calories", "protein", "fat", "carbs")}}}
        else:
            data = row.data
    return {"entity": entity, "id": str(row.id), "version": row.version,
            "updatedAt": row.updated_at.isoformat(),
            "deletedAt": row.deleted_at.isoformat() if row.deleted_at else None, "data": data}


def last_sequence(session, owner):
    return session.scalar(select(func.max(SyncChange.sequence)).where(SyncChange.user_id == owner)) or 0


def find_row(session, owner, entity, entity_id):
    if entity in nutrition_models:
        model = nutrition_models[entity]
        return session.scalar(select(model).where(model.id == entity_id, model.user_id == owner))
    return session.get(SyncEntity, (owner, entity, entity_id))


@router.post("/sync/push", response_model=SyncPushResult)
@router.post("/v1/nutrition/sync/push", response_model=SyncPushResult, include_in_schema=False)
def push(data: SyncPush, identity=Depends(current_session), session: Session = Depends(get_session)):
    user, device = identity
    # A per-user transaction lock also prevents a later cursor from committing ahead of an earlier one.
    session.scalar(select(User).where(User.id == user.id).with_for_update())
    sequence = last_sequence(session, user.id)
    applied = []
    repo = NutritionRepository(session, user.id)
    try:
        for mutation in data.changes:
            payload = mutation.model_dump(mode="json", by_alias=True, exclude={"mutation_id"})
            fingerprint = sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
            receipt = session.scalar(select(SyncReceipt).where(SyncReceipt.user_id == user.id, or_(
                SyncReceipt.mutation_id == mutation.mutation_id,
                (SyncReceipt.device_id == device.id) & (SyncReceipt.entity == mutation.entity) &
                (SyncReceipt.entity_id == mutation.id) & (SyncReceipt.client_revision == mutation.client_revision))))
            if receipt:
                if receipt.digest != fingerprint or receipt.device_id != device.id:
                    raise error("idempotency_conflict", "Mutation key has already been used")
                version = receipt.version
            else:
                old = find_row(session, user.id, mutation.entity, mutation.id)
                if (old.version if old else 0) != mutation.base_version:
                    raise error("version_conflict", "Pull current state before retrying", entityId=str(mutation.id),
                                entity=mutation.entity, currentVersion=old.version if old else 0)
                children = []
                if mutation.entity in nutrition_models:
                    if mutation.entity == "meal" and mutation.operation == "upsert":
                        canonical = session.scalar(select(NutritionMeal).where(NutritionMeal.user_id == user.id,
                            NutritionMeal.day == mutation.data.day, NutritionMeal.kind == mutation.data.kind))
                        if canonical is not None and canonical.id != mutation.id:
                            raise error("meal_alias", "Use the existing day/meal slot", entity="meal",
                                entityId=str(mutation.id), canonicalId=str(canonical.id), currentVersion=canonical.version)
                    if mutation.operation == "delete":
                        if mutation.entity == "meal":
                            children = list(session.scalars(select(NutritionEntry).where(
                                NutritionEntry.user_id == user.id, NutritionEntry.meal_id == mutation.id,
                                NutritionEntry.deleted_at.is_(None))))
                        row = repo.delete(mutation.entity, mutation.id, mutation.base_version)
                    else:
                        row = getattr(repo, f"save_{mutation.entity}")(mutation.id, mutation.data, mutation.base_version)
                else:
                    if old is None and mutation.operation == "delete":
                        raise NutritionNotFound()
                    row = old or SyncEntity(user_id=user.id, entity=mutation.entity, id=mutation.id, version=0)
                    row.version += 1
                    row.updated_at = datetime.now(timezone.utc)
                    row.deleted_at = row.updated_at if mutation.operation == "delete" else None
                    row.data = mutation.data.model_dump(mode="json", by_alias=True) if mutation.data else None
                    session.add(row)
                version = row.version
                for changed_entity, changed_row in [("entry", child) for child in children] + [(mutation.entity, row)]:
                    sequence += 1
                    session.add(SyncChange(user_id=user.id, sequence=sequence, record=record(changed_entity, changed_row)))
                session.add(SyncReceipt(user_id=user.id, mutation_id=mutation.mutation_id, device_id=device.id,
                    entity=mutation.entity, entity_id=mutation.id, client_revision=mutation.client_revision,
                    digest=fingerprint, version=version))
                session.flush()
            applied.append(Applied(mutation_id=mutation.mutation_id, id=mutation.id, entity=mutation.entity, version=version))
        device.last_sync_at = datetime.now(timezone.utc)
        session.commit()
    except (NutritionVersionConflict, NutritionNotFound, IntegrityError) as exc:
        session.rollback()
        if isinstance(exc, NutritionVersionConflict):
            raise error("version_conflict", "Pull current state before retrying") from None
        raise error("reference_missing", "Entity, reference or day/meal slot unavailable") from None
    return SyncPushResult(applied=applied, cursor=cursor(user.id, sequence))


@router.get("/sync/pull", response_model=SyncPullResult)
@router.get("/v1/nutrition/sync/pull", response_model=SyncPullResult, include_in_schema=False)
def pull(since: str = "0", cursor_value: str | None = Query(default=None, alias="cursor"),
         limit: int = Query(default=100, ge=1, le=500),
         identity=Depends(current_session), session: Session = Depends(get_session)):
    user, _ = identity
    sequence = parse_cursor(user.id, cursor_value or since)
    rows = list(session.scalars(select(SyncChange).where(SyncChange.user_id == user.id,
                SyncChange.sequence > sequence).order_by(SyncChange.sequence).limit(limit + 1)))
    page = rows[:limit]
    return SyncPullResult(changes=[r.record for r in page], has_more=len(rows) > limit,
                          next_cursor=cursor(user.id, page[-1].sequence if page else sequence))


def catalog_rows(model, q, offset, limit, session):
    query = select(model).order_by(model.name, model.id).offset(offset).limit(limit)
    if q.strip():
        # PostgreSQL 18's built-in Unicode collation also works on clusters using locale C.
        query = query.where(func.lower(model.name.collate('pg_unicode_fast')).contains(q.strip().lower(), autoescape=True))
    return [{"id": str(row.id), **row.data, "sourceUrl": row.source_url, "license": row.license}
            for row in session.scalars(query)]


@router.get("/products", tags=["catalogs"])
def products(q: str = Query(default="", max_length=120), offset: int = Query(default=0, ge=0, le=100000),
             limit: int = Query(default=100, ge=1, le=200),
             identity=Depends(current_session), session: Session = Depends(get_session)):
    return catalog_rows(CatalogProduct, q, offset, limit, session)


@router.get("/exercises", tags=["catalogs"])
def exercises(q: str = Query(default="", max_length=120), offset: int = Query(default=0, ge=0, le=100000),
              limit: int = Query(default=100, ge=1, le=200),
              identity=Depends(current_session), session: Session = Depends(get_session)):
    return catalog_rows(CatalogExercise, q, offset, limit, session)
