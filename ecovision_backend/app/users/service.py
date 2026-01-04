"""
User business logic
"""
from sqlalchemy.orm import Session
from sqlalchemy import func, distinct
from datetime import datetime, timedelta
from typing import Optional
from app.auth.models import User
from app.users.models import UserSetting
from app.reports.models import Report
from app.reports.points_service import get_user_stats as get_points_stats
from app.utils.file_handler import save_uploaded_file


class UserService:
    """User service"""
    
    @staticmethod
    def get_user_stats(db: Session, user_id: str) -> dict:
        """Get user statistics including points and verification stats"""
        # Get user object to access total_reports field (which doesn't decrease when admin deletes)
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError(f"User {user_id} not found")
        
        # Get points and verification stats (this uses user.total_reports from database)
        points_stats = get_points_stats(db, user_id)
        
        # Use total_reports from user object (persistent count, doesn't decrease when admin deletes)
        # This ensures total_reports only increases, never decreases
        total_reports = user.total_reports or 0
        
        # Usage days (days with at least one report or activity)
        usage_days = db.query(
            func.count(distinct(func.date(Report.created_at)))
        ).filter(Report.user_id == user_id).scalar() or 0
        
        # Streak (consecutive days with activity)
        # Simplified: count days in last 30 days with activity
        thirty_days_ago = datetime.utcnow() - timedelta(days=30)
        recent_reports = db.query(Report).filter(
            Report.user_id == user_id,
            Report.created_at >= thirty_days_ago
        ).order_by(Report.created_at.desc()).all()
        
        streak = 0
        if recent_reports:
            current_date = datetime.utcnow().date()
            for i in range(30):
                check_date = current_date - timedelta(days=i)
                has_activity = any(
                    report.created_at.date() == check_date
                    for report in recent_reports
                )
                if has_activity:
                    streak += 1
                else:
                    break
        
        # Favorite location from settings
        settings = db.query(UserSetting).filter(UserSetting.user_id == user_id).first()
        favorite_location = None
        if settings and settings.favorite_location_lat:
            favorite_location = {
                "latitude": float(settings.favorite_location_lat),
                "longitude": float(settings.favorite_location_lon),
                "name": settings.favorite_location_name
            }
        
        # Merge points stats with existing stats
        # Override total_reports from points_stats with the persistent count from user object
        return {
            **points_stats,  # Includes: points, rank, verified_reports, accuracy_rate, etc.
            "total_reports": total_reports,  # Use persistent count, not count from database
            "usage_days": usage_days,
            "streak": streak,
            "favorite_location": favorite_location
        }
    
    @staticmethod
    def update_user_profile(
        db: Session,
        user: User,
        profile_data: dict
    ) -> User:
        """Update user profile"""
        if "name" in profile_data:
            user.name = profile_data["name"]
        if "phone" in profile_data:
            user.phone = profile_data["phone"]
        
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    async def upload_avatar(
        db: Session,
        user: User,
        file
    ) -> User:
        """Upload user avatar"""
        file_path = await save_uploaded_file(file, subdirectory="avatars")
        user.avatar_url = f"/uploads/avatars/{file_path}"
        
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    def get_user_settings(db: Session, user_id: str) -> Optional[UserSetting]:
        """Get user settings"""
        settings = db.query(UserSetting).filter(UserSetting.user_id == user_id).first()
        
        if not settings:
            # Create default settings
            settings = UserSetting(user_id=user_id)
            db.add(settings)
            db.commit()
            db.refresh(settings)
        
        return settings
    
    @staticmethod
    def update_user_settings(
        db: Session,
        user_id: str,
        settings_data: dict
    ) -> UserSetting:
        """Update user settings"""
        settings = UserService.get_user_settings(db, user_id)
        
        for key, value in settings_data.items():
            if value is not None and hasattr(settings, key):
                setattr(settings, key, value)
        
        db.commit()
        db.refresh(settings)
        return settings

