"""
System health check script
"""
import sys
import httpx
from app.database import SessionLocal, engine
from sqlalchemy import text


def check_database():
    """Check database connection"""
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        print("✓ Database: OK")
        return True
    except Exception as e:
        print(f"✗ Database: ERROR - {e}")
        return False


def check_redis():
    """Check Redis connection"""
    try:
        from app.utils.cache import get_redis
        redis = get_redis()
        if redis:
            redis.ping()
            print("✓ Redis: OK")
            return True
        else:
            print("✗ Redis: Not configured")
            return False
    except Exception as e:
        print(f"✗ Redis: ERROR - {e}")
        return False


def check_api():
    """Check API health endpoint"""
    try:
        response = httpx.get("http://localhost:8000/health", timeout=5.0)
        if response.status_code == 200:
            print("✓ API: OK")
            return True
        else:
            print(f"✗ API: ERROR - Status {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ API: ERROR - {e}")
        return False


def main():
    """Run health checks"""
    print("Running health checks...\n")
    
    results = [
        check_database(),
        check_redis(),
        check_api()
    ]
    
    print()
    if all(results):
        print("✓ All systems operational")
        sys.exit(0)
    else:
        print("✗ Some systems are not operational")
        sys.exit(1)


if __name__ == "__main__":
    main()

