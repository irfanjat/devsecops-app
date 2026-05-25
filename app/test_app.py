import pytest
import json

def test_home_endpoint(client):
    resp = client.get('/')
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["status"] == "running"
    assert "version" in data

def test_health_endpoint(client):
    resp = client.get('/health')
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"

def test_secure_endpoint_no_auth(client):
    resp = client.get('/secure')
    assert resp.status_code == 401

def test_secure_endpoint_with_auth(client):
    resp = client.get('/secure', headers={"Authorization": "Bearer test123"})
    assert resp.status_code == 200
    assert resp.get_json()["message"] == "secure endpoint"

@pytest.fixture
def client():
    from app import app
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client
