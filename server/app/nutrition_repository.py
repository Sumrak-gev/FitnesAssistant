"""Caller owns the Session transaction. Every query is scoped to the authenticated user."""
from datetime import date, datetime, timezone
from uuid import UUID
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.nutrition_contracts import ProductData, MealData, EntryData
from app.nutrition_models import NutritionProduct, NutritionMeal, NutritionEntry

class NutritionNotFound(ValueError):
    pass
class NutritionVersionConflict(ValueError):
    pass

class NutritionRepository:
    def __init__(self, session: Session, user_id: UUID):
        self.session, self.user_id = session, user_id

    def _get(self, model, entity_id, *, lock=False, deleted=False):
        query = select(model).where(model.id == entity_id, model.user_id == self.user_id)
        if not deleted:
            query = query.where(model.deleted_at.is_(None))
        if lock:
            query = query.with_for_update().execution_options(populate_existing=True)
        return self.session.scalar(query)

    def _prepare(self, model, entity_id, expected_version, *, resurrect=False):
        row = self._get(model, entity_id, lock=True, deleted=True)
        if row is None:
            if expected_version != 0:
                raise NutritionVersionConflict("Entity version is no longer current")
            # A globally unique ID must never be reassigned to another owner.
            if self.session.get(model, entity_id) is not None:
                raise NutritionNotFound("Entity unavailable")
            row = model(id=entity_id, user_id=self.user_id, version=1)
            self.session.add(row)
        else:
            if row.version != expected_version:
                raise NutritionVersionConflict("Entity version is no longer current")
            if row.deleted_at is not None and not resurrect:
                raise NutritionNotFound("Entity unavailable")
            row.version += 1
        row.updated_at = datetime.now(timezone.utc)
        row.deleted_at = None
        return row

    def save_product(self, entity_id: UUID, data: ProductData, expected_version: int):
        # No autoflush until all non-null columns are assigned.
        with self.session.no_autoflush:
            row = self._prepare(NutritionProduct, entity_id, expected_version)
            for key, value in data.model_dump().items():
                setattr(row, key, value)
        self.session.flush()
        return row

    def products(self):
        return list(self.session.scalars(select(NutritionProduct).where(
            NutritionProduct.user_id == self.user_id, NutritionProduct.deleted_at.is_(None))
            .order_by(NutritionProduct.name, NutritionProduct.id)))

    def save_meal(self, entity_id: UUID, data: MealData, expected_version: int):
        with self.session.no_autoflush:
            row = self._prepare(NutritionMeal, entity_id, expected_version, resurrect=True)
            row.day, row.kind = data.day, data.kind
        self.session.flush()
        return row

    def save_entry(self, entity_id: UUID, data: EntryData, expected_version: int):
        meal = self._get(NutritionMeal, data.meal_id, lock=True)
        old = self._get(NutritionEntry, entity_id, lock=True)
        product = self._get(NutritionProduct, data.product_id, lock=True,
                            deleted=old is not None and old.product_id == data.product_id)
        if meal is None or product is None:
            raise NutritionNotFound("Meal or product unavailable")
        # Updating portions preserves the original snapshot, including deleted catalog items.
        keep = old is not None and old.product_id == data.product_id
        with self.session.no_autoflush:
            row = self._prepare(NutritionEntry, entity_id, expected_version)
            row.meal_id, row.product_id, row.grams = data.meal_id, data.product_id, data.grams
            if not keep:
                row.product_name = data.snapshot.name
                for key in ("calories", "protein", "fat", "carbs"):
                    setattr(row, key, getattr(data.snapshot, key))
        self.session.flush()
        return row

    def delete(self, entity: str, entity_id: UUID, expected_version: int):
        model = {"product": NutritionProduct, "meal": NutritionMeal, "entry": NutritionEntry}[entity]
        row = self._get(model, entity_id, lock=True)
        if row is None:
            raise NutritionNotFound("Entity unavailable")
        if row.version != expected_version:
            raise NutritionVersionConflict("Entity version is no longer current")
        now = datetime.now(timezone.utc)
        if entity == "meal":
            for entry in self.session.scalars(select(NutritionEntry).where(
                NutritionEntry.user_id == self.user_id, NutritionEntry.meal_id == entity_id,
                NutritionEntry.deleted_at.is_(None)).with_for_update()):
                entry.deleted_at = entry.updated_at = now
                entry.version += 1
        row.deleted_at = row.updated_at = now
        row.version += 1
        self.session.flush()
        return row

    def diary(self, start: date, end_exclusive: date):
        if end_exclusive <= start or (end_exclusive - start).days > 366:
            raise ValueError("Diary range must contain 1–366 days")
        query = select(NutritionEntry, NutritionMeal.day, NutritionMeal.kind).join(NutritionMeal,
            (NutritionMeal.id == NutritionEntry.meal_id) & (NutritionMeal.user_id == NutritionEntry.user_id)).where(
                NutritionEntry.user_id == self.user_id, NutritionEntry.deleted_at.is_(None),
                NutritionMeal.deleted_at.is_(None), NutritionMeal.day >= start, NutritionMeal.day < end_exclusive)
        return list(self.session.execute(query.order_by(NutritionMeal.day, NutritionMeal.kind, NutritionEntry.id)))
