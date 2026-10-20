from datetime import date
from typing import Annotated, Literal
from uuid import UUID

from pydantic import Field, StrictBool, model_validator

from app.nutrition_contracts import Contract, ProductMutation, MealMutation, EntryMutation, Mutation


class ProfileData(Contract):
    name: str = Field(max_length=80)
    birth_date: date | None = None
    sex: Literal["unspecified", "female", "male"]
    height_cm: float | None = Field(default=None, ge=50, le=260)
    weight_kg: float | None = Field(default=None, ge=20, le=500)
    target_weight_kg: float | None = Field(default=None, ge=20, le=500)
    activity: Literal["sedentary", "light", "moderate", "active", "veryActive"]
    goal: Literal["weightLoss", "muscleGain", "maintenance", "endurance"]
    program_id: str | None = Field(default=None, max_length=100)

    @model_validator(mode="after")
    def valid_birth_date(self):
        if self.birth_date and not date(1900, 1, 1) <= self.birth_date <= date.today():
            raise ValueError("Invalid birth date")
        return self


class GoalData(Contract):
    goal: Literal["weightLoss", "muscleGain", "maintenance", "endurance"]
    target_weight_kg: float | None = Field(default=None, ge=20, le=500)


class ExerciseData(Contract):
    id: str = Field(min_length=1, max_length=100)
    name: str = Field(min_length=1, max_length=120)
    muscle_group: str = Field(max_length=120)
    equipment: str = Field(max_length=120)
    contraindications: list[Annotated[str, Field(max_length=120)]] = Field(default_factory=list, max_length=30)


class WorkoutData(Contract):
    title: str = Field(min_length=1, max_length=120)
    target_goal: str = Field(min_length=1, max_length=120)
    exercises: list[ExerciseData] = Field(max_length=100)


class ProgressData(Contract):
    day: date = Field(ge=date(1900, 1, 1), le=date(2100, 12, 31))
    workout_done: StrictBool
    calories_consumed: float | None = Field(default=None, ge=0, le=100000)


class AchievementData(Contract):
    key: str = Field(min_length=1, max_length=100)
    unlocked: StrictBool


class ProfileMutation(Mutation):
    entity: Literal["profile"]
    data: ProfileData | None = None


class GoalMutation(Mutation):
    entity: Literal["goal"]
    data: GoalData | None = None


class WorkoutMutation(Mutation):
    entity: Literal["workout"]
    data: WorkoutData | None = None


class ProgressMutation(Mutation):
    entity: Literal["progress"]
    data: ProgressData | None = None


class AchievementMutation(Mutation):
    entity: Literal["achievement"]
    data: AchievementData | None = None


SyncMutation = Annotated[ProductMutation | MealMutation | EntryMutation | ProfileMutation | GoalMutation |
                         WorkoutMutation | ProgressMutation | AchievementMutation, Field(discriminator="entity")]


class SyncPush(Contract):
    changes: list[SyncMutation] = Field(min_length=1, max_length=100)

    @model_validator(mode="after")
    def unique_entities(self):
        if len({(c.entity, c.id) for c in self.changes}) != len(self.changes) or len({c.mutation_id for c in self.changes}) != len(self.changes):
            raise ValueError("Duplicate entities or mutation IDs")
        return self


class Applied(Contract):
    mutation_id: UUID
    id: UUID
    entity: str
    version: int


class SyncPushResult(Contract):
    applied: list[Applied]
    cursor: str


class SyncPullResult(Contract):
    changes: list[dict]
    next_cursor: str
    has_more: bool
