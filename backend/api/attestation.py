"""
Attestation API endpoints
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from backend.services.eas_service import eas_service

router = APIRouter(prefix="/api/attestation", tags=["attestation"])


class AttestationRequest(BaseModel):
    uid: str


class AttestationResponse(BaseModel):
    uid: str
    schema: str
    recipient: str
    attester: str
    time: int
    expirationTime: int
    revocationTime: int
    valid: bool
    data: dict | None = None


@router.get("/verify/{uid}")
async def verify_attestation(uid: str):
    """Verify if attestation is valid"""
    is_valid = eas_service.verify_attestation(uid)
    
    return {
        "uid": uid,
        "valid": is_valid
    }


@router.get("/{uid}")
async def get_attestation(uid: str) -> AttestationResponse:
    """Get attestation details by UID"""
    attestation = eas_service.get_attestation(uid)
    
    if not attestation:
        raise HTTPException(status_code=404, detail="Attestation not found")
    
    # Try to decode KYC data if possible
    kyc_data = None
    if attestation['data']:
        kyc_data = eas_service.decode_kyc_data(attestation['data'])
    
    return AttestationResponse(
        uid=attestation['uid'],
        schema=attestation['schema'],
        recipient=attestation['recipient'],
        attester=attestation['attester'],
        time=attestation['time'],
        expirationTime=attestation['expirationTime'],
        revocationTime=attestation['revocationTime'],
        valid=eas_service.verify_attestation(uid),
        data=kyc_data
    )


@router.post("/link")
async def link_attestation(request: AttestationRequest):
    """Link attestation to user account"""
    uid = request.uid
    
    # Verify attestation exists and is valid
    if not eas_service.verify_attestation(uid):
        raise HTTPException(status_code=400, detail="Invalid or expired attestation")
    
    attestation = eas_service.get_attestation(uid)
    
    return {
        "success": True,
        "attestation": {
            "uid": attestation['uid'],
            "recipient": attestation['recipient'],
            "valid": True
        }
    }
