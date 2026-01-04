"""
Authentication business logic
"""
from sqlalchemy.orm import Session
from app.auth.models import User
from app.auth.schemas import UserCreate, UserLogin
from app.core.security import verify_password, get_password_hash, create_access_token, create_refresh_token
from app.core.exceptions import UnauthorizedError, ValidationError
from datetime import timedelta
from app.config import settings


class AuthService:
    """Authentication service"""
    
    @staticmethod
    def register_user(db: Session, user_data: UserCreate) -> User:
        """Register a new user"""
        # Check if user already exists
        existing_user = db.query(User).filter(User.email == user_data.email).first()
        if existing_user:
            raise ValidationError("Email already registered")
        
        # Create new user
        user = User(
            email=user_data.email,
            password_hash=get_password_hash(user_data.password),
            name=user_data.name,
            phone=user_data.phone
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    def authenticate_user(db: Session, login_data: UserLogin) -> tuple[User, dict]:
        """Authenticate user and return tokens"""
        user = db.query(User).filter(User.email == login_data.email).first()
        
        if not user or not verify_password(login_data.password, user.password_hash):
            raise UnauthorizedError("Invalid email or password")
        
        if not user.is_active:
            raise UnauthorizedError("User account is inactive")
        
        # Create tokens
        access_token = create_access_token(
            data={"sub": user.id, "email": user.email},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        refresh_token = create_refresh_token(data={"sub": user.id})
        
        tokens = {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        }
        
        return user, tokens
    
    @staticmethod
    def refresh_access_token(db: Session, refresh_token: str) -> dict:
        """Refresh access token using refresh token"""
        from app.core.security import decode_token
        
        payload = decode_token(refresh_token)
        if payload is None or payload.get("type") != "refresh":
            raise UnauthorizedError("Invalid refresh token")
        
        user_id = payload.get("sub")
        user = db.query(User).filter(User.id == user_id).first()
        
        if not user or not user.is_active:
            raise UnauthorizedError("User not found or inactive")
        
        # Create new access token
        access_token = create_access_token(
            data={"sub": user.id, "email": user.email},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        }
    
    @staticmethod
    def request_password_reset(db: Session, email: str) -> str:
        """Request password reset - create reset token"""
        from app.auth.models import PasswordResetToken
        from app.core.security import create_reset_token
        from datetime import datetime, timedelta
        
        user = db.query(User).filter(User.email == email).first()
        if not user:
            # Don't reveal if email exists for security
            return None
        
        if not user.is_active:
            raise UnauthorizedError("User account is inactive")
        
        # Invalidate all previous reset tokens for this user
        db.query(PasswordResetToken).filter(
            PasswordResetToken.user_id == user.id,
            PasswordResetToken.used == False
        ).update({"used": True})
        
        # Create new reset token
        expires_at = datetime.utcnow() + timedelta(hours=1)
        reset_token = create_reset_token(
            data={"sub": user.id, "email": user.email},
            expires_delta=timedelta(hours=1)
        )
        
        # Save token to database
        db_token = PasswordResetToken(
            user_id=user.id,
            token=reset_token,
            expires_at=expires_at
        )
        db.add(db_token)
        db.commit()
        
        return reset_token
    
    @staticmethod
    def reset_password(db: Session, token: str, new_password: str) -> User:
        """Reset password using reset token"""
        from app.auth.models import PasswordResetToken
        from app.core.security import decode_token, get_password_hash
        from datetime import datetime
        
        # Verify token
        payload = decode_token(token)
        if payload is None or payload.get("type") != "reset":
            raise UnauthorizedError("Invalid or expired reset token")
        
        # Check if token exists in database and is not used
        db_token = db.query(PasswordResetToken).filter(
            PasswordResetToken.token == token,
            PasswordResetToken.used == False,
            PasswordResetToken.expires_at > datetime.utcnow()
        ).first()
        
        if not db_token:
            raise UnauthorizedError("Invalid or expired reset token")
        
        # Get user
        user = db.query(User).filter(User.id == db_token.user_id).first()
        if not user or not user.is_active:
            raise UnauthorizedError("User not found or inactive")
        
        # Update password
        user.password_hash = get_password_hash(new_password)
        
        # Mark token as used
        db_token.used = True
        
        db.commit()
        db.refresh(user)
        
        return user

