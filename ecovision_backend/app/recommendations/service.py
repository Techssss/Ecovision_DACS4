"""
Recommendation business logic
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List
from datetime import datetime
from app.recommendations.models import Recommendation
from app.recommendations.engine import RecommendationEngine
from app.auth.models import User


class RecommendationService:
    """Recommendation service"""
    
    @staticmethod
    async def get_user_recommendations(
        db: Session,
        user: User,
        latitude: float = None,
        longitude: float = None,
        limit: int = 10
    ) -> List[Recommendation]:
        """Get recommendations for user"""
        # Get existing unread recommendations
        existing = db.query(Recommendation).filter(
            and_(
                Recommendation.user_id == user.id,
                Recommendation.is_read == False,
                (Recommendation.expires_at.is_(None)) | (Recommendation.expires_at > datetime.utcnow())
            )
        ).order_by(Recommendation.priority.desc(), Recommendation.created_at.desc()).limit(limit).all()
        
        # If we have location, generate new recommendations
        if latitude and longitude and len(existing) < 3:
            new_recommendations = await RecommendationEngine.generate_recommendations(
                db, user, latitude, longitude
            )
            
            # Add new recommendations
            for rec in new_recommendations:
                db.add(rec)
            
            db.commit()
            
            # Refresh and return combined
            for rec in new_recommendations:
                db.refresh(rec)
            
            existing.extend(new_recommendations)
        
        return existing[:limit]
    
    @staticmethod
    def mark_as_read(
        db: Session,
        user_id: str,
        recommendation_id: str
    ) -> bool:
        """Mark recommendation as read"""
        recommendation = db.query(Recommendation).filter(
            Recommendation.id == recommendation_id,
            Recommendation.user_id == user_id
        ).first()
        
        if recommendation:
            recommendation.is_read = True
            db.commit()
            return True
        return False

