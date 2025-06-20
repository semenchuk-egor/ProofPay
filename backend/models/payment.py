from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class Payment(BaseModel):
    payment_id: str
    sender: str
    recipient: str
    amount: float = Field(gt=0)
    attestation_uid: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    status: str = "pending"
    
    class Config:
        json_schema_extra = {
            "example": {
                "payment_id": "0x123...",
                "sender": "0xabc...",
                "recipient": "0xdef...",
                "amount": 0.1,
                "status": "completed"
            }
        }
