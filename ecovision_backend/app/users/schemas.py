"""
Pydantic schemas for users
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class UserProfileResponse(BaseModel):
    """Schema for user profile response"""
    id: str
    email: str
    name: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


class UserProfileUpdate(BaseModel):
    """Schema for updating user profile"""
    name: Optional[str] = None
    phone: Optional[str] = None


class UserStatsResponse(BaseModel):
    """Schema for user statistics"""
    total_reports: int
    usage_days: int
    streak: int
    favorite_location: Optional[dict] = None


class UserSettingsResponse(BaseModel):
    """Schema for user settings response"""
    aqi_notifications: bool
    auto_location: bool
    reminder_notifications: bool
    favorite_location_lat: Optional[float] = None
    favorite_location_lon: Optional[float] = None
    favorite_location_name: Optional[str] = None
    language: str
    
    class Config:
        from_attributes = True


class UserSettingsUpdate(BaseModel):
    """Schema for updating user settings"""
    aqi_notifications: Optional[bool] = None
    auto_location: Optional[bool] = None
    reminder_notifications: Optional[bool] = None
    favorite_location_lat: Optional[float] = None
    favorite_location_lon: Optional[float] = None
    favorite_location_name: Optional[str] = None
    language: Optional[str] = None

