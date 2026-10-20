"""Versioned nutrition DTOs used by the authenticated sync handlers."""
from datetime import date, datetime
from typing import Annotated, Literal
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field, AwareDatetime, model_validator
from pydantic.alias_generators import to_camel

class Contract(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True,
                              extra="forbid", allow_inf_nan=False, str_strip_whitespace=True)

class ProductData(Contract):
    name: str = Field(min_length=1, max_length=120)
    calories: float = Field(strict=True, ge=0, le=900)
    protein: float = Field(strict=True, ge=0, le=100.1)
    fat: float = Field(strict=True, ge=0, le=100.1)
    carbs: float = Field(strict=True, ge=0, le=100.1)

    @model_validator(mode="after")
    def macro_mass(self):
        if self.protein + self.fat + self.carbs > 100.1:
            raise ValueError("Sum of macros exceeds 100 g (0.1 g rounding tolerance)")
        return self

class ProductSnapshot(ProductData):
    id: UUID

class MealData(Contract):
    day: date = Field(ge=date(1900, 1, 1), le=date(2100, 12, 31))
    kind: Literal["breakfast", "lunch", "dinner", "snack"]

class EntryData(Contract):
    meal_id: UUID
    product_id: UUID
    grams: float = Field(strict=True, gt=0, le=10000)
    snapshot: ProductSnapshot

    @model_validator(mode="after")
    def matching_snapshot(self):
        if self.snapshot.id != self.product_id:
            raise ValueError("Snapshot must refer to productId")
        return self

class Mutation(Contract):
    mutation_id: UUID
    id: UUID
    operation: Literal["upsert", "delete"]
    base_version: int = Field(strict=True, ge=0)
    client_revision: int = Field(strict=True, ge=1)

    @model_validator(mode="after")
    def payload_matches_operation(self):
        if (self.operation == "upsert") != (self.data is not None):
            raise ValueError("Upsert requires data; deletion requires null data")
        return self

class ProductMutation(Mutation):
    entity: Literal["product"]
    data: ProductData | None = None

class MealMutation(Mutation):
    entity: Literal["meal"]
    data: MealData | None = None

class EntryMutation(Mutation):
    entity: Literal["entry"]
    data: EntryData | None = None

NutritionMutation = Annotated[ProductMutation | MealMutation | EntryMutation, Field(discriminator="entity")]

class PushRequest(Contract):
    changes: list[NutritionMutation] = Field(min_length=1, max_length=100)

    @model_validator(mode="after")
    def unique_mutations_and_entities(self):
        keys = [(c.entity, c.id) for c in self.changes]
        if len(set(keys)) != len(keys) or len({c.mutation_id for c in self.changes}) != len(keys):
            raise ValueError("A batch must contain one mutation per entity and distinct mutation IDs")
        return self

class AppliedMutation(Contract):
    mutation_id: UUID
    id: UUID
    entity: Literal["product", "meal", "entry"]
    version: int = Field(ge=1)

class PushResponse(Contract):
    applied: list[AppliedMutation]
    cursor: str

class ChangeRecord(Contract):
    entity: Literal["product", "meal", "entry"]
    id: UUID
    version: int = Field(ge=1)
    updated_at: AwareDatetime
    deleted_at: AwareDatetime | None = None
    data: ProductData | MealData | EntryData | None

    @model_validator(mode="after")
    def record_matches_entity(self):
        if self.deleted_at is not None:
            if self.data is not None or self.deleted_at > self.updated_at:
                raise ValueError("A tombstone requires null data and a valid deletion time")
        elif not isinstance(self.data, {"product": ProductData, "meal": MealData, "entry": EntryData}[self.entity]):
            raise ValueError("Live change data must match its entity")
        return self

class PullResponse(Contract):
    changes: list[ChangeRecord]
    next_cursor: str
    has_more: bool

class SyncError(Contract):
    code: Literal["unauthorized", "version_conflict", "reference_missing", "validation_error", "cursor_expired"]
    detail: str
    entity_id: UUID | None = None
    canonical_id: UUID | None = None
    current_version: int | None = Field(default=None, ge=1)
