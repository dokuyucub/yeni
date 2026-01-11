"""
Route tests for decision intake API.

Uses mocked repository and auth to test API behavior without Supabase.
"""

from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch
from uuid import UUID, uuid4

import pytest
from fastapi.testclient import TestClient

from app.core.auth import CurrentUser
from app.db.repositories.decisions_repo import (
    DecisionCreateError,
    DecisionNotFoundError,
)
from app.main import app
from app.models.decision_intake import DecisionStatus


# ============================================================================
# FIXTURES
# ============================================================================


@pytest.fixture
def test_user() -> CurrentUser:
    """Create a test user."""
    return CurrentUser(
        id=UUID("12345678-1234-1234-1234-123456789012"),
        email="test@example.com",
        role="authenticated",
    )


@pytest.fixture
def valid_intake_payload() -> dict:
    """Create a valid intake request payload."""
    return {
        "title": "Test Decision Title",
        "statement": "This is a test decision statement that is long enough.",
        "options": [
            {
                "label": "O1",
                "name": "Option One",
                "description": "Description of option one",
            },
            {
                "label": "O2",
                "name": "Option Two",
                "description": "Description of option two",
            },
        ],
        "timeHorizons": {
            "decisionDeadline": "End of month",
            "implementationPeriod": "3 months",
            "impactHorizon": "1 year",
        },
        "objectives": [
            {"key": "money", "weight": 60},
            {"key": "time", "weight": 40},
        ],
        "constraints": {
            "budgetMin": 1000,
            "budgetMax": 5000,
            "mustHaves": "Must work",
            "cantDo": "Can't fail",
        },
        "stakeholders": {
            "decisionMaker": "Me",
            "influencers": "Boss",
            "affected": "Team",
        },
        "baselineDoNothing": "If I do nothing, status quo continues.",
        "resources": {"available": "Time and money", "needed": "Help"},
        "risk": {"tolerance": "moderate", "maxAcceptableLoss": "$1000"},
        "dealbreakers": ["Losing job", "Going bankrupt"],
        "knownUncertainties": ["Market conditions", "Health"],
        "gutPreference": {
            "optionLabel": "O1",
            "confidence": 70,
            "reason": "Feels right",
        },
        "successDefinition": "Achieve the goal within budget and time.",
        "failureDefinition": "Miss the deadline or exceed budget significantly.",
    }


@pytest.fixture
def mock_auth(test_user: CurrentUser):
    """Mock authentication to return test user."""
    with patch("app.routers.decisions.AuthenticatedUser") as mock:
        # This doesn't directly mock the dependency, we need to override
        yield mock


def override_auth(test_user: CurrentUser):
    """Create auth override for dependency injection."""
    from app.core.auth import get_current_user

    async def override():
        return test_user

    return {get_current_user: override}


# ============================================================================
# AUTH TESTS
# ============================================================================


class TestAuthRequired:
    """Tests for authentication requirements."""

    def test_create_without_auth_returns_401(self, valid_intake_payload: dict):
        """POST /decisions/intake without auth should return 401."""
        client = TestClient(app)
        response = client.post("/decisions/intake", json=valid_intake_payload)

        assert response.status_code == 401

    def test_list_without_auth_returns_401(self):
        """GET /decisions without auth should return 401."""
        client = TestClient(app)
        response = client.get("/decisions")

        assert response.status_code == 401

    def test_get_without_auth_returns_401(self):
        """GET /decisions/{id} without auth should return 401."""
        client = TestClient(app)
        response = client.get(f"/decisions/{uuid4()}")

        assert response.status_code == 401

    def test_put_without_auth_returns_401(self, valid_intake_payload: dict):
        """PUT /decisions/{id} without auth should return 401."""
        client = TestClient(app)
        response = client.put(f"/decisions/{uuid4()}", json=valid_intake_payload)

        assert response.status_code == 401

    def test_delete_without_auth_returns_401(self):
        """DELETE /decisions/{id} without auth should return 401."""
        client = TestClient(app)
        response = client.delete(f"/decisions/{uuid4()}")

        assert response.status_code == 401


