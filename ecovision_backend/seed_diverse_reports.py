"""
Seed diverse report types for demo
Run: python seed_diverse_reports.py
"""
import sys
import os
from datetime import datetime, timedelta
import random

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.reports.models import Report
from app.auth.models import User

def seed_diverse_reports():
    """Seed reports with different types for demo"""
    db = SessionLocal()
    
    try:
        print("🌱 Starting to seed diverse reports...")
        
        # Get first user (or create demo user)
        user = db.query(User).first()
        if not user:
            print("❌ No users found. Please create a user first.")
            return
        
        print(f"✓ Using user: {user.email}")
        
        # Diverse report types with realistic data
        report_templates = [
            {
                "type": "air_pollution",
                "description": "Khói bụi từ nhà máy gây ô nhiễm không khí nghiêm trọng",
                "severity": "high",
                "latitude": 16.0700,
                "longitude": 108.1500,
                "address": "Khu công nghiệp Liên Chiểu, Đà Nẵng",
            },
            {
                "type": "water_pollution",
                "description": "Nước sông Hàn có màu đen, mùi hôi thối",
                "severity": "critical",
                "latitude": 16.0600,
                "longitude": 108.2250,
                "address": "Sông Hàn, gần Cầu Rồng, Đà Nẵng",
            },
            {
                "type": "noise_pollution",
                "description": "Tiếng ồn từ công trình xây dựng vào ban đêm",
                "severity": "medium",
                "latitude": 16.0544,
                "longitude": 108.2022,
                "address": "Trung tâm Hải Châu, Đà Nẵng",
            },
            {
                "type": "soil_pollution",
                "description": "Đất bị ô nhiễm hóa chất từ nhà máy",
                "severity": "high",
                "latitude": 16.0300,
                "longitude": 108.1700,
                "address": "Khu công nghiệp Hòa Khánh, Cẩm Lệ, Đà Nẵng",
            },
            {
                "type": "industrial_pollution",
                "description": "Khí thải công nghiệp gây ô nhiễm môi trường",
                "severity": "high",
                "latitude": 16.0000,
                "longitude": 108.1000,
                "address": "Khu công nghiệp Hòa Vang, Đà Nẵng",
            },
            {
                "type": "trash",
                "description": "Rác thải tích tụ trên vỉa hè",
                "severity": "medium",
                "latitude": 16.0600,
                "longitude": 108.1900,
                "address": "Thanh Khê, Đà Nẵng",
            },
            {
                "type": "air_pollution",
                "description": "Khói xe cộ gây ô nhiễm không khí",
                "severity": "medium",
                "latitude": 16.0900,
                "longitude": 108.2500,
                "address": "Sơn Trà, Đà Nẵng",
            },
            {
                "type": "water_pollution",
                "description": "Nước thải từ nhà máy xả ra biển",
                "severity": "critical",
                "latitude": 16.0100,
                "longitude": 108.2500,
                "address": "Ngũ Hành Sơn, Đà Nẵng",
            },
        ]
        
        created_count = 0
        for template in report_templates:
            # Create report with varied timestamps
            days_ago = random.randint(0, 30)
            created_at = datetime.now() - timedelta(days=days_ago)
            
            # Random status
            statuses = ['pending', 'reviewing', 'resolved']
            status = random.choice(statuses)
            
            report = Report(
                user_id=user.id,
                type=template['type'],
                description=template['description'],
                latitude=template['latitude'],
                longitude=template['longitude'],
                address=template['address'],
                severity=template['severity'],
                status=status,
                created_at=created_at,
                updated_at=created_at,
            )
            
            db.add(report)
            created_count += 1
            print(f"  + Created {template['type']} report ({status})")
        
        db.commit()
        print(f"\n✅ Successfully created {created_count} diverse reports!")
        print("\n📊 Report types:")
        print("  • Air Pollution: 2")
        print("  • Water Pollution: 2")
        print("  • Noise Pollution: 1")
        print("  • Soil Pollution: 1")
        print("  • Industrial Pollution: 1")
        print("  • Trash: 1")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_diverse_reports()
