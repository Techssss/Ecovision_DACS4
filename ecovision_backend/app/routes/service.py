"""
Route business logic
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from app.routes.models import Route, UserRoute
from app.routes.calculator import RouteCalculator
from app.utils.geocoding import reverse_geocode
from app.auth.models import User


class RouteService:
    """Route service"""
    
    @staticmethod
    async def calculate_routes(
        db: Session,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float,
        strategy: str
    ) -> List[Route]:
        """Calculate and save routes"""
        # Calculate routes
        route_data_list = await RouteCalculator.calculate_routes(
            db, start_lat, start_lon, end_lat, end_lon, strategy
        )
        
        # Get addresses
        start_address_data = await reverse_geocode(start_lat, start_lon)
        end_address_data = await reverse_geocode(end_lat, end_lon)
        
        # Create route records
        routes = []
        for route_data in route_data_list:
            route = Route(
                start_latitude=start_lat,
                start_longitude=start_lon,
                end_latitude=end_lat,
                end_longitude=end_lon,
                start_address=start_address_data.get("address") if start_address_data else None,
                end_address=end_address_data.get("address") if end_address_data else None,
                strategy=strategy,
                avg_aqi=route_data["avg_aqi"],
                max_aqi=route_data["max_aqi"],
                distance_km=route_data["distance"],
                duration_minutes=int(route_data["duration"]),
                coordinates=route_data["coordinates"],
                segment_aqis=route_data.get("segment_aqis"),
                features=route_data.get("features", [])
            )
            db.add(route)
            routes.append(route)
        
        db.commit()
        for route in routes:
            db.refresh(route)
        
        return routes
    
    @staticmethod
    def save_route_for_user(
        db: Session,
        user: User,
        route_id: str
    ) -> UserRoute:
        """Save route for user"""
        # Check if already saved
        existing = db.query(UserRoute).filter(
            UserRoute.user_id == user.id,
            UserRoute.route_id == route_id
        ).first()
        
        if existing:
            return existing
        
        user_route = UserRoute(
            user_id=user.id,
            route_id=route_id
        )
        db.add(user_route)
        db.commit()
        db.refresh(user_route)
        return user_route
    
    @staticmethod
    def get_user_saved_routes(
        db: Session,
        user_id: str
    ) -> List[Route]:
        """Get saved routes for user"""
        user_routes = db.query(UserRoute).filter(
            UserRoute.user_id == user_id
        ).all()
        
        return [ur.route for ur in user_routes]
    
    @staticmethod
    def delete_saved_route(
        db: Session,
        user_id: str,
        route_id: str
    ) -> bool:
        """Delete saved route"""
        user_route = db.query(UserRoute).filter(
            UserRoute.user_id == user_id,
            UserRoute.route_id == route_id
        ).first()
        
        if user_route:
            db.delete(user_route)
            db.commit()
            return True
        return False

