"""
OSRM API client for route calculation
"""
from typing import List, Dict, Optional
import httpx
from app.config import settings


class OSRMClient:
    """OSRM routing client"""
    
    def __init__(self):
        self.base_url = settings.OSRM_URL
    
    async def get_route(
        self,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float,
        profile: str = "driving"
    ) -> Optional[Dict]:
        """
        Get route from OSRM
        Returns route with coordinates, distance, duration
        """
        try:
            async with httpx.AsyncClient() as client:
                url = f"{self.base_url}/route/v1/{profile}/{start_lon},{start_lat};{end_lon},{end_lat}"
                params = {
                    "overview": "full",
                    "geometries": "geojson",
                    "steps": "true"
                }
                
                response = await client.get(url, params=params, timeout=10.0)
                if response.status_code == 200:
                    data = response.json()
                    if data.get("code") == "Ok" and data.get("routes"):
                        route = data["routes"][0]
                        geometry = data.get("geometry", {}).get("coordinates", [])
                        
                        return {
                            "coordinates": [[coord[1], coord[0]] for coord in geometry],  # Convert to [lat, lng]
                            "distance": route.get("distance", 0) / 1000,  # Convert to km
                            "duration": route.get("duration", 0) / 60,  # Convert to minutes
                            "legs": route.get("legs", [])
                        }
        except Exception as e:
            print(f"OSRM API error: {e}")
        
        return None
    
    async def get_alternative_routes(
        self,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float,
        alternatives: int = 2
    ) -> List[Dict]:
        """Get alternative routes"""
        try:
            async with httpx.AsyncClient() as client:
                url = f"{self.base_url}/route/v1/driving/{start_lon},{start_lat};{end_lon},{end_lat}"
                params = {
                    "alternatives": alternatives,
                    "overview": "full",
                    "geometries": "geojson"
                }
                
                response = await client.get(url, params=params, timeout=10.0)
                if response.status_code == 200:
                    data = response.json()
                    if data.get("code") == "Ok":
                        routes = []
                        for route in data.get("routes", []):
                            geometry = data.get("geometry", {}).get("coordinates", [])
                            routes.append({
                                "coordinates": [[coord[1], coord[0]] for coord in geometry],
                                "distance": route.get("distance", 0) / 1000,
                                "duration": route.get("duration", 0) / 60
                            })
                        return routes
        except Exception as e:
            print(f"OSRM API error: {e}")
        
        return []


# Global client instance
osrm_client = OSRMClient()

