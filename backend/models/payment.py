"""
Payment data models
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum

class PaymentStatus(str, Enum):
    """Payment status enumeration"""
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class PaymentType(str, Enum):
    """Payment type enumeration"""
    SINGLE = "single"
    BATCH = "batch"
    RECURRING = "recurring"


class Payment(BaseModel):
    """Payment transaction model"""
    id: str = Field(..., description="Unique payment identifier")
    sender_address: str = Field(..., description="Sender wallet address")
    recipient_address: str = Field(..., description="Recipient wallet address")
    amount: str = Field(..., description="Payment amount in wei")
    token_address: Optional[str] = Field(None, description="ERC20 token address (None for native)")
    tx_hash: Optional[str] = Field(None, description="Blockchain transaction hash")
    status: PaymentStatus = Field(default=PaymentStatus.PENDING)
    payment_type: PaymentType = Field(default=PaymentType.SINGLE)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": "pay_123",
                "sender_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
                "recipient_address": "0x8ba1f109551bD432803012645Ac136ddd64DBA72",
                "amount": "1000000000000000000",
                "token_address": None,
                "tx_hash": "0xabc...",
                "status": "completed",
                "payment_type": "single",
                "created_at": "2025-08-20T10:00:00"
            }
        }


class PaymentCreate(BaseModel):
    """Model for creating a new payment"""
    recipient_address: str
    amount: str
    token_address: Optional[str] = None


class BatchPaymentCreate(BaseModel):
    """Model for creating batch payment"""
    payments: list[PaymentCreate]
    token_address: Optional[str] = None
