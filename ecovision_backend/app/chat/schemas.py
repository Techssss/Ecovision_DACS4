"""
Pydantic schemas for chat
"""
from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import datetime


class MessageRequest(BaseModel):
    """Schema for sending message"""
    content: str
    session_id: Optional[str] = None


class MessageResponse(BaseModel):
    """Schema for message response"""
    id: str
    content: str
    is_user: bool
    session_id: Optional[str] = None
    message_metadata: Optional[Dict] = None  # Match DB column name
    created_at: datetime
    
    class Config:
        from_attributes = True
        # Allow alias for backward compatibility
        populate_by_name = True
        
    @property
    def metadata(self) -> Optional[Dict]:
        """Alias for message_metadata"""
        return self.message_metadata


class ChatHistoryResponse(BaseModel):
    """Schema for chat history response"""
    messages: List[MessageResponse]
    total: int
    limit: int
    offset: int

