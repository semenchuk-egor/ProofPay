"""
Payment API endpoints
"""
from fastapi import APIRouter, HTTPException
from backend.models.payment import Payment, PaymentCreate, BatchPaymentCreate, PaymentStatus
from backend.services.blockchain_service import blockchain_service
from uuid import uuid4
from datetime import datetime

router = APIRouter(prefix="/api/payments", tags=["payments"])

# In-memory storage (replace with database)
payments_db = {}


@router.post("/", response_model=Payment)
async def create_payment(payment_data: PaymentCreate):
    """Create a new payment"""
    payment_id = str(uuid4())
    
    payment = {
        "id": payment_id,
        "sender_address": "0x0",  # TODO: Get from auth
        "recipient_address": payment_data.recipient_address,
        "amount": payment_data.amount,
        "token_address": payment_data.token_address,
        "tx_hash": None,
        "status": PaymentStatus.PENDING,
        "payment_type": "single",
        "created_at": datetime.utcnow(),
        "completed_at": None
    }
    
    payments_db[payment_id] = payment
    return Payment(**payment)


@router.get("/{payment_id}", response_model=Payment)
async def get_payment(payment_id: str):
    """Get payment by ID"""
    if payment_id not in payments_db:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    return Payment(**payments_db[payment_id])


@router.patch("/{payment_id}/confirm")
async def confirm_payment(payment_id: str, tx_hash: str):
    """Confirm payment with transaction hash"""
    if payment_id not in payments_db:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    payment = payments_db[payment_id]
    
    # Verify transaction
    is_valid = blockchain_service.verify_transaction(
        tx_hash,
        payment['sender_address'],
        payment['recipient_address']
    )
    
    if not is_valid:
        raise HTTPException(status_code=400, detail="Invalid transaction")
    
    payment['tx_hash'] = tx_hash
    payment['status'] = PaymentStatus.COMPLETED
    payment['completed_at'] = datetime.utcnow()
    
    payments_db[payment_id] = payment
    return Payment(**payment)


@router.get("/user/{address}")
async def get_user_payments(address: str, limit: int = 50, offset: int = 0):
    """Get payments for a user"""
    user_payments = [
        p for p in payments_db.values()
        if p['sender_address'].lower() == address.lower() or 
           p['recipient_address'].lower() == address.lower()
    ]
    
    # Sort by created_at descending
    user_payments.sort(key=lambda x: x['created_at'], reverse=True)
    
    # Pagination
    paginated = user_payments[offset:offset + limit]
    
    return {
        "payments": [Payment(**p) for p in paginated],
        "total": len(user_payments),
        "limit": limit,
        "offset": offset
    }


@router.post("/batch", response_model=dict)
async def create_batch_payment(batch_data: BatchPaymentCreate):
    """Create batch payment"""
    payment_ids = []
    
    for payment_data in batch_data.payments:
        payment_id = str(uuid4())
        
        payment = {
            "id": payment_id,
            "sender_address": "0x0",  # TODO: Get from auth
            "recipient_address": payment_data.recipient_address,
            "amount": payment_data.amount,
            "token_address": batch_data.token_address or payment_data.token_address,
            "tx_hash": None,
            "status": PaymentStatus.PENDING,
            "payment_type": "batch",
            "created_at": datetime.utcnow(),
            "completed_at": None
        }
        
        payments_db[payment_id] = payment
        payment_ids.append(payment_id)
    
    return {
        "batch_id": str(uuid4()),
        "payment_ids": payment_ids,
        "count": len(payment_ids)
    }
