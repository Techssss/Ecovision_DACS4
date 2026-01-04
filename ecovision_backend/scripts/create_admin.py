"""
Create admin user
"""
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.auth.models import User
from app.core.security import get_password_hash
from datetime import datetime
import sys


def create_admin(email: str, password: str, name: str = "Admin"):
    """Create admin user"""
    db = SessionLocal()
    try:
        # Check if admin exists
        existing = db.query(User).filter(User.email == email).first()
        if existing:
            print(f"User with email {email} already exists!")
            return
        
        # Create admin
        admin = User(
            email=email,
            password_hash=get_password_hash(password),
            name=name,
            email_verified_at=datetime.utcnow(),
            is_active=True
        )
        db.add(admin)
        db.commit()
        print(f"✓ Admin user created: {email}")
    except Exception as e:
        print(f"Error creating admin: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python create_admin.py <email> <password> [name]")
        sys.exit(1)
    
    email = sys.argv[1]
    password = sys.argv[2]
    name = sys.argv[3] if len(sys.argv) > 3 else "Admin"
    
    create_admin(email, password, name)

