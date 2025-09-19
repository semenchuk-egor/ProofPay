"""
Tests for attestation API endpoints
"""
import pytest
from fastapi.testclient import TestClient
from backend.server import app

client = TestClient(app)


def test_verify_attestation_endpoint():
    """Test attestation verification endpoint"""
    # Mock attestation UID
    uid = "0x1234567890abcdef"
    
    response = client.get(f"/api/attestation/verify/{uid}")
    
    assert response.status_code == 200
    data = response.json()
    assert "uid" in data
    assert "valid" in data
    assert data["uid"] == uid


def test_get_attestation_not_found():
    """Test getting non-existent attestation"""
    uid = "0xinvalid"
    
    response = client.get(f"/api/attestation/{uid}")
    
    # Should return 404 or handle gracefully
    assert response.status_code in [404, 200]


def test_link_attestation():
    """Test linking attestation to user"""
    payload = {
        "uid": "0x1234567890abcdef"
    }
    
    response = client.post("/api/attestation/link", json=payload)
    
    # Should return success or validation error
    assert response.status_code in [200, 400]
    
    if response.status_code == 200:
        data = response.json()
        assert "success" in data


def test_link_attestation_invalid():
    """Test linking invalid attestation"""
    payload = {
        "uid": ""
    }
    
    response = client.post("/api/attestation/link", json=payload)
    
    # Should return 400 for invalid input
    assert response.status_code == 422  # Validation error


@pytest.mark.asyncio
async def test_attestation_validation():
    """Test attestation validation logic"""
    from backend.services.eas_service import eas_service
    
    # Test with mock UID
    uid = "0x1234567890abcdef"
    result = eas_service.verify_attestation(uid)
    
    # Should return boolean
    assert isinstance(result, bool)
