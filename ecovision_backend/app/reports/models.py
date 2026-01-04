"""
Report models
"""
from sqlalchemy import Column, String, DateTime, Text, Numeric, ForeignKey, Integer, Float, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import uuid


class Report(Base):
    """Report model"""
    __tablename__ = "reports"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    type = Column(String(50), nullable=False)  # 'air_pollution', 'water_pollution', etc.
    description = Column(Text, nullable=True)
    latitude = Column(Numeric(10, 8), nullable=False)
    longitude = Column(Numeric(11, 8), nullable=False)
    address = Column(String(500), nullable=True)
    severity = Column(String(20), default="medium")  # 'low', 'medium', 'high', 'critical'
    status = Column(String(20), default="pending")  # 'pending', 'reviewing', 'resolved', 'rejected'
    tracking_code = Column(String(20), unique=True, nullable=True)
    
    # AI Verification fields
    verification_status = Column(String(30), nullable=True)  # 'verified', 'partially_verified', 'needs_review', 'rejected'
    verification_accuracy = Column(Float, nullable=True)  # 0-100
    ai_severity = Column(String(20), nullable=True)  # 'low', 'medium', 'high', 'critical' - calculated from YOLO
    points_awarded = Column(Integer, default=0)
    ai_feedback = Column(Text, nullable=True)
    needs_admin_review = Column(Boolean, default=False)  # Flag for admin: report needs review (no detections found)
    
    created_at = Column(DateTime, server_default=func.now(), index=True)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    images = relationship("ReportImage", back_populates="report", cascade="all, delete-orphan")
    responses = relationship("ReportResponse", back_populates="report", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Report(id={self.id}, type={self.type})>"


class ReportImage(Base):
    """Report image model"""
    __tablename__ = "report_images"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    report_id = Column(String(36), ForeignKey("reports.id"), nullable=False)
    image_url = Column(String(500), nullable=False)
    thumbnail_url = Column(String(500), nullable=True)
    order_index = Column(Integer, default=0)
    yolo_detections = Column(Text, nullable=True)  # JSON string of detections
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    report = relationship("Report", back_populates="images")
    
    def __repr__(self):
        return f"<ReportImage(id={self.id}, report_id={self.report_id})>"


class ReportResponse(Base):
    """Report response model"""
    __tablename__ = "report_responses"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    report_id = Column(String(36), ForeignKey("reports.id"), nullable=False)
    responder_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    message = Column(Text, nullable=False)
    status = Column(String(20), default="resolved")
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    report = relationship("Report", back_populates="responses")
    
    def __repr__(self):
        return f"<ReportResponse(id={self.id}, report_id={self.report_id})>"

