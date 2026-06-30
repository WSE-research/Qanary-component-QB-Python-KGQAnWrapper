"""End-to-end smoke test: the component app boots and serves its callback
endpoints (no triplestore or KGQAn backend needed)."""
import pytest
from fastapi.testclient import TestClient

pytestmark = pytest.mark.e2e


def test_health_and_about():
    from component import app

    client = TestClient(app)
    health = client.get("/health")
    assert health.status_code == 200
    assert health.text == "alive"

    about = client.get("/about")
    assert about.status_code == 200
    assert "KGQAn" in about.text
