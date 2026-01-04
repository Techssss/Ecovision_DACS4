"""
Create a test user in the database
"""
import sys
from pathlib import Path

# Add parent directory to path
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

from app.core.security import get_password_hash
from app.database import SessionLocal
from app.auth.models import User
import uuid


def create_test_user(email: str = "test@example.com", password: str = "password123", name: str = "Test User"):
    """Create a test user"""
    db = SessionLocal()
    
    try:
        # Check if user already exists
        existing_user = db.query(User).filter(User.email == email).first()
        if existing_user:
            print(f"⚠️  User already exists: {email}")
            return existing_user
        
        # Create new user
        user = User(
            id=str(uuid.uuid4()),
            email=email,
            password_hash=get_password_hash(password),
            name=name,
            is_active=True
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        
        print(f"✅ Created test user:")
        print(f"   Email: {user.email}")
        print(f"   Name: {user.name}")
        print(f"   Password: {password}")
        print(f"   ID: {user.id}")
        
        return user
    except Exception as e:
        db.rollback()
        print(f"❌ Error creating user: {e}")
        return None
    finally:
        db.close()


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Create a test user")
    parser.add_argument("--email", default="test@example.com", help="User email")
    parser.add_argument("--password", default="password123", help="User password")
    parser.add_argument("--name", default="Test User", help="User name")
    
    args = parser.parse_args()
    
    create_test_user(
        email=args.email,
        password=args.password,
        name=args.name
    )

