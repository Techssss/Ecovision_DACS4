"""
Chat message models
"""
from sqlalchemy import Column, String, DateTime, Text, Boolean, JSON, ForeignKey
from sqlalchemy.sql import func
from app.database import Base
import uuid


class Message(Base):
    """Chat message model"""
    __tablename__ = "messages"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    is_user = Column(Boolean, default=True)  # True = user message, False = bot response
    session_id = Column(String(36), nullable=True, index=True)
    message_metadata = Column(JSON, nullable=True)  # Store actions, suggestions, context
    created_at = Column(DateTime, server_default=func.now(), index=True)
    
    def __repr__(self):
        return f"<Message(id={self.id}, is_user={self.is_user})>"

