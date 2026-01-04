"""
Input validation utilities
"""
import re
from typing import Optional


def validate_email(email: str) -> bool:
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def validate_phone(phone: str) -> bool:
    """Validate phone number format (Vietnamese)"""
    # Remove spaces and special characters
    cleaned = re.sub(r'[\s\-\(\)]', '', phone)
    # Check if it's a valid Vietnamese phone number
    pattern = r'^(0|\+84)[3-9]\d{8,9}$'
    return bool(re.match(pattern, cleaned))


def validate_password_strength(password: str) -> tuple[bool, Optional[str]]:
    """Validate password strength"""
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    
    if not re.search(r'\d', password):
        return False, "Password must contain at least one digit"
    
    return True, None


def validate_coordinates(latitude: float, longitude: float) -> bool:
    """Validate GPS coordinates"""
    return -90 <= latitude <= 90 and -180 <= longitude <= 180

