from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from services.eas_service import EASService
from typing import Optional

router = APIRouter(prefix='/api/attestations', tags=['attestations'])

class CreateAttestationRequest(BaseModel):
    recipient: str
    amount: float
    description: Optional[str] = ''

class AttestationResponse(BaseModel):
    uid: str
    schema: str
    recipient: str
    attester: str
    timestamp: int

@router.post('/', response_model=AttestationResponse)
async def create_attestation(request: CreateAttestationRequest):
    """Create a new payment attestation on EAS"""
    eas_service = EASService()
    
    attestation = await eas_service.create_attestation({
        'recipient': request.recipient,
        'amount': request.amount,
        'description': request.description
    })
    
    return AttestationResponse(
        uid=attestation['uid'],
        schema=attestation['schema'],
        recipient=attestation['recipient'],
        attester=attestation['attester'],
        timestamp=attestation['timestamp']
    )

@router.get('/{uid}', response_model=AttestationResponse)
async def get_attestation(uid: str):
    """Get attestation details by UID"""
    eas_service = EASService()
    attestation = await eas_service.get_attestation(uid)
    
    if not attestation:
        raise HTTPException(status_code=404, detail='Attestation not found')
    
    return AttestationResponse(**attestation)

@router.post('/{uid}/verify')
async def verify_attestation(uid: str):
    """Verify if attestation is valid"""
    eas_service = EASService()
    is_valid = await eas_service.verify_attestation(uid)
    
    return {
        'uid': uid,
        'valid': bool(is_valid),
        'verified_at': int(datetime.now().timestamp())
    }

@router.get('/')
async def list_attestations(address: Optional[str] = None):
    """List attestations, optionally filtered by address"""
    # Implementation for listing attestations
    return []
