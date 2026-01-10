"""Health check endpoints."""

from datetime import UTC, datetime

from fastapi import APIRouter

from app import __version__
from app.models.health import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """
    Check API health status.

    Returns basic health information including version and timestamp.
    """
    return HealthResponse(
        status="healthy",
        version=__version__,
        timestamp=datetime.now(UTC).isoformat(),
    )
