"""
User routes
"""
from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth.dependencies import get_current_user
from app.auth.models import User
from app.users.schemas import (
    UserProfileResponse, UserProfileUpdate, UserStatsResponse,
    UserSettingsResponse, UserSettingsUpdate
)
from app.users.service import UserService
from app.utils.response import success_response

router = APIRouter()


@router.get("/profile", response_model=dict)
async def get_profile(
    current_user: User = Depends(get_current_user)
):
    """Get current user profile"""
    return success_response(
        data=UserProfileResponse.from_orm(current_user).dict()
    )


@router.put("/profile", response_model=dict)
async def update_profile(
    profile_data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user profile"""
    user = UserService.update_user_profile(db, current_user, profile_data.dict(exclude_unset=True))
    return success_response(
        data=UserProfileResponse.from_orm(user).dict(),
        message="Profile updated successfully"
    )


@router.post("/avatar", response_model=dict)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload user avatar"""
    user = await UserService.upload_avatar(db, current_user, file)
    return success_response(
        data={"avatar_url": user.avatar_url},
        message="Avatar uploaded successfully"
    )


@router.get("/stats", response_model=dict)
async def get_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user statistics"""
    stats = UserService.get_user_stats(db, current_user.id)
    return success_response(data=stats)


@router.get("/settings", response_model=dict)
async def get_settings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user settings"""
    settings = UserService.get_user_settings(db, current_user.id)
    return success_response(
        data=UserSettingsResponse.from_orm(settings).dict()
    )


@router.put("/settings", response_model=dict)
async def update_settings(
    settings_data: UserSettingsUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user settings"""
    settings = UserService.update_user_settings(
        db, current_user.id, settings_data.dict(exclude_unset=True)
    )
    return success_response(
        data=UserSettingsResponse.from_orm(settings).dict(),
        message="Settings updated successfully"
    )

