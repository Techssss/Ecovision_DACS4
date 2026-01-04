"""
Migration script to add needs_admin_review field to reports table
Run this script to update existing database schema
"""
import sqlite3
from pathlib import Path
import sys

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.config import settings
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def add_needs_admin_review_field():
    """Add needs_admin_review field to reports table"""
    
    # Get database path from settings
    db_url = settings.DATABASE_URL
    if db_url.startswith('sqlite:///'):
        db_path = db_url.replace('sqlite:///', '')
    elif db_url.startswith('sqlite://'):
        db_path = db_url.replace('sqlite://', '')
    else:
        logger.error(f"Unsupported database URL: {db_url}")
        logger.info("For PostgreSQL/MySQL, please run SQL manually:")
        logger.info("ALTER TABLE reports ADD COLUMN needs_admin_review BOOLEAN DEFAULT FALSE;")
        return False
    
    logger.info(f"Connecting to database: {db_path}")
    
    conn = None
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if column already exists
        cursor.execute("PRAGMA table_info(reports)")
        report_columns = [col[1] for col in cursor.fetchall()]
        
        if 'needs_admin_review' not in report_columns:
            try:
                cursor.execute("ALTER TABLE reports ADD COLUMN needs_admin_review INTEGER DEFAULT 0")
                logger.info("✓ Added column needs_admin_review to reports table")
                
                # Update existing reports to set default value
                cursor.execute("UPDATE reports SET needs_admin_review = 0 WHERE needs_admin_review IS NULL")
                logger.info("✓ Updated existing reports with default value")
                
                conn.commit()
                logger.info("✅ Database migration completed successfully!")
                return True
            except sqlite3.OperationalError as e:
                logger.warning(f"Column might already exist: {e}")
                return True
        else:
            logger.info("✓ Column needs_admin_review already exists")
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
    print("Database Migration: Adding needs_admin_review Field")
    print("=" * 60)
    
    success = add_needs_admin_review_field()
    
    if success:
        print("\n✅ Migration completed!")
        print("   The needs_admin_review field has been added to reports table.")
    else:
        print("\n❌ Migration failed. Please check the logs above.")
        sys.exit(1)

