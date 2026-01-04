"""
Script to seed fake AQI data for the last 5 days
"""
import sys
import os
from datetime import datetime, timedelta
import random

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal
from app.aqi.models import AQIStation, AQIReading
from sqlalchemy import func

def seed_aqi_data():
    """Seed fake AQI data for the last 5 days"""
    db = SessionLocal()
    
    try:
        # Find or create a station for Da Nang
        station = db.query(AQIStation).filter(
            AQIStation.latitude == 16.0544,
            AQIStation.longitude == 108.2022
        ).first()
        
        if not station:
            station = AQIStation(
                name="Đà Nẵng - Trung tâm",
                latitude=16.0544,
                longitude=108.2022,
                address="Đà Nẵng, Việt Nam",
                city="Đà Nẵng",
                district="Hải Châu",
                is_active=True
            )
            db.add(station)
            db.commit()
            db.refresh(station)
            print(f"✅ Created station: {station.name}")
        else:
            print(f"✅ Using existing station: {station.name}")
        
        # Generate data for the last 5 days
        now = datetime.utcnow()
        base_aqi = 45  # Base AQI value
        
        total_readings = 0
        
        for day_offset in range(5, 0, -1):  # 5 days ago to yesterday
            target_date = now - timedelta(days=day_offset)
            
            # Create 4 readings per day (every 6 hours)
            for hour_offset in [0, 6, 12, 18]:
                reading_time = target_date.replace(
                    hour=hour_offset,
                    minute=random.randint(0, 59),
                    second=0,
                    microsecond=0
                )
                
                # Check if reading already exists
                existing = db.query(AQIReading).filter(
                    AQIReading.station_id == station.id,
                    func.date(AQIReading.recorded_at) == reading_time.date(),
                    func.extract('hour', AQIReading.recorded_at) == hour_offset
                ).first()
                
                if existing:
                    continue  # Skip if already exists
                
                # Generate AQI with some variation
                # AQI varies between 35-55 (Good to Moderate range)
                aqi = base_aqi + random.randint(-10, 10)
                aqi = max(35, min(55, aqi))  # Clamp between 35-55
                
                # Generate related pollutants based on AQI
                pm25 = round(aqi * 0.6 + random.uniform(-5, 5), 2)
                pm10 = round(aqi * 0.8 + random.uniform(-5, 5), 2)
                o3 = round(30 + random.uniform(-10, 10), 2)
                no2 = round(20 + random.uniform(-5, 5), 2)
                
                # Weather data
                temperature = round(28 + random.uniform(-3, 3), 2)
                humidity = round(70 + random.uniform(-10, 10), 2)
                pressure = round(1013 + random.uniform(-5, 5), 2)
                wind_speed = round(5 + random.uniform(-2, 2), 2)
                
                reading = AQIReading(
                    station_id=station.id,
                    aqi=aqi,
                    pm25=max(0, pm25),
                    pm10=max(0, pm10),
                    o3=max(0, o3),
                    no2=max(0, no2),
                    so2=round(10 + random.uniform(-3, 3), 2),
                    co=round(0.5 + random.uniform(-0.2, 0.2), 2),
                    temperature=temperature,
                    humidity=humidity,
                    pressure=pressure,
                    wind_speed=wind_speed,
                    recorded_at=reading_time
                )
                
                db.add(reading)
                total_readings += 1
        
        db.commit()
        print(f"✅ Created {total_readings} AQI readings for the last 5 days")
        print(f"📊 Station: {station.name}")
        print(f"📍 Location: {station.latitude}, {station.longitude}")
        
        # Show summary
        latest = db.query(AQIReading).filter(
            AQIReading.station_id == station.id
        ).order_by(AQIReading.recorded_at.desc()).first()
        
        if latest:
            print(f"\n📈 Latest reading:")
            print(f"   Date: {latest.recorded_at}")
            print(f"   AQI: {latest.aqi}")
            print(f"   Temperature: {latest.temperature}°C")
            print(f"   Humidity: {latest.humidity}%")
        
    except Exception as e:
        print(f"❌ Error seeding AQI data: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    print("🌱 Seeding AQI data for the last 5 days...")
    seed_aqi_data()
    print("✅ Done!")

