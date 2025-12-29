import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["message"] == "Roster Maker API"


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_roster_health_check():
    response = client.get("/api/roster/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
