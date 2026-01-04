"""
JWT authentication dependencies
"""
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.database import get_db
from app.core.security import decode_token
from app.auth.models import User
from app.core.exceptions import UnauthorizedError

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user"""
    token = credentials.credentials
    payload = decode_token(token)
    
    if payload is None or payload.get("type") != "access":
        raise UnauthorizedError("Invalid or expired token")
    
    user_id = payload.get("sub")
    if user_id is None:
        raise UnauthorizedError("Invalid token payload")
    
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise UnauthorizedError("User not found")
    
    if not user.is_active:
        raise UnauthorizedError("User is inactive")
    
    return user


async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False)),
    db: Session = Depends(get_db)
) -> Optional[User]:
    """Get current user if authenticated, None otherwise"""
    if credentials is None:
        return None
    
    try:
        return await get_current_user(credentials, db)
    except:
        return None

