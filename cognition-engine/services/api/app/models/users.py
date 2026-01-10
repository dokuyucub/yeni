"""User-related models."""

from pydantic import BaseModel, Field


class UserMeResponse(BaseModel):
    """Response model for /users/me endpoint."""

    id: str = Field(description="User's unique identifier (UUID)")
    email: str | None = Field(default=None, description="User's email address")
    role: str = Field(default="authenticated", description="User's role")
    app_metadata: dict | None = Field(default=None, description="Application metadata")
    user_metadata: dict | None = Field(default=None, description="User metadata")
