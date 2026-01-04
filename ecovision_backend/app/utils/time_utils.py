"""
Time utility functions
"""
from datetime import datetime, timedelta
from typing import Optional


def get_current_time() -> datetime:
    """Get current UTC time"""
    return datetime.utcnow()


def format_datetime(dt: datetime, format_str: str = "%Y-%m-%d %H:%M:%S") -> str:
    """Format datetime to string"""
    return dt.strftime(format_str)


def parse_datetime(date_string: str, format_str: str = "%Y-%m-%d %H:%M:%S") -> Optional[datetime]:
    """Parse string to datetime"""
    try:
        return datetime.strptime(date_string, format_str)
    except ValueError:
        return None


def get_time_range(days: int = 7) -> tuple[datetime, datetime]:
    """Get time range from now to N days ago"""
    end = datetime.utcnow()
    start = end - timedelta(days=days)
    return start, end


def is_within_time_range(dt: datetime, start: datetime, end: datetime) -> bool:
    """Check if datetime is within time range"""
    return start <= dt <= end


def get_hour_of_day(dt: datetime) -> int:
    """Get hour of day (0-23)"""
    return dt.hour


def get_day_of_week(dt: datetime) -> int:
    """Get day of week (0=Monday, 6=Sunday)"""
    return dt.weekday()

