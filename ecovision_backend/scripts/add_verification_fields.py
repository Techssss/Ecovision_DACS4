"""
Migration script to add verification and points fields to database
Run this script to update existing database schema
"""
import sqlite3
from pathlib import Path
import sys

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.config import settings
from app.database import engine
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def add_verification_fields():
    """Add verification and points fields to database"""
    
    # Get database path from settings
    db_url = settings.DATABASE_URL
    if db_url.startswith('sqlite:///'):
        db_path = db_url.replace('sqlite:///', '')
    else:
        logger.error(f"Unsupported database URL: {db_url}")
        return False
    
    logger.info(f"Connecting to database: {db_path}")
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if columns already exist
        cursor.execute("PRAGMA table_info(reports)")
        report_columns = [col[1] for col in cursor.fetchall()]
        
        cursor.execute("PRAGMA table_info(users)")
        user_columns = [col[1] for col in cursor.fetchall()]
        
        # Add columns to reports table
        reports_additions = []
        
        if 'verification_status' not in report_columns:
            reports_additions.append("ADD COLUMN verification_status TEXT")
        if 'verification_accuracy' not in report_columns:
            reports_additions.append("ADD COLUMN verification_accuracy REAL")
        if 'ai_severity' not in report_columns:
            reports_additions.append("ADD COLUMN ai_severity TEXT")
        if 'points_awarded' not in report_columns:
            reports_additions.append("ADD COLUMN points_awarded INTEGER DEFAULT 0")
        if 'ai_feedback' not in report_columns:
            reports_additions.append("ADD COLUMN ai_feedback TEXT")
        
        if reports_additions:
            for addition in reports_additions:
                try:
                    cursor.execute(f"ALTER TABLE reports {addition}")
                    logger.info(f"✓ Added column to reports: {addition}")
                except sqlite3.OperationalError as e:
                    logger.warning(f"Column might already exist: {e}")
        else:
            logger.info("✓ All report columns already exist")
        
        # Add columns to users table
        users_additions = []
        
        if 'points' not in user_columns:
            users_additions.append("ADD COLUMN points INTEGER DEFAULT 0")
        if 'rank' not in user_columns:
            users_additions.append("ADD COLUMN rank TEXT DEFAULT 'Người Mới'")
        if 'total_reports' not in user_columns:
            users_additions.append("ADD COLUMN total_reports INTEGER DEFAULT 0")
        if 'verified_reports' not in user_columns:
            users_additions.append("ADD COLUMN verified_reports INTEGER DEFAULT 0")
        
        if users_additions:
            for addition in users_additions:
                try:
                    cursor.execute(f"ALTER TABLE users {addition}")
                    logger.info(f"✓ Added column to users: {addition}")
                except sqlite3.OperationalError as e:
                    logger.warning(f"Column might already exist: {e}")
        else:
            logger.info("✓ All user columns already exist")
        
        # Update existing users with default rank
        cursor.execute("UPDATE users SET rank = 'Người Mới' WHERE rank IS NULL")
        cursor.execute("UPDATE users SET points = 0 WHERE points IS NULL")
        cursor.execute("UPDATE users SET total_reports = 0 WHERE total_reports IS NULL")
        cursor.execute("UPDATE users SET verified_reports = 0 WHERE verified_reports IS NULL")
        
        conn.commit()
        logger.info("✅ Database migration completed successfully!")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Error during migration: {e}", exc_info=True)
        if conn:
            conn.rollback()
        return False
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    print("=" * 60)
    print("Database Migration: Adding Verification & Points Fields")
    print("=" * 60)
    
    success = add_verification_fields()
    
    if success:
        print("\n✅ Migration completed!")
        print("   You can now use the verification and points system.")
    else:
        print("\n❌ Migration failed. Please check the logs above.")
        sys.exit(1)

