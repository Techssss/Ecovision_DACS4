"""
User model for authentication
"""
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import uuid


class User(Base):
    """User model"""
    __tablename__ = "users"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=True)
    avatar_url = Column(String(500), nullable=True)
    email_verified_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # Points and ranking system
    points = Column(Integer, default=0)
    rank = Column(String(50), default="Người Mới")  # 'Người Mới', 'Eco Warrior', 'Guardian', 'Champion', 'Legend'
    total_reports = Column(Integer, default=0)
    verified_reports = Column(Integer, default=0)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    password_reset_tokens = relationship("PasswordResetToken", back_populates="user", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<User(id={self.id}, email={self.email})>"


class PasswordResetToken(Base):
    """Password reset token model"""
    __tablename__ = "password_reset_tokens"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    token = Column(String(500), nullable=False, unique=True, index=True)
    expires_at = Column(DateTime, nullable=False)
    used = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="password_reset_tokens")
    
    def __repr__(self):
        return f"<PasswordResetToken(id={self.id}, user_id={self.user_id}, used={self.used})>"
