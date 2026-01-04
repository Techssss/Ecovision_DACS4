"""
Pydantic schemas for reports
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import json


class ReportBase(BaseModel):
    """Base report schema"""
    type: str = Field(..., description="Type of pollution")
    description: Optional[str] = None
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    address: Optional[str] = None
    severity: str = Field("medium", pattern="^(low|medium|high|critical)$")


class ReportCreate(ReportBase):
    """Schema for creating report"""
    pass


class ReportImageResponse(BaseModel):
    """Schema for report image response"""
    id: str
    image_url: str
    thumbnail_url: Optional[str] = None
    order_index: int
    yolo_detections: Optional[List[dict]] = None
    
    class Config:
        from_attributes = True
    
    @classmethod
    def from_orm(cls, obj):
        """Custom from_orm to parse yolo_detections JSON string"""
        import json
        data = {
            'id': obj.id,
            'image_url': obj.image_url,
            'thumbnail_url': obj.thumbnail_url,
            'order_index': obj.order_index,
            'yolo_detections': None
        }
        
        # Parse yolo_detections if it's a string
        if obj.yolo_detections:
            try:
                if isinstance(obj.yolo_detections, str):
                    data['yolo_detections'] = json.loads(obj.yolo_detections)
                else:
                    data['yolo_detections'] = obj.yolo_detections
            except:
                data['yolo_detections'] = None
        
        return cls(**data)


class ReportResponse(BaseModel):
    """Schema for report response"""
    id: str
    user_id: str
    type: str
    description: Optional[str] = None
    latitude: float
    longitude: float
    address: Optional[str] = None
    severity: str
    status: str
    tracking_code: Optional[str] = None
    images: List[ReportImageResponse] = []
    
    # AI Verification fields
    verification_status: Optional[str] = None
    verification_accuracy: Optional[float] = None
    ai_severity: Optional[str] = None
    points_awarded: int = 0
    ai_feedback: Optional[str] = None
    
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
    
    @classmethod
    def from_orm(cls, obj):
        """Custom from_orm to handle images with yolo_detections"""
        data = {
            'id': obj.id,
            'user_id': obj.user_id,
            'type': obj.type,
            'description': obj.description,
            'latitude': float(obj.latitude),
            'longitude': float(obj.longitude),
            'address': obj.address,
            'severity': obj.severity,
            'status': obj.status,
            'tracking_code': obj.tracking_code,
            'verification_status': obj.verification_status,
            'verification_accuracy': float(obj.verification_accuracy) if obj.verification_accuracy else None,
            'ai_severity': obj.ai_severity,
            'points_awarded': obj.points_awarded or 0,
            'ai_feedback': obj.ai_feedback,
            'created_at': obj.created_at,
            'updated_at': obj.updated_at,
            'images': [ReportImageResponse.from_orm(img) for img in obj.images]
        }
        return cls(**data)


class ReportListResponse(BaseModel):
    """Schema for report list response"""
    reports: List[ReportResponse]
    total: int
    limit: int
    offset: int

