"""
Recommendation routes
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth.dependencies import get_current_user
from app.auth.models import User
from app.recommendations.schemas import RecommendationResponse
from app.recommendations.service import RecommendationService
from app.utils.response import success_response

router = APIRouter()


@router.get("", response_model=dict)
async def get_recommendations(
    lat: float = Query(None, description="Latitude for context"),
    lon: float = Query(None, description="Longitude for context"),
    limit: int = Query(10, ge=1, le=20),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get recommendations for current user"""
    recommendations = await RecommendationService.get_user_recommendations(
        db, current_user, lat, lon, limit
    )
    
    return success_response(
        data=[RecommendationResponse.from_orm(r).dict() for r in recommendations]
    )


@router.put("/{recommendation_id}/read", response_model=dict)
async def mark_recommendation_read(
    recommendation_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark recommendation as read"""
    marked = RecommendationService.mark_as_read(db, current_user.id, recommendation_id)
    if marked:
        return success_response(message="Recommendation marked as read")
    else:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Recommendation")

