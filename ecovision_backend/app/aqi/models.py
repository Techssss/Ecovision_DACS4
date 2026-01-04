"""
AQI models
"""
from sqlalchemy import Column, String, DateTime, Integer, Numeric, Boolean, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import uuid


class AQIStation(Base):
    """AQI Station model"""
    __tablename__ = "aqi_stations"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    latitude = Column(Numeric(10, 8), nullable=False)
    longitude = Column(Numeric(11, 8), nullable=False)
    address = Column(String(500), nullable=True)
    city = Column(String(100), nullable=True)
    district = Column(String(100), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    readings = relationship("AQIReading", back_populates="station", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<AQIStation(id={self.id}, name={self.name})>"


class AQIReading(Base):
    """AQI Reading model"""
    __tablename__ = "aqi_readings"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    station_id = Column(String(36), ForeignKey("aqi_stations.id"), nullable=False)
    aqi = Column(Integer, nullable=False)
    pm25 = Column(Numeric(6, 2), nullable=True)
    pm10 = Column(Numeric(6, 2), nullable=True)
    o3 = Column(Numeric(6, 2), nullable=True)
    no2 = Column(Numeric(6, 2), nullable=True)
    so2 = Column(Numeric(6, 2), nullable=True)
    co = Column(Numeric(6, 2), nullable=True)
    temperature = Column(Numeric(5, 2), nullable=True)
    humidity = Column(Numeric(5, 2), nullable=True)
    pressure = Column(Numeric(7, 2), nullable=True)
    wind_speed = Column(Numeric(5, 2), nullable=True)
    recorded_at = Column(DateTime, nullable=False, index=True)
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    station = relationship("AQIStation", back_populates="readings")
    
    def __repr__(self):
        return f"<AQIReading(id={self.id}, aqi={self.aqi})>"

