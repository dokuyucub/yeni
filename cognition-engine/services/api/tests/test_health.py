"""Tests for health check endpoints."""

from fastapi.testclient import TestClient

from app import __version__


def test_health_check_returns_healthy(client: TestClient) -> None:
    """Test that health check returns healthy status."""
    response = client.get("/health")

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["version"] == __version__
    assert "timestamp" in data


def test_health_check_response_format(client: TestClient) -> None:
    """Test that health check returns correct response format."""
    response = client.get("/health")

    assert response.status_code == 200
    data = response.json()

    # Verify all required fields are present
    required_fields = {"status", "version", "timestamp"}
    assert required_fields.issubset(data.keys())

    # Verify timestamp is ISO format
    assert "T" in data["timestamp"]
