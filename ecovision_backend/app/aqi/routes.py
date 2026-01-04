"""
AQI routes
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.aqi.schemas import AQILocationRequest, AQILocationResponse, AQITrendResponse, AQIReadingCreate
from app.aqi.service import AQIService
from app.utils.response import success_response

router = APIRouter()


@router.get("/location", response_model=dict)
async def get_aqi_by_location(
    lat: float = Query(..., description="Latitude"),
    lon: float = Query(..., description="Longitude"),
    db: Session = Depends(get_db)
):
    """Get AQI for a specific location"""
    data = await AQIService.get_aqi_by_location(db, lat, lon)
    return success_response(data=data)


@router.get("/trend", response_model=dict)
async def get_aqi_trend(
    days: int = Query(7, ge=1, le=30, description="Number of days"),
    db: Session = Depends(get_db)
):
    """Get AQI trend for the last N days"""
    data = AQIService.get_aqi_trend(db, days)
    return success_response(data=data)


@router.get("/stations", response_model=dict)
async def get_stations(
    db: Session = Depends(get_db)
):
    """Get all active AQI stations"""
    from app.aqi.models import AQIStation
    stations = db.query(AQIStation).filter(AQIStation.is_active == True).all()
    return success_response(
        data=[{
            "id": s.id,
            "name": s.name,
            "latitude": float(s.latitude),
            "longitude": float(s.longitude),
            "address": s.address,
            "city": s.city
        } for s in stations]
    )


@router.get("/map-data", response_model=dict)
async def get_map_data(
    db: Session = Depends(get_db)
):
    """
    Get AQI data for map visualization
    Returns all active stations with their latest AQI readings
    """
    from app.aqi.models import AQIStation, AQIReading
    from sqlalchemy import func, desc
    from datetime import datetime, timedelta
    
    # Get all active stations
    stations = db.query(AQIStation).filter(AQIStation.is_active == True).all()
    
    map_data = []
    
    for station in stations:
        # Get latest reading for this station (within last 24 hours)
        latest_reading = db.query(AQIReading).filter(
            AQIReading.station_id == station.id,
            AQIReading.recorded_at >= datetime.now() - timedelta(hours=24)
        ).order_by(desc(AQIReading.recorded_at)).first()
        
        # If no recent reading, get the most recent one available
        if not latest_reading:
            latest_reading = db.query(AQIReading).filter(
                AQIReading.station_id == station.id
            ).order_by(desc(AQIReading.recorded_at)).first()
        
        # Calculate average AQI for last 24 hours
        avg_aqi_24h = db.query(func.avg(AQIReading.aqi)).filter(
            AQIReading.station_id == station.id,
            AQIReading.recorded_at >= datetime.now() - timedelta(hours=24)
        ).scalar()
        
        map_data.append({
            "station_id": station.id,
            "name": station.name,
            "latitude": float(station.latitude),
            "longitude": float(station.longitude),
            "address": station.address,
            "city": station.city,
            "current_aqi": int(latest_reading.aqi) if latest_reading else None,
            "avg_aqi_24h": round(float(avg_aqi_24h)) if avg_aqi_24h else None,
            "pm25": float(latest_reading.pm25) if latest_reading and latest_reading.pm25 is not None else None,
            "pm10": float(latest_reading.pm10) if latest_reading and latest_reading.pm10 is not None else None,
            "last_updated": latest_reading.recorded_at.isoformat() if latest_reading else None,
            "status": _get_aqi_status(int(latest_reading.aqi) if latest_reading else None)
        })
    
    return success_response(
        data=map_data,
        message=f"Retrieved {len(map_data)} AQI stations"
    )


def _get_aqi_status(aqi: int) -> dict:
    """Get AQI status with color and description"""
    if aqi is None:
        return {
            "level": "unknown",
            "color": "#999999",
            "description": "Không có dữ liệu"
        }
    elif aqi <= 50:
        return {
            "level": "good",
            "color": "#00E400",
            "description": "Tốt"
        }
    elif aqi <= 100:
        return {
            "level": "moderate",
            "color": "#FFFF00",
            "description": "Trung bình"
        }
    elif aqi <= 150:
        return {
            "level": "unhealthy_sensitive",
            "color": "#FF7E00",
            "description": "Không tốt cho nhóm nhạy cảm"
        }
    elif aqi <= 200:
        return {
            "level": "unhealthy",
            "color": "#FF0000",
            "description": "Không tốt"
        }
    elif aqi <= 300:
        return {
            "level": "very_unhealthy",
            "color": "#8F3F97",
            "description": "Rất không tốt"
        }
    else:
        return {
            "level": "hazardous",
            "color": "#7E0023",
            "description": "Nguy hại"
        }


@router.post("/readings", response_model=dict)
async def create_reading(
    reading_data: AQIReadingCreate,
    db: Session = Depends(get_db)
):
    """Create a new AQI reading"""
    reading = AQIService.create_reading(db, reading_data)
    return success_response(
        data={
            "id": reading.id,
            "station_id": reading.station_id,
            "aqi": reading.aqi,
            "recorded_at": reading.recorded_at.isoformat()
        },
        message="AQI reading saved successfully"
    )
