"""
Route models
"""
from sqlalchemy import Column, String, DateTime, Numeric, Integer, ForeignKey, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import uuid


class Route(Base):
    """Route model"""
    __tablename__ = "routes"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    start_latitude = Column(Numeric(10, 8), nullable=False)
    start_longitude = Column(Numeric(11, 8), nullable=False)
    end_latitude = Column(Numeric(10, 8), nullable=False)
    end_longitude = Column(Numeric(11, 8), nullable=False)
    start_address = Column(String(500), nullable=True)
    end_address = Column(String(500), nullable=True)
    strategy = Column(String(20), nullable=False)  # 'cleanest', 'fastest', 'balanced'
    avg_aqi = Column(Integer, nullable=False)
    max_aqi = Column(Integer, nullable=False)
    distance_km = Column(Numeric(6, 2), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    coordinates = Column(JSON, nullable=False)  # Array of {lat, lng}
    segment_aqis = Column(JSON, nullable=True)  # Array of AQI values per segment
    features = Column(JSON, nullable=True)  # Array of route features
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    user_routes = relationship("UserRoute", back_populates="route", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Route(id={self.id}, strategy={self.strategy})>"


class UserRoute(Base):
    """User saved route model"""
    __tablename__ = "user_routes"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    route_id = Column(String(36), ForeignKey("routes.id"), nullable=False)
    saved_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    route = relationship("Route", back_populates="user_routes")
    
    def __repr__(self):
        return f"<UserRoute(id={self.id}, user_id={self.user_id})>"

