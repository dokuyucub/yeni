"""Tests for authentication module."""

import time
from unittest.mock import patch
from uuid import uuid4

import jwt
import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient

from app.core.auth import (
    AuthError,
    CurrentUser,
    TokenPayload,
    verify_supabase_jwt,
)
from app.main import app

# Test JWT secret (matches local Supabase default)
TEST_JWT_SECRET = "super-secret-jwt-token-with-at-least-32-characters-long"


def create_test_token(
    user_id: str | None = None,
    email: str | None = "test@example.com",
    role: str = "authenticated",
    exp_offset: int = 3600,  # 1 hour from now
    secret: str = TEST_JWT_SECRET,
) -> str:
    """Create a test JWT token."""
    now = int(time.time())
    payload = {
        "sub": user_id or str(uuid4()),
        "aud": "authenticated",
        "role": role,
        "email": email,
        "iat": now,
        "exp": now + exp_offset,
    }
    return jwt.encode(payload, secret, algorithm="HS256")


class TestVerifySupabaseJwt:
    """Tests for verify_supabase_jwt function."""

    @patch("app.core.auth.settings")
    def test_valid_token(self, mock_settings: any) -> None:
        """Test successful token verification."""
        mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

        user_id = str(uuid4())
        token = create_test_token(user_id=user_id, email="test@example.com")

        payload = verify_supabase_jwt(token)

        assert payload.sub == user_id
        assert payload.email == "test@example.com"
        assert payload.role == "authenticated"

    @patch("app.core.auth.settings")
    def test_expired_token(self, mock_settings: any) -> None:
        """Test that expired tokens are rejected."""
        mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

        # Create token that expired 1 hour ago
        token = create_test_token(exp_offset=-3600)

        with pytest.raises(AuthError) as exc_info:
            verify_supabase_jwt(token)

        assert "expired" in exc_info.value.message.lower()

    @patch("app.core.auth.settings")
    def test_invalid_secret(self, mock_settings: any) -> None:
        """Test that tokens signed with wrong secret are rejected."""
        mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

        # Create token with different secret
        token = create_test_token(secret="wrong-secret-that-is-at-least-32-chars-long")

        with pytest.raises(AuthError) as exc_info:
            verify_supabase_jwt(token)

        assert "invalid" in exc_info.value.message.lower()

    @patch("app.core.auth.settings")
    def test_missing_jwt_secret(self, mock_settings: any) -> None:
        """Test that missing JWT secret raises error."""
        mock_settings.SUPABASE_JWT_SECRET = ""

        token = create_test_token()

        with pytest.raises(AuthError) as exc_info:
            verify_supabase_jwt(token)

        assert exc_info.value.status_code == 500

    @patch("app.core.auth.settings")
    def test_invalid_role(self, mock_settings: any) -> None:
        """Test that anon role is rejected."""
        mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

        # Create token with anon role
        now = int(time.time())
        payload = {
            "sub": str(uuid4()),
            "aud": "authenticated",
            "role": "anon",
            "iat": now,
            "exp": now + 3600,
        }
        token = jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")

        with pytest.raises(AuthError) as exc_info:
            verify_supabase_jwt(token)

        assert "role" in exc_info.value.message.lower()


class TestMeEndpoint:
    """Tests for /users/me endpoint."""

    @patch("app.core.auth.settings")
    def test_me_with_valid_token(self, mock_settings: any) -> None:
        """Test /users/me with valid authentication."""
        mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

        client = TestClient(app)
        user_id = str(uuid4())
        token = create_test_token(user_id=user_id, email="test@example.com")

        response = client.get(
            "/users/me",
            headers={"Authorization": f"Bearer {token}"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id
        assert data["email"] == "test@example.com"
        assert data["role"] == "authenticated"

    def test_me_without_token(self) -> None:
        """Test /users/me without authentication."""
        client = TestClient(app)

        response = client.get("/users/me")

        assert response.status_code == 401
        assert "authorization" in response.json()["detail"].lower()

    @patch("app.core.auth.settings")
    def test_me_with_expired_token(self, mock_settings: any) -> None:
        """Test /users/me with expired token."""
        mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

        client = TestClient(app)
        token = create_test_token(exp_offset=-3600)

        response = client.get(
            "/users/me",
            headers={"Authorization": f"Bearer {token}"},
        )

        assert response.status_code == 401

    def test_me_with_invalid_scheme(self) -> None:
        """Test /users/me with wrong auth scheme."""
        client = TestClient(app)

        response = client.get(
            "/users/me",
            headers={"Authorization": "Basic dXNlcjpwYXNz"},
        )

        assert response.status_code == 401
