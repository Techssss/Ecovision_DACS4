"""
Authentication routes
"""
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth.schemas import (
    UserCreate, UserLogin, UserResponse, TokenResponse,
    RefreshTokenRequest, ForgotPasswordRequest, ResetPasswordRequest
)
from app.auth.service import AuthService
from app.auth.dependencies import get_current_user
from app.auth.models import User
from app.utils.response import success_response
from app.auth.models import User as UserModel
from app.core.exceptions import UnauthorizedError
from app.config import settings

router = APIRouter()


@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """Register a new user"""
    user = AuthService.register_user(db, user_data)
    
    # Convert datetime to ISO format safely
    created_at_str = user.created_at.isoformat() if user.created_at else None
    
    return success_response(
        data={
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "phone": user.phone,
            "avatar_url": user.avatar_url,
            "is_active": user.is_active,
            "created_at": created_at_str
        },
        message="User registered successfully"
    )


@router.post("/login", response_model=dict)
async def login(
    login_data: UserLogin,
    db: Session = Depends(get_db)
):
    """Login user"""
    user, tokens = AuthService.authenticate_user(db, login_data)
    return success_response(
        data={
            "user": {
                "id": user.id,
                "email": user.email,
                "name": user.name,
                "phone": user.phone,
                "avatar_url": user.avatar_url,
                "is_active": user.is_active,
                "created_at": user.created_at.isoformat()
            },
            "tokens": tokens
        },
        message="Login successful"
    )


@router.post("/refresh", response_model=dict)
async def refresh_token(
    token_data: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """Refresh access token"""
    tokens = AuthService.refresh_access_token(db, token_data.refresh_token)
    return success_response(
        data=tokens,
        message="Token refreshed successfully"
    )


@router.post("/forgot-password", response_model=dict)
async def forgot_password(
    request: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    """Request password reset"""
    try:
        reset_token = AuthService.request_password_reset(db, request.email)
        
        if reset_token:
            # Send email with reset link
            from app.utils.email_service import EmailService
            await EmailService.send_password_reset_email(
                email=request.email,
                reset_token=reset_token,
                frontend_url=settings.FRONTEND_URL
            )
            
            # In development, also return token for testing
            # In production, don't return token in response
            return success_response(
                data={"reset_token": reset_token} if settings.DEBUG else None,
                message="If the email exists, a password reset link has been sent"
            )
        else:
            # Don't reveal if email exists
            return success_response(
                message="If the email exists, a password reset link has been sent"
            )
    except UnauthorizedError as e:
        # Don't reveal if email exists
        return success_response(
            message="If the email exists, a password reset link has been sent"
        )


@router.post("/reset-password", response_model=dict)
async def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    """Reset password with token"""
    try:
        user = AuthService.reset_password(db, request.token, request.new_password)
        return success_response(
            message="Password reset successfully"
        )
    except UnauthorizedError as e:
        from fastapi import HTTPException, status
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get("/me", response_model=dict)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """Get current user information"""
    return success_response(
        data={
            "id": current_user.id,
            "email": current_user.email,
            "name": current_user.name,
            "phone": current_user.phone,
            "avatar_url": current_user.avatar_url,
            "is_active": current_user.is_active,
            "created_at": current_user.created_at.isoformat()
        }
    )

