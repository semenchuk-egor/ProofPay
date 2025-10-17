import pytest
from fastapi.testclient import TestClient
from backend.server import app

client = TestClient(app)

def test_create_user():
    response = client.post("/api/users/", json={
        "wallet_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    })
    assert response.status_code in [200, 201]

def test_get_user_by_wallet():
    wallet = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    response = client.get(f"/api/users/wallet/{wallet}")
    assert response.status_code in [200, 404]
