"""
Supabase JWT Authentication utilities.

This module provides JWT verification for Supabase auth tokens.
It uses offline verification with the JWT secret for performance.
"""

import time
from typing import Annotated
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# Security scheme for Swagger UI
security = HTTPBearer(auto_error=False)


class TokenPayload(BaseModel):
    """Decoded JWT token payload from Supabase."""

    sub: str  # User ID (UUID string)
    aud: str  # Audience (authenticated, anon, etc.)
    role: str  # Role (authenticated, anon, service_role)
    email: str | None = None
    phone: str | None = None
    app_metadata: dict | None = None
    user_metadata: dict | None = None
    iat: int  # Issued at
    exp: int  # Expiration


class CurrentUser(BaseModel):
    """Represents the current authenticated user."""

    id: UUID
    email: str | None = None
    role: str = "authenticated"
    app_metadata: dict | None = None
    user_metadata: dict | None = None


class AuthError(Exception):
    """Custom authentication error."""

    def __init__(self, message: str, status_code: int = status.HTTP_401_UNAUTHORIZED):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


def verify_supabase_jwt(token: str) -> TokenPayload:
    """
    Verify a Supabase JWT token using the JWT secret.

    Args:
        token: The JWT token string (without 'Bearer ' prefix)

    Returns:
        TokenPayload: Decoded token payload

    Raises:
        AuthError: If token is invalid, expired, or verification fails
    """
    if not settings.SUPABASE_JWT_SECRET:
        logger.error("SUPABASE_JWT_SECRET not configured")
        raise AuthError(
            "Authentication not configured",
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    try:
        # Decode and verify the JWT
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated",
            options={
                "verify_exp": True,
                "verify_aud": True,
                "require": ["sub", "aud", "role", "exp", "iat"],
            },
        )

        # Check expiration explicitly (jwt.decode should handle this, but be safe)
        if payload.get("exp", 0) < time.time():
            raise AuthError("Token has expired")

        # Validate role
        role = payload.get("role", "")
        if role not in ("authenticated", "service_role"):
            raise AuthError("Invalid token role")

        return TokenPayload(
            sub=payload["sub"],
            aud=payload["aud"],
            role=payload["role"],
            email=payload.get("email"),
            phone=payload.get("phone"),
            app_metadata=payload.get("app_metadata"),
            user_metadata=payload.get("user_metadata"),
            iat=payload["iat"],
            exp=payload["exp"],
        )

    except jwt.ExpiredSignatureError:
        logger.warning("Token expired")
        raise AuthError("Token has expired")
    except jwt.InvalidAudienceError:
        logger.warning("Invalid token audience")
        raise AuthError("Invalid token audience")
    except jwt.InvalidTokenError as e:
        # Don't log the actual token for security
        logger.warning("Invalid token", error_type=type(e).__name__)
        raise AuthError("Invalid authentication token")
    except Exception as e:
        logger.error("Unexpected auth error", error_type=type(e).__name__)
        raise AuthError("Authentication failed")


def get_token_from_header(
    credentials: HTTPAuthorizationCredentials | None,
) -> str:
    """
    Extract token from Authorization header.

    Args:
        credentials: The HTTP Bearer credentials

    Returns:
        str: The token string

    Raises:
        HTTPException: If no valid credentials provided
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication scheme",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return credentials.credentials


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)],
) -> CurrentUser:
    """
    FastAPI dependency to get the current authenticated user.

    Usage:
        @router.get("/protected")
        async def protected_route(user: CurrentUser = Depends(get_current_user)):
            return {"user_id": user.id}

    Args:
        credentials: HTTP Bearer credentials from Authorization header

    Returns:
        CurrentUser: The authenticated user information

    Raises:
        HTTPException: If authentication fails
    """
    try:
        token = get_token_from_header(credentials)
        payload = verify_supabase_jwt(token)

        return CurrentUser(
            id=UUID(payload.sub),
            email=payload.email,
            role=payload.role,
            app_metadata=payload.app_metadata,
            user_metadata=payload.user_metadata,
        )

    except AuthError as e:
        raise HTTPException(
            status_code=e.status_code,
            detail=e.message,
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_optional_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)],
) -> CurrentUser | None:
    """
    FastAPI dependency to optionally get the current user.

    Returns None instead of raising an exception if not authenticated.
    Useful for endpoints that work for both authenticated and anonymous users.

    Usage:
        @router.get("/maybe-protected")
        async def maybe_protected(user: CurrentUser | None = Depends(get_optional_user)):
            if user:
                return {"user_id": user.id}
            return {"message": "Anonymous access"}

    Args:
        credentials: HTTP Bearer credentials from Authorization header

    Returns:
        CurrentUser | None: The authenticated user or None
    """
    if credentials is None:
        return None

    try:
        token = get_token_from_header(credentials)
        payload = verify_supabase_jwt(token)

        return CurrentUser(
            id=UUID(payload.sub),
            email=payload.email,
            role=payload.role,
            app_metadata=payload.app_metadata,
            user_metadata=payload.user_metadata,
        )

    except (AuthError, HTTPException):
        return None


# Type alias for dependency injection
AuthenticatedUser = Annotated[CurrentUser, Depends(get_current_user)]
OptionalUser = Annotated[CurrentUser | None, Depends(get_optional_user)]
