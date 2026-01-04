"""
Pydantic schemas for AQI
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal


class AQIStationBase(BaseModel):
    """Base AQI station schema"""
    name: str
    latitude: float
    longitude: float
    address: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None


class AQIStationCreate(AQIStationBase):
    """Schema for creating AQI station"""
    pass


class AQIStationResponse(AQIStationBase):
    """Schema for AQI station response"""
    id: str
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class AQIReadingBase(BaseModel):
    """Base AQI reading schema"""
    aqi: int = Field(..., ge=0, le=500)
    pm25: Optional[float] = None
    pm10: Optional[float] = None
    o3: Optional[float] = None
    no2: Optional[float] = None
    so2: Optional[float] = None
    co: Optional[float] = None
    temperature: Optional[float] = None
    humidity: Optional[float] = None
    pressure: Optional[float] = None
    wind_speed: Optional[float] = None


class AQIReadingCreate(AQIReadingBase):
    """Schema for creating AQI reading"""
    station_id: str
    recorded_at: datetime


class AQIReadingResponse(AQIReadingBase):
    """Schema for AQI reading response"""
    id: str
    station_id: str
    recorded_at: datetime
    created_at: datetime
    
    class Config:
        from_attributes = True


class AQILocationRequest(BaseModel):
    """Schema for AQI location request"""
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


class AQILocationResponse(BaseModel):
    """Schema for AQI location response"""
    aqi: int
    location: dict
    pollutants: dict
    weather: dict
    quality: str  # "Good", "Moderate", "Unhealthy", etc.
    station: Optional[dict] = None


class AQITrendResponse(BaseModel):
    """Schema for AQI trend response"""
    date: str
    avg_aqi: float
    max_aqi: int
    min_aqi: int

