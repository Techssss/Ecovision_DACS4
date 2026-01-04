"""
Seed database with test data
"""
import asyncio
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.auth.models import User
from app.core.security import get_password_hash
from app.aqi.models import AQIStation, AQIReading
from datetime import datetime, timedelta
import random


def seed_users(db: Session):
    """Seed users"""
    users = [
        User(
            email="admin@ecovision.com",
            password_hash=get_password_hash("admin123"),
            name="Admin User",
            email_verified_at=datetime.utcnow()
        ),
        User(
            email="user@ecovision.com",
            password_hash=get_password_hash("user123"),
            name="Test User"
        )
    ]
    
    for user in users:
        existing = db.query(User).filter(User.email == user.email).first()
        if not existing:
            db.add(user)
    
    db.commit()
    print("✓ Seeded users")


def seed_aqi_stations(db: Session):
    """Seed AQI stations"""
    stations = [
        AQIStation(
            name="Trạm Sơn Trà",
            latitude=16.0544,
            longitude=108.2022,
            address="Đường Hoàng Sa, Quận Sơn Trà, Đà Nẵng",
            city="Đà Nẵng",
            district="Sơn Trà",
            is_active=True
        ),
        AQIStation(
            name="Trạm Hải Châu",
            latitude=16.0471,
            longitude=108.2208,
            address="Đường Trần Phú, Quận Hải Châu, Đà Nẵng",
            city="Đà Nẵng",
            district="Hải Châu",
            is_active=True
        )
    ]
    
    for station in stations:
        existing = db.query(AQIStation).filter(AQIStation.name == station.name).first()
        if not existing:
            db.add(station)
    
    db.commit()
    print("✓ Seeded AQI stations")
    
    # Seed readings
    stations = db.query(AQIStation).all()
    for station in stations:
        for i in range(7):  # Last 7 days
            reading = AQIReading(
                station_id=station.id,
                aqi=random.randint(30, 120),
                pm25=random.uniform(10, 60),
                pm10=random.uniform(20, 80),
                temperature=random.uniform(25, 35),
                humidity=random.uniform(60, 90),
                recorded_at=datetime.utcnow() - timedelta(days=i)
            )
            db.add(reading)
    
    db.commit()
    print("✓ Seeded AQI readings")


def main():
    """Main seeding function"""
    db = SessionLocal()
    try:
        print("Seeding database...")
        seed_users(db)
        seed_aqi_stations(db)
        print("✓ Database seeded successfully!")
    except Exception as e:
        print(f"Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    main()

