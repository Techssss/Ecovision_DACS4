"""
Pydantic schemas for authentication
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema"""
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)


class UserCreate(UserBase):
    """Schema for user registration"""
    password: str = Field(..., min_length=8, max_length=100)
    phone: Optional[str] = None


class UserLogin(BaseModel):
    """Schema for user login"""
    email: EmailStr
    password: str


class UserResponse(UserBase):
    """Schema for user response"""
    id: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    email_verified_at: Optional[datetime] = None
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """Schema for token response"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshTokenRequest(BaseModel):
    """Schema for refresh token request"""
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    """Schema for forgot password request"""
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    """Schema for reset password request"""
    token: str
    new_password: str = Field(..., min_length=8, max_length=100)

