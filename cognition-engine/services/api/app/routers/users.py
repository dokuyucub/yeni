"""User-related endpoints."""

from fastapi import APIRouter

from app.core.auth import AuthenticatedUser
from app.models.users import UserMeResponse

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserMeResponse)
async def get_current_user_info(user: AuthenticatedUser) -> UserMeResponse:
    """
    Get the current authenticated user's information.

    This endpoint verifies the Supabase JWT token and returns
    the user's ID and email (if available).

    Requires: Valid Bearer token in Authorization header.
    """
    return UserMeResponse(
        id=str(user.id),
        email=user.email,
        role=user.role,
        app_metadata=user.app_metadata,
        user_metadata=user.user_metadata,
    )
