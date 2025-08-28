"""
User API endpoints
"""
from fastapi import APIRouter, HTTPException
from backend.models.user import User, UserCreate, UserUpdate, UserStats
from backend.services.eas_service import eas_service
from uuid import uuid4
from datetime import datetime

router = APIRouter(prefix="/api/users", tags=["users"])

# In-memory storage (replace with database)
users_db = {}


@router.post("/", response_model=User)
async def create_user(user_data: UserCreate):
    """Create a new user account"""
    # Check if wallet already exists
    for user in users_db.values():
        if user['wallet_address'] == user_data.wallet_address:
            raise HTTPException(status_code=400, detail="Wallet address already registered")
    
    user_id = str(uuid4())
    user = {
        "id": user_id,
        "wallet_address": user_data.wallet_address,
        "attestation_uid": None,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    users_db[user_id] = user
    return User(**user)


@router.get("/{user_id}", response_model=User)
async def get_user(user_id: str):
    """Get user by ID"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    return User(**users_db[user_id])


@router.get("/wallet/{wallet_address}", response_model=User)
async def get_user_by_wallet(wallet_address: str):
    """Get user by wallet address"""
    for user in users_db.values():
        if user['wallet_address'].lower() == wallet_address.lower():
            return User(**user)
    
    raise HTTPException(status_code=404, detail="User not found")


@router.patch("/{user_id}", response_model=User)
async def update_user(user_id: str, update_data: UserUpdate):
    """Update user information"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    user = users_db[user_id]
    
    if update_data.attestation_uid:
        # Verify attestation
        if not eas_service.verify_attestation(update_data.attestation_uid):
            raise HTTPException(status_code=400, detail="Invalid attestation")
        
        user['attestation_uid'] = update_data.attestation_uid
    
    user['updated_at'] = datetime.utcnow()
    users_db[user_id] = user
    
    return User(**user)


@router.get("/{user_id}/stats", response_model=UserStats)
async def get_user_stats(user_id: str):
    """Get user statistics"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    user = users_db[user_id]
    
    stats = UserStats(
        attestation_linked=user['attestation_uid'] is not None,
        total_payments=0,  # TODO: Calculate from payments
        total_received=0   # TODO: Calculate from payments
    )
    
    # Get KYC level if attestation is linked
    if user['attestation_uid']:
        attestation = eas_service.get_attestation(user['attestation_uid'])
        if attestation and attestation['data']:
            kyc_data = eas_service.decode_kyc_data(attestation['data'])
            if kyc_data:
                stats.kyc_level = kyc_data['level']
    
    return stats
