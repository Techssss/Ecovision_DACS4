"""
Quick seed script for dashboard data - AQI and Reports
"""
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.auth.models import User
from app.core.security import get_password_hash
from app.aqi.models import AQIStation, AQIReading
from app.reports.models import Report, ReportImage
from datetime import datetime, timedelta
import random
import uuid
import json


def seed_dashboard_data():
    """Seed data for dashboard"""
    db = SessionLocal()
    
    try:
        print("🌱 Seeding Dashboard Data...")
        print("=" * 60)
        
        # 1. Create user if not exists
        user = db.query(User).filter(User.email == "test@ecovision.com").first()
        if not user:
            user = User(
                email="test@ecovision.com",
                password_hash=get_password_hash("test123"),
                name="Test User",
                email_verified_at=datetime.utcnow()
            )
            db.add(user)
            db.flush()
            print("✅ Created test user")
        else:
            print("✅ Using existing test user")
        
        # 2. Create AQI stations and readings
        station = db.query(AQIStation).filter(AQIStation.name == "Trạm Sơn Trà").first()
        if not station:
            station = AQIStation(
                name="Trạm Sơn Trà",
                latitude=16.0544,
                longitude=108.2022,
                address="Đường Hoàng Sa, Quận Sơn Trà, Đà Nẵng",
                city="Đà Nẵng",
                district="Sơn Trà",
                is_active=True
            )
            db.add(station)
            db.flush()
            print("✅ Created AQI station")
        
        # Create readings for last 7 days
        existing_readings = db.query(AQIReading).filter(
            AQIReading.station_id == station.id,
            AQIReading.recorded_at >= datetime.utcnow() - timedelta(days=7)
        ).count()
        
        if existing_readings == 0:
            for i in range(7):
                reading = AQIReading(
                    station_id=station.id,
                    aqi=random.randint(40, 100),
                    pm25=random.uniform(15, 50),
                    pm10=random.uniform(25, 70),
                    temperature=random.uniform(26, 32),
                    humidity=random.uniform(65, 85),
                    recorded_at=datetime.utcnow() - timedelta(days=i)
                )
                db.add(reading)
            print(f"✅ Created 7 AQI readings")
        else:
            print(f"✅ AQI readings already exist ({existing_readings} readings)")
        
        # 3. Create test reports
        report_types = ['air_pollution', 'water_pollution', 'trash', 'dust']
        severities = ['low', 'medium', 'high', 'critical']
        statuses = ['pending', 'reviewing', 'resolved']
        
        existing_reports = db.query(Report).count()
        reports_to_create = max(0, 10 - existing_reports)
        
        if reports_to_create > 0:
            for i in range(reports_to_create):
                report = Report(
                    user_id=user.id,
                    type=random.choice(report_types),
                    description=f"Test report #{i+1} - {random.choice(['Rác thải', 'Ô nhiễm không khí', 'Ô nhiễm nước', 'Khói bụi'])}",
                    latitude=16.0544 + random.uniform(-0.1, 0.1),
                    longitude=108.2022 + random.uniform(-0.1, 0.1),
                    address=f"Đà Nẵng, Vietnam - Test location {i+1}",
                    severity=random.choice(severities),
                    status=random.choice(statuses),
                    tracking_code=f"ECO-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:6].upper()}",
                    created_at=datetime.utcnow() - timedelta(days=random.randint(0, 30))
                )
                db.add(report)
                db.flush()
                
                # Add image with detections
                detections = [
                    {
                        "class": random.randint(0, 2),
                        "class_name": random.choice(['garbage', 'Graffiti', 'sand on road']),
                        "confidence": random.uniform(0.6, 0.95),
                        "bbox": [random.randint(50, 200), random.randint(50, 200), 
                                random.randint(300, 500), random.randint(300, 500)]
                    }
                ]
                
                image = ReportImage(
                    report_id=report.id,
                    image_url="https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=640",
                    thumbnail_url="https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=300",
                    order_index=0,
                    yolo_detections=json.dumps(detections)
                )
                db.add(image)
            
            print(f"✅ Created {reports_to_create} test reports")
        else:
            print(f"✅ Reports already exist ({existing_reports} reports)")
        
        db.commit()
        
        # Show summary
        total_reports = db.query(Report).count()
        pending = db.query(Report).filter(Report.status == 'pending').count()
        resolved = db.query(Report).filter(Report.status == 'resolved').count()
        aqi_readings = db.query(AQIReading).count()
        
        print("\n" + "=" * 60)
        print("📊 Dashboard Data Summary:")
        print(f"   - Total Reports: {total_reports}")
        print(f"   - Pending: {pending}")
        print(f"   - Resolved: {resolved}")
        print(f"   - AQI Readings: {aqi_readings}")
        print("=" * 60)
        print("\n✅ Dashboard data seeded successfully!")
        print("   Refresh admin dashboard to see the data")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    seed_dashboard_data()

