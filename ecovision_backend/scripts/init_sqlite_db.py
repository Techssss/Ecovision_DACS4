"""
Initialize SQLite database with schema
"""
import sqlite3
import os
from pathlib import Path

# Get the database schema file path
BASE_DIR = Path(__file__).resolve().parent.parent
SCHEMA_FILE = BASE_DIR / "database_schema.sql"
DB_FILE = BASE_DIR / "ecovision.db"


def init_database():
    """Initialize SQLite database from schema file"""
    print("Initializing SQLite database...")
    print(f"   Schema file: {SCHEMA_FILE}")
    print(f"   Database file: {DB_FILE}")
    
    # Read schema file
    if not SCHEMA_FILE.exists():
        print(f"❌ Schema file not found: {SCHEMA_FILE}")
        return False
    
    with open(SCHEMA_FILE, 'r', encoding='utf-8') as f:
        schema_sql = f.read()
    
    # Connect to database
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    try:
        # Execute schema
        cursor.executescript(schema_sql)
        conn.commit()
        print("Database initialized successfully!")
        print(f"   Database location: {DB_FILE.absolute()}")
        
        # Show tables
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        print(f"\nCreated {len(tables)} tables:")
        for table in tables:
            print(f"   - {table[0]}")
        
        return True
    except Exception as e:
        print(f"Error initializing database: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()


if __name__ == "__main__":
    init_database()


