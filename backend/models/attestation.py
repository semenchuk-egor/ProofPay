from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class Attestation(BaseModel):
    uid: str
    schema: str
    recipient: str
    attester: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    expiration_time: Optional[int] = None
    revocation_time: Optional[int] = None
    data: bytes = b""
    
    class Config:
        json_schema_extra = {
            "example": {
                "uid": "0x1234...",
                "schema": "0xabcd...",
                "recipient": "0xdef...",
                "attester": "0xghi...",
                "timestamp": "2025-06-01T12:00:00"
            }
        }

class CreateAttestationRequest(BaseModel):
    recipient: str
    amount: float = Field(gt=0)
    description: Optional[str] = ""
    expiration_hours: Optional[int] = 24
