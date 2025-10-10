"""
Notification data models
"""
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class Notification(BaseModel):
    id: str = Field(..., description="Notification ID")
    user_id: str = Field(..., description="User ID")
    type: str = Field(..., description="Notification type")
    title: str = Field(..., description="Notification title")
    message: str = Field(..., description="Notification message")
    read: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    data: Optional[dict] = None

class NotificationCreate(BaseModel):
    user_id: str
    type: str
    title: str
    message: str
    data: Optional[dict] = None
