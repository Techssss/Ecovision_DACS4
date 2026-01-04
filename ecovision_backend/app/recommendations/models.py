"""
Recommendation model
"""
from sqlalchemy import Column, String, DateTime, Text, Integer, Boolean, ForeignKey
from sqlalchemy.sql import func
from app.database import Base
import uuid


class Recommendation(Base):
    """Recommendation model"""
    __tablename__ = "recommendations"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    type = Column(String(50), nullable=False)  # 'exercise', 'weather', 'air_quality', etc.
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    time_range = Column(String(100), nullable=True)  # "6:00 - 8:00 AM"
    icon = Column(String(50), nullable=True)
    icon_color = Column(String(20), nullable=True)
    priority = Column(Integer, default=0)
    is_read = Column(Boolean, default=False)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), index=True)
    
    def __repr__(self):
        return f"<Recommendation(id={self.id}, type={self.type})>"

