import pytest
from fastapi.testclient import TestClient
from backend.server import app

client = TestClient(app)

def test_create_payment():
    response = client.post("/api/payments/", json={
        "recipient_address": "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
        "amount": "1000000000000000000",
        "token_address": None
    })
    assert response.status_code in [200, 201]

def test_get_payment():
    payment_id = "test_payment_123"
    response = client.get(f"/api/payments/{payment_id}")
    assert response.status_code in [200, 404]
