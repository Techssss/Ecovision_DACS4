"""
Script to fix database schema - add missing yolo_detections column
"""
import sqlite3
import os
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

def fix_database():
    """Add yolo_detections column to report_images table if it doesn't exist"""
    # Get database path
    db_path = Path(__file__).parent.parent / "ecovision.db"
    
    if not db_path.exists():
        print(f"❌ Database file not found: {db_path}")
        return False
    
    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        # Check if column exists
        cursor.execute("PRAGMA table_info(report_images)")
        columns = [col[1] for col in cursor.fetchall()]
        
        print(f"Current columns in report_images: {columns}")
        
        if 'yolo_detections' not in columns:
            print("Adding yolo_detections column...")
            cursor.execute("""
                ALTER TABLE report_images 
                ADD COLUMN yolo_detections TEXT
            """)
            conn.commit()
            print("✅ Column yolo_detections added successfully")
        else:
            print("✅ Column yolo_detections already exists")
        
        # Verify
        cursor.execute("PRAGMA table_info(report_images)")
        columns_after = [col[1] for col in cursor.fetchall()]
        print(f"Columns after fix: {columns_after}")
        
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ Error fixing database: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("Fixing database schema...")
    print("=" * 50)
    success = fix_database()
    if success:
        print("\n✅ Database fix completed successfully!")
    else:
        print("\n❌ Database fix failed!")
        sys.exit(1)

