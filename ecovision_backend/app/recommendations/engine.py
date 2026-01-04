"""
Recommendation engine
"""
from typing import List, Dict
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.aqi.service import AQIService
from app.recommendations.models import Recommendation
from app.auth.models import User


class RecommendationEngine:
    """Generate AI recommendations for users"""
    
    @staticmethod
    async def generate_recommendations(
        db: Session,
        user: User,
        latitude: float,
        longitude: float
    ) -> List[Recommendation]:
        """Generate recommendations based on user context"""
        recommendations = []
        
        # Get current AQI
        aqi_data = await AQIService.get_aqi_by_location(db, latitude, longitude)
        aqi = aqi_data.get("aqi", 0)
        quality = aqi_data.get("quality", "Unknown")
        
        # Generate recommendations based on AQI
        if aqi <= 50:
            # Good air quality - recommend outdoor activities
            recommendations.append(Recommendation(
                user_id=user.id,
                type="exercise",
                title="Great time for outdoor exercise",
                description=f"Air quality is {quality.lower()} (AQI: {aqi}). Perfect for outdoor activities!",
                time_range="6:00 - 8:00 AM",
                icon="exercise",
                icon_color="#4CAF50",
                priority=80
            ))
        elif aqi <= 100:
            # Moderate - suggest morning exercise
            recommendations.append(Recommendation(
                user_id=user.id,
                type="exercise",
                title="Best time for outdoor activities",
                description=f"Air quality is {quality.lower()} (AQI: {aqi}). Consider outdoor activities in the morning when AQI is typically lower.",
                time_range="6:00 - 8:00 AM",
                icon="exercise",
                icon_color="#FF9800",
                priority=70
            ))
        else:
            # Unhealthy - recommend indoor activities
            recommendations.append(Recommendation(
                user_id=user.id,
                type="health",
                title="Limit outdoor activities",
                description=f"Air quality is {quality.lower()} (AQI: {aqi}). Consider indoor activities or use a mask if going outside.",
                icon="health",
                icon_color="#F44336",
                priority=90
            ))
        
        # Weather-based recommendations
        weather = aqi_data.get("weather", {})
        temp = weather.get("temperature")
        if temp:
            if temp > 30:
                recommendations.append(Recommendation(
                    user_id=user.id,
                    type="weather",
                    title="Hot weather alert",
                    description=f"Temperature is {temp}°C. Stay hydrated and avoid prolonged sun exposure.",
                    icon="weather",
                    icon_color="#FF5722",
                    priority=60
                ))
        
        # Set expiration (24 hours)
        expires_at = datetime.utcnow() + timedelta(hours=24)
        for rec in recommendations:
            rec.expires_at = expires_at
        
        return recommendations

