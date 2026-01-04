"""
AQI business logic
"""
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from datetime import datetime, timedelta
from typing import List, Optional
from app.aqi.models import AQIStation, AQIReading
from app.aqi.schemas import AQIStationCreate, AQIReadingCreate
from app.aqi.utils import fetch_aqi_from_external_api, calculate_aqi_category, calculate_aqi_from_pollutants
from app.utils.cache import get_cache, set_cache
from app.utils.geocoding import reverse_geocode
import math


class AQIService:
    """AQI service"""
    
    @staticmethod
    async def get_aqi_by_location(
        db: Session,
        latitude: float,
        longitude: float
    ) -> dict:
        """Get AQI for a specific location"""
        # Check cache first
        cache_key = f"aqi:{latitude}:{longitude}"
        cached = await get_cache(cache_key)
        if cached:
            return cached
        
        # Try to get from nearest station
        station = AQIService._find_nearest_station(db, latitude, longitude)
        
        if station:
            # Get latest reading from station
            reading = db.query(AQIReading).filter(
                AQIReading.station_id == station.id
            ).order_by(AQIReading.recorded_at.desc()).first()
            
            if reading and (datetime.utcnow() - reading.recorded_at).total_seconds() < 3600:
                # Reading is less than 1 hour old
                result = AQIService._format_aqi_response(
                    reading, latitude, longitude, station
                )
                await set_cache(cache_key, result, ttl=900)  # 15 minutes
                return result
        
        # Fallback to external API
        external_data = await fetch_aqi_from_external_api(latitude, longitude)
        if external_data:
            # Get address
            address_data = await reverse_geocode(latitude, longitude)
            
            # Save to database for trend tracking
            await AQIService._save_aqi_reading(
                db, latitude, longitude, external_data, address_data
            )
            
            result = {
                "aqi": external_data.get("aqi", 0),
                "location": {
                    "latitude": latitude,
                    "longitude": longitude,
                    "address": address_data.get("address", "") if address_data else "",
                    "city": address_data.get("city", "") if address_data else ""
                },
                "pollutants": {
                    "pm25": external_data.get("pm25"),
                    "pm10": external_data.get("pm10"),
                    "o3": external_data.get("o3"),
                    "no2": external_data.get("no2")
                },
                "weather": {
                    "temperature": external_data.get("temperature"),
                    "humidity": external_data.get("humidity")
                },
                "quality": calculate_aqi_category(external_data.get("aqi", 0))
            }
            await set_cache(cache_key, result, ttl=900)
            return result
        
        # Default response
        return {
            "aqi": 0,
            "location": {
                "latitude": latitude,
                "longitude": longitude,
                "address": "",
                "city": ""
            },
            "pollutants": {},
            "weather": {},
            "quality": "Unknown"
        }
    
    @staticmethod
    def _find_nearest_station(
        db: Session,
        latitude: float,
        longitude: float,
        max_distance_km: float = 10.0
    ) -> Optional[AQIStation]:
        """Find nearest AQI station"""
        stations = db.query(AQIStation).filter(AQIStation.is_active == True).all()
        
        nearest = None
        min_distance = float('inf')
        
        for station in stations:
            distance = AQIService._calculate_distance(
                latitude, longitude,
                float(station.latitude), float(station.longitude)
            )
            if distance < min_distance and distance <= max_distance_km:
                min_distance = distance
                nearest = station
        
        return nearest
    
    @staticmethod
    def _calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two coordinates in km (Haversine formula)"""
        R = 6371  # Earth radius in km
        
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        
        return R * c
    
    @staticmethod
    def _format_aqi_response(
        reading: AQIReading,
        latitude: float,
        longitude: float,
        station: Optional[AQIStation] = None
    ) -> dict:
        """Format AQI reading as response"""
        return {
            "aqi": reading.aqi,
            "location": {
                "latitude": latitude,
                "longitude": longitude,
                "address": station.address if station else "",
                "city": station.city if station else ""
            },
            "pollutants": {
                "pm25": float(reading.pm25) if reading.pm25 else None,
                "pm10": float(reading.pm10) if reading.pm10 else None,
                "o3": float(reading.o3) if reading.o3 else None,
                "no2": float(reading.no2) if reading.no2 else None,
                "so2": float(reading.so2) if reading.so2 else None,
                "co": float(reading.co) if reading.co else None
            },
            "weather": {
                "temperature": float(reading.temperature) if reading.temperature else None,
                "humidity": float(reading.humidity) if reading.humidity else None,
                "pressure": float(reading.pressure) if reading.pressure else None,
                "wind_speed": float(reading.wind_speed) if reading.wind_speed else None
            },
            "quality": calculate_aqi_category(reading.aqi),
            "station": {
                "id": station.id,
                "name": station.name
            } if station else None
        }
    
    @staticmethod
    def get_aqi_trend(db: Session, days: int = 7) -> List[dict]:
        """Get AQI trend for the last N days"""
        start_date = datetime.utcnow() - timedelta(days=days)
        
        # Group by date and calculate statistics
        results = db.query(
            func.date(AQIReading.recorded_at).label('date'),
            func.avg(AQIReading.aqi).label('avg_aqi'),
            func.max(AQIReading.aqi).label('max_aqi'),
            func.min(AQIReading.aqi).label('min_aqi')
        ).filter(
            AQIReading.recorded_at >= start_date
        ).group_by(
            func.date(AQIReading.recorded_at)
        ).order_by(
            func.date(AQIReading.recorded_at)
        ).all()
        
        return [
            {
                "date": str(result.date),
                "avg_aqi": float(result.avg_aqi),
                "max_aqi": int(result.max_aqi),
                "min_aqi": int(result.min_aqi)
            }
            for result in results
        ]
    
    @staticmethod
    def create_station(db: Session, station_data: AQIStationCreate) -> AQIStation:
        """Create a new AQI station"""
        station = AQIStation(**station_data.dict())
        db.add(station)
        db.commit()
        db.refresh(station)
        return station
    
    @staticmethod
    def create_reading(db: Session, reading_data: AQIReadingCreate) -> AQIReading:
        """Create a new AQI reading"""
        reading = AQIReading(**reading_data.dict())
        db.add(reading)
        db.commit()
        db.refresh(reading)
        return reading
    
    @staticmethod
    async def _save_aqi_reading(
        db: Session,
        latitude: float,
        longitude: float,
        aqi_data: dict,
        address_data: Optional[dict] = None
    ):
        """Save AQI reading to database for trend tracking"""
        try:
            # Find or create station for this location
            station = AQIService._find_nearest_station(db, latitude, longitude, max_distance_km=1.0)
            
            if not station:
                # Create a new station for this location
                city = address_data.get("city", "") if address_data else ""
                district = address_data.get("district", "") if address_data else ""
                address = address_data.get("address", "") if address_data else ""
                
                station = AQIStation(
                    name=f"AQI Station - {city or district or 'Unknown'}",
                    latitude=latitude,
                    longitude=longitude,
                    address=address,
                    city=city,
                    district=district
                )
                db.add(station)
                db.commit()
                db.refresh(station)
            
            # Check if we already have a reading for this hour (avoid duplicates)
            now = datetime.utcnow()
            hour_start = now.replace(minute=0, second=0, microsecond=0)
            
            existing = db.query(AQIReading).filter(
                and_(
                    AQIReading.station_id == station.id,
                    AQIReading.recorded_at >= hour_start,
                    AQIReading.recorded_at < hour_start + timedelta(hours=1)
                )
            ).first()
            
            if existing:
                # Update existing reading
                existing.aqi = aqi_data.get("aqi", 0)
                existing.pm25 = aqi_data.get("pm25")
                existing.pm10 = aqi_data.get("pm10")
                existing.o3 = aqi_data.get("o3")
                existing.no2 = aqi_data.get("no2")
                existing.so2 = aqi_data.get("so2")
                existing.co = aqi_data.get("co")
                existing.temperature = aqi_data.get("temperature")
                existing.humidity = aqi_data.get("humidity")
                existing.recorded_at = now
                db.commit()
            else:
                # Create new reading
                reading = AQIReading(
                    station_id=station.id,
                    aqi=aqi_data.get("aqi", 0),
                    pm25=aqi_data.get("pm25"),
                    pm10=aqi_data.get("pm10"),
                    o3=aqi_data.get("o3"),
                    no2=aqi_data.get("no2"),
                    so2=aqi_data.get("so2"),
                    co=aqi_data.get("co"),
                    temperature=aqi_data.get("temperature"),
                    humidity=aqi_data.get("humidity"),
                    recorded_at=now
                )
                db.add(reading)
                db.commit()
        except Exception as e:
            # Log error but don't fail the request
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Failed to save AQI reading: {e}")
            db.rollback()

