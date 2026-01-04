"""
Background job to periodically save AQI data
"""
import asyncio
import logging
from datetime import datetime
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.aqi.service import AQIService
from app.aqi.models import AQIStation
from app.aqi.utils import fetch_aqi_from_external_api
from app.utils.geocoding import reverse_geocode

logger = logging.getLogger(__name__)


class AQIBackgroundJob:
    """Background job to save AQI data periodically"""
    
    def __init__(self, interval_minutes: int = 60):
        """
        Initialize background job
        
        Args:
            interval_minutes: Interval in minutes to save AQI data (default: 60 minutes)
        """
        self.interval_minutes = interval_minutes
        self.is_running = False
        self.default_locations = [
            {"lat": 16.0544, "lon": 108.2022, "name": "Đà Nẵng"},  # Da Nang
        ]
    
    async def start(self):
        """Start the background job"""
        if self.is_running:
            logger.warning("AQI background job is already running")
            return
        
        self.is_running = True
        logger.info(f"AQI background job started (interval: {self.interval_minutes} minutes)")
        
        while self.is_running:
            try:
                await self._save_aqi_for_locations()
            except Exception as e:
                logger.error(f"Error in AQI background job: {e}")
            
            # Wait for next interval
            await asyncio.sleep(self.interval_minutes * 60)
    
    def stop(self):
        """Stop the background job"""
        self.is_running = False
        logger.info("AQI background job stopped")
    
    async def _save_aqi_for_locations(self):
        """Save AQI data for default locations"""
        db: Session = SessionLocal()
        try:
            for location in self.default_locations:
                try:
                    lat = location["lat"]
                    lon = location["lon"]
                    
                    logger.info(f"Fetching AQI for {location['name']} ({lat}, {lon})")
                    
                    # Fetch AQI from external API
                    aqi_data = await fetch_aqi_from_external_api(lat, lon)
                    
                    if aqi_data:
                        # Get address
                        address_data = await reverse_geocode(lat, lon)
                        
                        # Save to database
                        await AQIService._save_aqi_reading(
                            db, lat, lon, aqi_data, address_data
                        )
                        
                        logger.info(f"Saved AQI data for {location['name']}: AQI={aqi_data.get('aqi', 0)}")
                    else:
                        logger.warning(f"No AQI data returned for {location['name']}")
                    
                    # Small delay between locations
                    await asyncio.sleep(2)
                    
                except Exception as e:
                    logger.error(f"Error saving AQI for {location['name']}: {e}")
                    continue
                    
        finally:
            db.close()
    
    async def save_aqi_now(self, latitude: float, longitude: float):
        """Manually trigger AQI save for a location"""
        db: Session = SessionLocal()
        try:
            aqi_data = await fetch_aqi_from_external_api(latitude, longitude)
            if aqi_data:
                address_data = await reverse_geocode(latitude, longitude)
                await AQIService._save_aqi_reading(
                    db, latitude, longitude, aqi_data, address_data
                )
                logger.info(f"Manually saved AQI data for ({latitude}, {longitude})")
        finally:
            db.close()


# Global instance
_aqi_background_job: AQIBackgroundJob = None


def get_aqi_background_job() -> AQIBackgroundJob:
    """Get or create AQI background job instance"""
    global _aqi_background_job
    if _aqi_background_job is None:
        _aqi_background_job = AQIBackgroundJob(interval_minutes=60)  # Save every hour
    return _aqi_background_job

