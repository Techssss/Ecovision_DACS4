"""
Admin dependencies
"""
from typing import Optional
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth.models import User
from app.auth.dependencies import get_current_user, get_optional_user
from app.config import settings

# For development: allow bypassing auth in DEBUG mode
async def get_admin_user(
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_user)
) -> Optional[User]:
    """Get admin user - allows bypass in DEBUG mode"""
    # In DEBUG mode, allow access without authentication
    if settings.DEBUG:
        # Try to get first active user if no token provided
        if current_user is None:
            user = db.query(User).filter(User.is_active == True).first()
            if user:
                return user
            # If no user exists, return None (endpoints will handle it)
            return None
        return current_user
    
    # In production, require authentication
    if current_user is None:
        raise HTTPException(status_code=401, detail="Authentication required")
    
    # TODO: Add admin role check
    # if not current_user.is_admin:
    #     raise HTTPException(status_code=403, detail="Admin access required")
    
    return current_user

