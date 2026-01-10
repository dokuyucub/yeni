"""Health check models."""

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    """Health check response model."""

    status: str = Field(description="Health status of the API")
    version: str = Field(description="API version")
    timestamp: str = Field(description="Current server timestamp in ISO format")


class ErrorResponse(BaseModel):
    """Standard error response model."""

    error: str = Field(description="Error type")
    message: str = Field(description="Human-readable error message")
    status_code: int = Field(description="HTTP status code")
    request_id: str | None = Field(default=None, description="Request ID for tracking")
