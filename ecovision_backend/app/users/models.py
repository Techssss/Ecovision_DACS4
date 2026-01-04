"""
User settings model
"""
from sqlalchemy import Column, String, DateTime, Boolean, Numeric, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from app.database import Base
import uuid


class UserSetting(Base):
    """User settings model"""
    __tablename__ = "user_settings"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), unique=True, nullable=False)
    aqi_notifications = Column(Boolean, default=True)
    auto_location = Column(Boolean, default=True)
    reminder_notifications = Column(Boolean, default=False)
    favorite_location_lat = Column(Numeric(10, 8), nullable=True)
    favorite_location_lon = Column(Numeric(11, 8), nullable=True)
    favorite_location_name = Column(String(255), nullable=True)
    language = Column(String(10), default="vi")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<UserSetting(user_id={self.user_id})>"

