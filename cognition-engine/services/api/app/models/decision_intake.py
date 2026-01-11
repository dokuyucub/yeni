"""
Pydantic models for Decision Intake.

These models match the TypeScript types from @cognition-engine/shared.
"""

from datetime import datetime
from enum import Enum
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator


# ============================================================================
# ENUMS
# ============================================================================


class ObjectiveKey(str, Enum):
    """Allowed objective keys."""

    MONEY = "money"
    TIME = "time"
    FREEDOM = "freedom"
    LEARNING = "learning"
    STATUS = "status"
    IMPACT = "impact"
    HEALTH = "health"
    RELATIONSHIPS = "relationships"
    OTHER = "other"


class RiskTolerance(str, Enum):
    """Risk tolerance levels - matches mobile Step 4."""

    CONSERVATIVE = "conservative"
    MODERATE = "moderate"
    AGGRESSIVE = "aggressive"


class DecisionStatus(str, Enum):
    """Decision status values."""

    DRAFT = "draft"
    ACTIVE = "active"
    EXECUTED = "executed"
    ARCHIVED = "archived"


# ============================================================================
# SUB-MODELS
# ============================================================================


class DecisionOption(BaseModel):
    """Option definition for a decision."""

    label: str = Field(..., min_length=1, max_length=10)
    name: str = Field(..., max_length=200)
    description: str = Field(default="", max_length=2000)


class TimeHorizons(BaseModel):
    """Time horizons for decision impact."""

    decisionDeadline: str = Field(default="", max_length=200)
    implementationPeriod: str = Field(default="", max_length=200)
    impactHorizon: str = Field(default="", max_length=200)


class ObjectiveWeight(BaseModel):
    """Objective with weight."""

    key: ObjectiveKey
    weight: int = Field(ge=0, le=100)


class DecisionConstraints(BaseModel):
    """Constraints on the decision."""

    budgetMin: int | None = None
    budgetMax: int | None = None
    mustHaves: str = Field(default="", max_length=2000)
    cantDo: str = Field(default="", max_length=2000)


class DecisionStakeholders(BaseModel):
    """Stakeholders affected by the decision."""

    decisionMaker: str = Field(default="", max_length=500)
    influencers: str = Field(default="", max_length=500)
    affected: str = Field(default="", max_length=500)


class DecisionResources(BaseModel):
    """Available resources."""

    available: str = Field(default="", max_length=2000)
    needed: str = Field(default="", max_length=2000)


class DecisionRisk(BaseModel):
    """Risk configuration."""

    tolerance: RiskTolerance = RiskTolerance.MODERATE
    maxAcceptableLoss: str = Field(default="", max_length=1000)


class GutPreference(BaseModel):
    """Gut preference (optional)."""

    optionLabel: str = Field(default="", max_length=10)
    confidence: int = Field(ge=0, le=100, default=50)
    reason: str = Field(default="", max_length=1000)


# ============================================================================
# REQUEST MODELS
# ============================================================================


class DecisionIntakeRequest(BaseModel):
    """
    Complete Decision Intake request DTO.

    Matches TypeScript DecisionIntake from shared types.
    """

    title: str = Field(..., min_length=1, max_length=500)
    statement: str = Field(..., min_length=1, max_length=5000)
    options: list[DecisionOption] = Field(default_factory=list)
    timeHorizons: TimeHorizons = Field(default_factory=TimeHorizons)
    objectives: list[ObjectiveWeight] = Field(default_factory=list)
    constraints: DecisionConstraints = Field(default_factory=DecisionConstraints)
    stakeholders: DecisionStakeholders = Field(default_factory=DecisionStakeholders)
    baselineDoNothing: str = Field(default="", max_length=2000)
    resources: DecisionResources = Field(default_factory=DecisionResources)
    risk: DecisionRisk = Field(default_factory=DecisionRisk)
    dealbreakers: list[str] = Field(default_factory=list)
    knownUncertainties: list[str] = Field(default_factory=list)
    gutPreference: GutPreference | None = None
    successDefinition: str = Field(default="", max_length=2000)
    failureDefinition: str = Field(default="", max_length=2000)

    @field_validator("dealbreakers", "knownUncertainties", mode="before")
    @classmethod
    def filter_empty_strings(cls, v: list[str] | None) -> list[str]:
        """Remove empty strings from lists."""
        if v is None:
            return []
        return [s for s in v if s and s.strip()]


# ============================================================================
# RESPONSE MODELS
# ============================================================================


class DecisionCreateResponse(BaseModel):
    """Response from creating a decision."""

    decision_id: UUID
    status: DecisionStatus
    created_at: datetime
    updated_at: datetime
    warnings: list[str] = Field(default_factory=list)


class DecisionListItem(BaseModel):
    """Decision list item for GET /decisions."""

    decision_id: UUID
    title: str
    status: DecisionStatus
    updated_at: datetime


class DecisionListResponse(BaseModel):
    """Response from listing decisions."""

    items: list[DecisionListItem]


class DecisionDetailResponse(BaseModel):
    """Response from getting a single decision."""

    decision_id: UUID
    status: DecisionStatus
    created_at: datetime
    updated_at: datetime
    intake: DecisionIntakeRequest
    warnings: list[str] = Field(default_factory=list)


class DecisionDeleteResponse(BaseModel):
    """Response from deleting a decision."""

    ok: bool = True


class ErrorResponse(BaseModel):
    """Standard error response."""

    error: str
    requestId: str


# ============================================================================
# NORMALIZED INTAKE (internal use)
# ============================================================================


class NormalizedIntake(BaseModel):
    """
    Normalized decision intake.

    This is the result of running normalization on DecisionIntakeRequest.
    All fields are validated and cleaned.
    """

    title: str
    statement: str
    options: list[DecisionOption]
    timeHorizons: TimeHorizons
    objectives: list[ObjectiveWeight]
    constraints: DecisionConstraints
    stakeholders: DecisionStakeholders
    baselineDoNothing: str
    resources: DecisionResources
    risk: DecisionRisk
    dealbreakers: list[str]
    knownUncertainties: list[str]
    gutPreference: GutPreference | None
    successDefinition: str
    failureDefinition: str
    warnings: list[str] = Field(default_factory=list)
