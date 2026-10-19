from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_liveness_does_not_need_database():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_readiness_success(monkeypatch):
    monkeypatch.setattr("app.main.check_database", lambda: None)
    assert client.get("/health/db").status_code == 200


def test_readiness_failure_hides_secrets(monkeypatch):
    def fail():
        raise RuntimeError("postgresql://user:SECRET@localhost/fitness_dev")
    monkeypatch.setattr("app.main.check_database", fail)
    response = client.get("/health/db")
    assert response.status_code == 503
    assert response.json() == {"detail": "Database unavailable"}
    assert "SECRET" not in response.text


def test_openapi_exposes_health_only():
    assert set(client.get("/openapi.json").json()["paths"]) == {"/health", "/health/db"}
