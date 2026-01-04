"""
Route calculation algorithms
"""
from typing import List, Dict, Optional
from app.routes.osrm_client import osrm_client
from app.aqi.service import AQIService
from sqlalchemy.orm import Session


class RouteCalculator:
    """Route calculation service"""
    
    @staticmethod
    async def calculate_routes(
        db: Session,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float,
        strategy: str = "balanced"
    ) -> List[Dict]:
        """
        Calculate routes based on strategy
        Returns list of routes with AQI data
        """
        # Get alternative routes from OSRM
        osrm_routes = await osrm_client.get_alternative_routes(
            start_lat, start_lon, end_lat, end_lon, alternatives=2
        )
        
        if not osrm_routes:
            # Fallback to single route
            single_route = await osrm_client.get_route(start_lat, start_lon, end_lat, end_lon)
            if single_route:
                osrm_routes = [single_route]
        
        # Calculate AQI for each route
        routes_with_aqi = []
        for route in osrm_routes:
            aqi_data = await RouteCalculator._calculate_route_aqi(
                db, route["coordinates"]
            )
            
            route_data = {
                **route,
                "avg_aqi": aqi_data["avg_aqi"],
                "max_aqi": aqi_data["max_aqi"],
                "segment_aqis": aqi_data["segment_aqis"],
                "strategy": strategy
            }
            routes_with_aqi.append(route_data)
        
        # Sort routes based on strategy
        if strategy == "cleanest":
            routes_with_aqi.sort(key=lambda x: x["avg_aqi"])
        elif strategy == "fastest":
            routes_with_aqi.sort(key=lambda x: x["duration"])
        else:  # balanced
            # Score = (avg_aqi * 0.6) + (duration * 0.4)
            for route in routes_with_aqi:
                route["score"] = (route["avg_aqi"] * 0.6) + (route["duration"] * 0.4)
            routes_with_aqi.sort(key=lambda x: x["score"])
        
        return routes_with_aqi
    
    @staticmethod
    async def _calculate_route_aqi(
        db: Session,
        coordinates: List[List[float]]
    ) -> Dict:
        """Calculate AQI for route coordinates"""
        aqis = []
        
        # Sample coordinates (every Nth point to avoid too many API calls)
        sample_rate = max(1, len(coordinates) // 20)  # Sample ~20 points
        
        for i in range(0, len(coordinates), sample_rate):
            lat, lng = coordinates[i]
            aqi_data = await AQIService.get_aqi_by_location(db, lat, lng)
            aqis.append(aqi_data.get("aqi", 0))
        
        if not aqis:
            return {
                "avg_aqi": 0,
                "max_aqi": 0,
                "segment_aqis": []
            }
        
        return {
            "avg_aqi": int(sum(aqis) / len(aqis)),
            "max_aqi": max(aqis),
            "segment_aqis": aqis
        }

