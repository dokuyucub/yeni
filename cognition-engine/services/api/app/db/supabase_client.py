"""
Supabase client for database operations.

Uses the SERVICE_ROLE key to bypass RLS for backend operations.
Ownership enforcement is done in application code.
"""

from functools import lru_cache

from supabase import Client, create_client

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


@lru_cache
def get_supabase_client() -> Client:
    """
    Get a cached Supabase client using the service role key.

    The service role key bypasses RLS, so all authorization
    must be enforced in the repository layer.

    Returns:
        Client: Supabase client instance
    """
    if not settings.SUPABASE_URL:
        raise RuntimeError("SUPABASE_URL not configured")
    if not settings.SUPABASE_SERVICE_ROLE_KEY:
        raise RuntimeError("SUPABASE_SERVICE_ROLE_KEY not configured")

    logger.debug("Creating Supabase client")
    return create_client(
        settings.SUPABASE_URL,
        settings.SUPABASE_SERVICE_ROLE_KEY,
    )


# Convenience instance
supabase = get_supabase_client
