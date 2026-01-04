"""
Context Loader for Chatbot
Loads user context and nearby pollution data for chatbot prompts
"""
from sqlalchemy.orm import Session
from typing import Dict, Optional, List
from app.auth.models import User
from app.reports.models import Report
from app.users.models import UserSetting
from app.users.service import UserService
from app.reports.points_service import get_user_stats
from app.aqi.models import AQIReading
from sqlalchemy import func, desc
from datetime import datetime, timedelta
import math
import logging

logger = logging.getLogger(__name__)


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate distance between two coordinates in km using Haversine formula
    
    Args:
        lat1, lon1: First point coordinates
        lat2, lon2: Second point coordinates
        
    Returns:
        Distance in kilometers
    """
    R = 6371  # Earth radius in km
    
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c


def get_nearby_pollution_summary(
    db: Session,
    latitude: float,
    longitude: float,
    radius_km: float = 2.0,
    limit: int = 10
) -> Dict:
    """
    Get summary of nearby pollution reports
    
    Args:
        db: Database session
        latitude: User latitude
        longitude: User longitude
        radius_km: Search radius in kilometers
        limit: Maximum number of reports to return
        
    Returns:
        Dictionary with pollution summary
    """
    try:
        # Get all reports
        all_reports = db.query(Report).filter(
            Report.status.in_(['pending', 'reviewing', 'resolved'])
        ).all()
        
        # Filter by distance
        nearby_reports = []
        for report in all_reports:
            distance = calculate_distance(
                latitude, longitude,
                float(report.latitude), float(report.longitude)
            )
            if distance <= radius_km:
                nearby_reports.append({
                    'id': report.id,
                    'type': report.type,
                    'severity': report.severity,
                    'distance_km': round(distance, 2),
                    'address': report.address or 'Không có địa chỉ',
                    'created_at': report.created_at.isoformat() if report.created_at else None
                })
        
        # Sort by distance
        nearby_reports.sort(key=lambda x: x['distance_km'])
        nearby_reports = nearby_reports[:limit]
        
        # Count by type
        type_counts = {}
        for report in nearby_reports:
            report_type = report['type']
            type_counts[report_type] = type_counts.get(report_type, 0) + 1
        
        return {
            'total_nearby': len(nearby_reports),
            'reports': nearby_reports,
            'by_type': type_counts,
            'radius_km': radius_km
        }
    except Exception as e:
        logger.error(f"Error getting nearby pollution: {e}", exc_info=True)
        return {
            'total_nearby': 0,
            'reports': [],
            'by_type': {},
            'radius_km': radius_km
        }


def get_current_aqi(db: Session, latitude: Optional[float] = None, longitude: Optional[float] = None) -> Optional[Dict]:
    """
    Get current AQI data from database
    
    Args:
        db: Database session
        latitude: Optional latitude for location-specific AQI
        longitude: Optional longitude for location-specific AQI
        
    Returns:
        Dictionary with AQI data or None
    """
    try:
        # Get latest AQI reading (within last 24 hours)
        cutoff_time = datetime.now() - timedelta(hours=24)
        
        query = db.query(AQIReading).filter(
            AQIReading.recorded_at >= cutoff_time
        )
        
        # If location provided, try to find nearest station
        # For now, just get the latest reading
        latest_reading = query.order_by(desc(AQIReading.recorded_at)).first()
        
        if latest_reading:
            return {
                'aqi': latest_reading.aqi,
                'pm25': latest_reading.pm25,
                'pm10': latest_reading.pm10,
                'location': latest_reading.location_name or 'Đà Nẵng',
                'recorded_at': latest_reading.recorded_at.isoformat() if latest_reading.recorded_at else None,
                'status': _get_aqi_status(latest_reading.aqi)
            }
        
        return None
    except Exception as e:
        logger.error(f"Error getting current AQI: {e}", exc_info=True)
        return None


def _get_aqi_status(aqi: int) -> str:
    """Get AQI status in Vietnamese"""
    if aqi <= 50:
        return "Tốt"
    elif aqi <= 100:
        return "Trung bình"
    elif aqi <= 150:
        return "Kém"
    elif aqi <= 200:
        return "Xấu"
    elif aqi <= 300:
        return "Rất xấu"
    else:
        return "Nguy hại"


def load_user_context(
    db: Session,
    user: User,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
) -> Dict:
    """
    Load comprehensive user context for chatbot
    
    Args:
        db: Database session
        user: User object
        latitude: Optional user latitude for location-based context
        longitude: Optional user longitude for location-based context
        
    Returns:
        Dictionary with user context including:
        - user_name, user_email
        - user_points, user_rank
        - total_reports, verified_reports
        - favorite_location (if available)
        - nearby_pollution_summary (if location provided)
    """
    context = {
        'user_id': user.id,
        'user_name': user.name or 'Người dùng',
        'user_email': user.email,
        'user_points': user.points or 0,
        'user_rank': user.rank or 'Người Mới',
    }
    
    # Get current AQI
    try:
        aqi_data = get_current_aqi(db, latitude, longitude)
        if aqi_data:
            context['current_aqi'] = aqi_data
    except Exception as e:
        logger.error(f"Error loading AQI: {e}", exc_info=True)
    
    # Get user stats
    try:
        stats = get_user_stats(db, user.id)
        context.update({
            'total_reports': stats.get('total_reports', 0),
            'verified_reports': stats.get('verified_reports', 0),
            'accuracy_rate': stats.get('accuracy_rate', 0.0),
        })
    except Exception as e:
        logger.error(f"Error loading user stats: {e}", exc_info=True)
        context.update({
            'total_reports': 0,
            'verified_reports': 0,
            'accuracy_rate': 0.0,
        })
    
    # Get favorite location from settings
    try:
        settings = db.query(UserSetting).filter(UserSetting.user_id == user.id).first()
        if settings and settings.favorite_location_lat:
            context['favorite_location'] = {
                'name': settings.favorite_location_name or 'Vị trí yêu thích',
                'latitude': float(settings.favorite_location_lat),
                'longitude': float(settings.favorite_location_lon),
            }
    except Exception as e:
        logger.error(f"Error loading user settings: {e}", exc_info=True)
    
    # Get nearby pollution if location provided
    if latitude and longitude:
        try:
            nearby_pollution = get_nearby_pollution_summary(db, latitude, longitude)
            context['nearby_pollution_summary'] = nearby_pollution
        except Exception as e:
            logger.error(f"Error loading nearby pollution: {e}", exc_info=True)
            context['nearby_pollution_summary'] = {
                'total_nearby': 0,
                'reports': [],
                'by_type': {},
            }
    
    return context

