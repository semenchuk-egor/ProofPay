"""
User data models
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class User(BaseModel):
    """User account model"""
    id: str = Field(..., description="Unique user identifier")
    wallet_address: str = Field(..., description="Ethereum wallet address")
    attestation_uid: Optional[str] = Field(None, description="Linked EAS attestation UID")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": "user_123",
                "wallet_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
                "attestation_uid": "0xabc123...",
                "created_at": "2025-08-20T10:00:00",
                "updated_at": "2025-08-20T10:00:00"
            }
        }


class UserCreate(BaseModel):
    """Model for creating a new user"""
    wallet_address: str


class UserUpdate(BaseModel):
    """Model for updating user information"""
    attestation_uid: Optional[str] = None


class UserStats(BaseModel):
    """User statistics model"""
    total_payments: int = 0
    total_received: int = 0
    attestation_linked: bool = False
    kyc_level: Optional[int] = None
