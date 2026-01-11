"""
Request ID middleware for tracing requests.

Propagates or generates X-Request-Id header for request tracing.
"""

import uuid
from contextvars import ContextVar
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

# Context variable to store request ID for the current request
request_id_ctx: ContextVar[str] = ContextVar("request_id", default="")

# Header names
REQUEST_ID_HEADER = "X-Request-Id"


def get_request_id() -> str:
    """
    Get the current request ID from context.

    Returns:
        The request ID for the current request, or empty string if not set
    """
    return request_id_ctx.get()


class RequestIdMiddleware(BaseHTTPMiddleware):
    """
    Middleware to propagate or generate request IDs.

    - Reads X-Request-Id from incoming request headers
    - If not present, generates a new UUID
    - Stores in context variable for use throughout the request
    - Adds X-Request-Id to response headers
    """

    async def dispatch(
        self,
        request: Request,
        call_next: Callable,
    ) -> Response:
        """Process the request with request ID handling."""
        # Get existing request ID or generate new one
        request_id = request.headers.get(REQUEST_ID_HEADER)
        if not request_id:
            request_id = str(uuid.uuid4())

        # Store in context
        token = request_id_ctx.set(request_id)

        try:
            # Process request
            response = await call_next(request)

            # Add request ID to response headers
            response.headers[REQUEST_ID_HEADER] = request_id

            return response
        finally:
            # Reset context
            request_id_ctx.reset(token)
