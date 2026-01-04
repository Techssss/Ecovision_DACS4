"""
Pydantic schemas for recommendations
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class RecommendationResponse(BaseModel):
    """Schema for recommendation response"""
    id: str
    type: str
    title: str
    description: Optional[str] = None
    time_range: Optional[str] = None
    icon: Optional[str] = None
    icon_color: Optional[str] = None
    priority: int
    is_read: bool
    expires_at: Optional[datetime] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

