"""
Decision intake API routes.

Provides CRUD operations for decision intake data.
"""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.auth import AuthenticatedUser
from app.core.logging import get_logger
from app.core.request_id import get_request_id
from app.db.repositories.decisions_repo import (
    DecisionCreateError,
    DecisionNotFoundError,
    DecisionsRepository,
    get_decisions_repo,
)
from app.models.decision_intake import (
    DecisionCreateResponse,
    DecisionDeleteResponse,
    DecisionDetailResponse,
    DecisionIntakeRequest,
    DecisionListItem,
    DecisionListResponse,
    ErrorResponse,
)
from app.services.decision_normalize import normalize_decision_intake

logger = get_logger(__name__)

router = APIRouter(prefix="/decisions", tags=["Decisions"])

# Type alias for dependency injection
DecisionsRepo = Annotated[DecisionsRepository, Depends(get_decisions_repo)]


def make_error_response(message: str) -> ErrorResponse:
    """Create a standard error response with request ID."""
    return ErrorResponse(error=message, requestId=get_request_id())


# ============================================================================
# CREATE
# ============================================================================


@router.post(
    "/intake",
    response_model=DecisionCreateResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Validation error"},
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        500: {"model": ErrorResponse, "description": "Server error"},
    },
)
async def create_decision_intake(
    intake: DecisionIntakeRequest,
    user: AuthenticatedUser,
    repo: DecisionsRepo,
) -> DecisionCreateResponse:
    """
    Create a new decision from intake data.

    Normalizes the intake data, validates it, and persists to database.
    Returns the created decision ID and any normalization warnings.
    """
    try:
        # Normalize and validate
        normalized = normalize_decision_intake(intake)

        # Create in database
        result = await repo.create_decision(user.id, normalized)

        return DecisionCreateResponse(
            decision_id=result["decision_id"],
            status=result["status"],
            created_at=result["created_at"],
            updated_at=result["updated_at"],
            warnings=normalized.warnings,
        )

    except ValueError as e:
        logger.warning(
            "Intake validation failed",
            error=str(e),
            request_id=get_request_id(),
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except DecisionCreateError as e:
        logger.error(
            "Decision creation failed",
            error=str(e),
            request_id=get_request_id(),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create decision",
        )


# ============================================================================
# LIST
# ============================================================================


@router.get(
    "",
    response_model=DecisionListResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"},
    },
)
async def list_decisions(
    user: AuthenticatedUser,
    repo: DecisionsRepo,
) -> DecisionListResponse:
    """
    List all decisions for the authenticated user.

    Returns a list of decision summaries sorted by most recently updated.
    """
    decisions = await repo.list_decisions(user.id)

    return DecisionListResponse(
        items=[
            DecisionListItem(
                decision_id=d["decision_id"],
                title=d["title"],
                status=d["status"],
                updated_at=d["updated_at"],
            )
            for d in decisions
        ]
    )


# ============================================================================
# GET
# ============================================================================


@router.get(
    "/{decision_id}",
    response_model=DecisionDetailResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        404: {"model": ErrorResponse, "description": "Not found"},
    },
)
async def get_decision(
    decision_id: UUID,
    user: AuthenticatedUser,
    repo: DecisionsRepo,
) -> DecisionDetailResponse:
    """
    Get a single decision with full intake data.

    Returns 404 if the decision doesn't exist or belongs to another user.
    """
    try:
        result = await repo.get_decision(user.id, decision_id)

        # Convert stored JSON back to model
        intake_data = result.get("intake", {})
        intake = DecisionIntakeRequest(**intake_data) if intake_data else None

        if intake is None:
            raise DecisionNotFoundError("Decision intake data not found")

        return DecisionDetailResponse(
            decision_id=result["decision_id"],
            status=result["status"],
            created_at=result["created_at"],
            updated_at=result["updated_at"],
            intake=intake,
        )

    except DecisionNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Decision not found",
        )


# ============================================================================
# UPDATE (REPLACE)
# ============================================================================


@router.put(
    "/{decision_id}",
    response_model=DecisionDetailResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation error"},
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        404: {"model": ErrorResponse, "description": "Not found"},
    },
)
async def replace_decision(
    decision_id: UUID,
    intake: DecisionIntakeRequest,
    user: AuthenticatedUser,
    repo: DecisionsRepo,
) -> DecisionDetailResponse:
    """
    Replace a decision's intake data (full replace, idempotent).

    The entire intake must be provided. Partial updates are not supported.
    Returns 404 if the decision doesn't exist or belongs to another user.
    """
    try:
        # Normalize and validate
        normalized = normalize_decision_intake(intake)

        # Update in database
        result = await repo.replace_decision(user.id, decision_id, normalized)

        # Convert stored JSON back to model
        intake_model = DecisionIntakeRequest(**result.get("intake", {}))

        return DecisionDetailResponse(
            decision_id=result["decision_id"],
            status=result["status"],
            created_at=result["created_at"],
            updated_at=result["updated_at"],
            intake=intake_model,
            warnings=normalized.warnings,
        )

    except ValueError as e:
        logger.warning(
            "Intake validation failed",
            error=str(e),
            request_id=get_request_id(),
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except DecisionNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Decision not found",
        )


# ============================================================================
# DELETE
# ============================================================================


@router.delete(
    "/{decision_id}",
    response_model=DecisionDeleteResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        404: {"model": ErrorResponse, "description": "Not found"},
    },
)
async def delete_decision(
    decision_id: UUID,
    user: AuthenticatedUser,
    repo: DecisionsRepo,
) -> DecisionDeleteResponse:
    """
    Delete a decision and all related data.

    This action is permanent and cannot be undone.
    Returns 404 if the decision doesn't exist or belongs to another user.
    """
    try:
        await repo.delete_decision(user.id, decision_id)
        return DecisionDeleteResponse(ok=True)

    except DecisionNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Decision not found",
        )