# ============================================================================
# CREATE TESTS
# ============================================================================


class TestCreateDecision:
    """Tests for POST /decisions/intake."""

    def test_create_with_valid_payload_returns_201(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Valid intake should create decision and return 201."""
        decision_id = uuid4()
        now = datetime.now(timezone.utc)

        mock_repo = AsyncMock()
        mock_repo.create_decision.return_value = {
            "decision_id": decision_id,
            "status": DecisionStatus.DRAFT,
            "created_at": now,
            "updated_at": now,
        }

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.post(
                    "/decisions/intake", json=valid_intake_payload
                )

                assert response.status_code == 201
                data = response.json()
                assert data["decision_id"] == str(decision_id)
                assert data["status"] == "draft"
                assert "created_at" in data
                assert "warnings" in data
            finally:
                app.dependency_overrides.clear()

    def test_create_with_invalid_title_returns_400(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Invalid title should return 400."""
        valid_intake_payload["title"] = "Hi"

        app.dependency_overrides.update(override_auth(test_user))
        try:
            client = TestClient(app)
            response = client.post("/decisions/intake", json=valid_intake_payload)

            assert response.status_code == 400
            assert "Title must be at least 3 characters" in response.json()["detail"]
        finally:
            app.dependency_overrides.clear()

    def test_create_with_one_option_returns_400(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Less than 2 options should return 400."""
        valid_intake_payload["options"] = [valid_intake_payload["options"][0]]

        app.dependency_overrides.update(override_auth(test_user))
        try:
            client = TestClient(app)
            response = client.post("/decisions/intake", json=valid_intake_payload)

            assert response.status_code == 400
            assert "At least 2 options" in response.json()["detail"]
        finally:
            app.dependency_overrides.clear()

    def test_create_repo_error_returns_500(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Repository error should return 500."""
        mock_repo = AsyncMock()
        mock_repo.create_decision.side_effect = DecisionCreateError("DB error")

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.post(
                    "/decisions/intake", json=valid_intake_payload
                )

                assert response.status_code == 500
            finally:
                app.dependency_overrides.clear()


# ============================================================================
# LIST TESTS
# ============================================================================


class TestListDecisions:
    """Tests for GET /decisions."""

    def test_list_returns_user_decisions(self, test_user: CurrentUser):
        """List should return decisions for the authenticated user."""
        decision_id = uuid4()
        now = datetime.now(timezone.utc)

        mock_repo = AsyncMock()
        mock_repo.list_decisions.return_value = [
            {
                "decision_id": decision_id,
                "title": "Test Decision",
                "status": DecisionStatus.DRAFT,
                "updated_at": now,
            }
        ]

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.get("/decisions")

                assert response.status_code == 200
                data = response.json()
                assert "items" in data
                assert len(data["items"]) == 1
                assert data["items"][0]["decision_id"] == str(decision_id)
                assert data["items"][0]["title"] == "Test Decision"
            finally:
                app.dependency_overrides.clear()

    def test_list_empty_returns_empty_list(self, test_user: CurrentUser):
        """Empty list should return empty items array."""
        mock_repo = AsyncMock()
        mock_repo.list_decisions.return_value = []

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.get("/decisions")

                assert response.status_code == 200
                data = response.json()
                assert data["items"] == []
            finally:
                app.dependency_overrides.clear()


# ============================================================================
# GET TESTS
# ============================================================================


class TestGetDecision:
    """Tests for GET /decisions/{id}."""

    def test_get_existing_decision_returns_200(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Getting existing decision should return 200 with full data."""
        decision_id = uuid4()
        now = datetime.now(timezone.utc)

        mock_repo = AsyncMock()
        mock_repo.get_decision.return_value = {
            "decision_id": decision_id,
            "status": DecisionStatus.DRAFT,
            "created_at": now,
            "updated_at": now,
            "intake": valid_intake_payload,
        }

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.get(f"/decisions/{decision_id}")

                assert response.status_code == 200
                data = response.json()
                assert data["decision_id"] == str(decision_id)
                assert "intake" in data
                assert data["intake"]["title"] == valid_intake_payload["title"]
            finally:
                app.dependency_overrides.clear()

    def test_get_nonexistent_decision_returns_404(self, test_user: CurrentUser):
        """Getting non-existent decision should return 404."""
        mock_repo = AsyncMock()
        mock_repo.get_decision.side_effect = DecisionNotFoundError("Not found")

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.get(f"/decisions/{uuid4()}")

                assert response.status_code == 404
            finally:
                app.dependency_overrides.clear()


# ============================================================================
# PUT TESTS
# ============================================================================


class TestReplaceDecision:
    """Tests for PUT /decisions/{id}."""

    def test_replace_existing_returns_200(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Replacing existing decision should return 200."""
        decision_id = uuid4()
        now = datetime.now(timezone.utc)

        mock_repo = AsyncMock()
        mock_repo.replace_decision.return_value = {
            "decision_id": decision_id,
            "status": DecisionStatus.DRAFT,
            "created_at": now,
            "updated_at": now,
            "intake": valid_intake_payload,
        }

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.put(
                    f"/decisions/{decision_id}", json=valid_intake_payload
                )

                assert response.status_code == 200
                data = response.json()
                assert data["decision_id"] == str(decision_id)
            finally:
                app.dependency_overrides.clear()

    def test_replace_nonexistent_returns_404(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Replacing non-existent decision should return 404."""
        mock_repo = AsyncMock()
        mock_repo.replace_decision.side_effect = DecisionNotFoundError("Not found")

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.put(
                    f"/decisions/{uuid4()}", json=valid_intake_payload
                )

                assert response.status_code == 404
            finally:
                app.dependency_overrides.clear()

    def test_replace_with_invalid_payload_returns_400(
        self,
        test_user: CurrentUser,
        valid_intake_payload: dict,
    ):
        """Invalid payload should return 400."""
        valid_intake_payload["title"] = "Hi"

        app.dependency_overrides.update(override_auth(test_user))
        try:
            client = TestClient(app)
            response = client.put(
                f"/decisions/{uuid4()}", json=valid_intake_payload
            )

            assert response.status_code == 400
        finally:
            app.dependency_overrides.clear()


# ============================================================================
# DELETE TESTS
# ============================================================================


class TestDeleteDecision:
    """Tests for DELETE /decisions/{id}."""

    def test_delete_existing_returns_200(self, test_user: CurrentUser):
        """Deleting existing decision should return 200."""
        mock_repo = AsyncMock()
        mock_repo.delete_decision.return_value = True

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.delete(f"/decisions/{uuid4()}")

                assert response.status_code == 200
                assert response.json()["ok"] is True
            finally:
                app.dependency_overrides.clear()

    def test_delete_nonexistent_returns_404(self, test_user: CurrentUser):
        """Deleting non-existent decision should return 404."""
        mock_repo = AsyncMock()
        mock_repo.delete_decision.side_effect = DecisionNotFoundError("Not found")

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.delete(f"/decisions/{uuid4()}")

                assert response.status_code == 404
            finally:
                app.dependency_overrides.clear()


# ============================================================================
# REQUEST ID TESTS
# ============================================================================


class TestRequestId:
    """Tests for request ID handling."""

    def test_response_includes_request_id_header(self, test_user: CurrentUser):
        """Response should include X-Request-Id header."""
        mock_repo = AsyncMock()
        mock_repo.list_decisions.return_value = []

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.get("/decisions")

                assert "x-request-id" in response.headers
            finally:
                app.dependency_overrides.clear()

    def test_echoes_provided_request_id(self, test_user: CurrentUser):
        """Should echo back provided X-Request-Id."""
        mock_repo = AsyncMock()
        mock_repo.list_decisions.return_value = []
        request_id = "test-request-id-12345"

        with patch(
            "app.routers.decisions.get_decisions_repo", return_value=mock_repo
        ):
            app.dependency_overrides.update(override_auth(test_user))
            try:
                client = TestClient(app)
                response = client.get(
                    "/decisions", headers={"X-Request-Id": request_id}
                )

                assert response.headers.get("x-request-id") == request_id
            finally:
                app.dependency_overrides.clear()
