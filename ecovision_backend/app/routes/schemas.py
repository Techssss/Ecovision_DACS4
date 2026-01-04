"""
Pydantic schemas for routes
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
from datetime import datetime


class RouteRequest(BaseModel):
    """Schema for route calculation request"""
    start_latitude: float = Field(..., ge=-90, le=90)
    start_longitude: float = Field(..., ge=-180, le=180)
    end_latitude: float = Field(..., ge=-90, le=90)
    end_longitude: float = Field(..., ge=-180, le=180)
    strategy: str = Field(..., pattern="^(cleanest|fastest|balanced)$")


class RouteResponse(BaseModel):
    """Schema for route response"""
    id: str
    start_latitude: float
    start_longitude: float
    end_latitude: float
    end_longitude: float
    start_address: Optional[str] = None
    end_address: Optional[str] = None
    strategy: str
    avg_aqi: int
    max_aqi: int
    distance_km: float
    duration_minutes: int
    coordinates: List[Dict[str, float]]
    segment_aqis: Optional[List[int]] = None
    features: Optional[List[str]] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


class RouteCalculationResponse(BaseModel):
    """Schema for route calculation response"""
    routes: List[RouteResponse]
    best_route_id: str

