"""
Seed mock AQI data for demo purposes
Run: python seed_aqi_mock_data.py
"""
import sys
import os
from datetime import datetime, timedelta
import random

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.aqi.models import AQIStation, AQIReading
from sqlalchemy import text

def seed_mock_data():
    """Seed mock AQI stations and readings for Đà Nẵng"""
    db = SessionLocal()
    
    try:
        print("🌱 Starting to seed mock AQI data...")
        
        # Mock stations data for Đà Nẵng
        mock_stations = [
            {
                "name": "Hải Châu",
                "latitude": 16.0544,
                "longitude": 108.2022,
                "address": "Trung tâm Hải Châu",
                "city": "Đà Nẵng",
                "district": "Hải Châu",
                "base_aqi": 42,  # Good
            },
            {
                "name": "Liên Chiểu",
                "latitude": 16.0700,
                "longitude": 108.1500,
                "address": "Khu công nghiệp Liên Chiểu",
                "city": "Đà Nẵng",
                "district": "Liên Chiểu",
                "base_aqi": 85,  # Moderate
            },
            {
                "name": "Thanh Khê",
                "latitude": 16.0600,
                "longitude": 108.1900,
                "address": "Công viên 29/3",
                "city": "Đà Nẵng",
                "district": "Thanh Khê",
                "base_aqi": 38,  # Good
            },
            {
                "name": "Sơn Trà",
                "latitude": 16.0900,
                "longitude": 108.2500,
                "address": "Bán đảo Sơn Trà",
                "city": "Đà Nẵng",
                "district": "Sơn Trà",
                "base_aqi": 125,  # Unhealthy for Sensitive
            },
            {
                "name": "Ngũ Hành Sơn",
                "latitude": 16.0100,
                "longitude": 108.2500,
                "address": "Khu du lịch Ngũ Hành Sơn",
                "city": "Đà Nẵng",
                "district": "Ngũ Hành Sơn",
                "base_aqi": 72,  # Moderate
            },
            {
                "name": "Cẩm Lệ",
                "latitude": 16.0300,
                "longitude": 108.1700,
                "address": "Khu công nghiệp Hòa Khánh",
                "city": "Đà Nẵng",
                "district": "Cẩm Lệ",
                "base_aqi": 165,  # Unhealthy
            },
            {
                "name": "Hòa Vang",
                "latitude": 16.0000,
                "longitude": 108.1000,
                "address": "Huyện Hòa Vang",
                "city": "Đà Nẵng",
                "district": "Hòa Vang",
                "base_aqi": 35,  # Good
            },
            {
                "name": "Cầu Rồng",
                "latitude": 16.0600,
                "longitude": 108.2250,
                "address": "Cầu Rồng - Sông Hàn",
                "city": "Đà Nẵng",
                "district": "Hải Châu",
                "base_aqi": 68,  # Moderate
            },
        ]
        
        # Create or update stations
        for station_data in mock_stations:
            base_aqi = station_data.pop('base_aqi')
            
            # Check if station exists
            existing = db.query(AQIStation).filter(
                AQIStation.name == station_data['name']
            ).first()
            
            if existing:
                print(f"  ✓ Station '{station_data['name']}' already exists, updating...")
                for key, value in station_data.items():
                    setattr(existing, key, value)
                station = existing
            else:
                print(f"  + Creating station '{station_data['name']}'...")
                station = AQIStation(**station_data)
                db.add(station)
                db.flush()  # Get station ID
            
            # Create readings for last 48 hours
            print(f"    → Adding readings for '{station_data['name']}'...")
            now = datetime.now()
            
            # Delete old readings for this station
            db.query(AQIReading).filter(
                AQIReading.station_id == station.id
            ).delete()
            
            # Create readings every 2 hours for last 48 hours
            for hours_ago in range(48, 0, -2):
                recorded_at = now - timedelta(hours=hours_ago)
                
                # Add some random variation to base AQI
                variation = random.randint(-10, 10)
                aqi = max(0, base_aqi + variation)
                
                # Calculate PM2.5 and PM10 from AQI (simplified)
                pm25 = aqi * 0.5 + random.uniform(-5, 5)
                pm10 = aqi * 0.8 + random.uniform(-8, 8)
                
                reading = AQIReading(
                    station_id=station.id,
                    aqi=aqi,
                    pm25=max(0, pm25),
                    pm10=max(0, pm10),
                    recorded_at=recorded_at
                )
                db.add(reading)
            
            print(f"    ✓ Added 24 readings")
        
        db.commit()
        print("\n✅ Mock data seeded successfully!")
        print(f"📊 Created {len(mock_stations)} stations with readings")
        print("\n🗺️ Stations:")
        for station_data in mock_stations:
            print(f"  • {station_data['name']}")
        
    except Exception as e:
        print(f"\n❌ Error seeding data: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_mock_data()
