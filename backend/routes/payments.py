from fastapi import APIRouter, HTTPException, Depends
from models.payment import Payment
from services.eas_service import EASService
from typing import List

router = APIRouter(prefix='/api/payments', tags=['payments'])

@router.post('/', response_model=dict)
async def create_payment(
    sender: str,
    recipient: str,
    amount: float,
    description: str = ""
):
    """Create new payment with attestation"""
    eas_service = EASService()
    
    # Create attestation
    attestation_uid = await eas_service.create_attestation({
        'sender': sender,
        'recipient': recipient,
        'amount': amount,
        'description': description
    })
    
    return {
        'status': 'success',
        'attestation_uid': attestation_uid,
        'message': 'Payment attestation created'
    }

@router.get('/{payment_id}', response_model=dict)
async def get_payment(payment_id: str):
    """Get payment details"""
    # Implementation
    return {'payment_id': payment_id, 'status': 'completed'}

@router.get('/', response_model=List[dict])
async def list_payments(address: str = None):
    """List all payments or filter by address"""
    # Implementation
    return []
