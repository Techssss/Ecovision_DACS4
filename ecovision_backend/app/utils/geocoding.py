"""
Geocoding utilities (GPS to address conversion)
"""
from typing import Optional
import httpx
from app.config import settings


async def reverse_geocode(latitude: float, longitude: float) -> Optional[dict]:
    """
    Convert GPS coordinates to address using Nominatim (OpenStreetMap)
    """
    try:
        async with httpx.AsyncClient() as client:
            url = "https://nominatim.openstreetmap.org/reverse"
            params = {
                "lat": latitude,
                "lon": longitude,
                "format": "json",
                "addressdetails": 1
            }
            headers = {
                "User-Agent": "EcoVision/1.0"
            }
            
            response = await client.get(url, params=params, headers=headers, timeout=5.0)
            if response.status_code == 200:
                data = response.json()
                address = data.get("address", {})
                
                # Build address string
                address_parts = []
                if address.get("road"):
                    address_parts.append(address["road"])
                if address.get("suburb") or address.get("neighbourhood"):
                    address_parts.append(address.get("suburb") or address.get("neighbourhood"))
                if address.get("city") or address.get("town"):
                    address_parts.append(address.get("city") or address.get("town"))
                if address.get("state"):
                    address_parts.append(address["state"])
                
                return {
                    "address": ", ".join(address_parts) if address_parts else "Unknown location",
                    "city": address.get("city") or address.get("town") or "",
                    "district": address.get("suburb") or address.get("neighbourhood") or "",
                    "country": address.get("country", ""),
                    "full_address": data.get("display_name", "")
                }
    except Exception:
        pass
    
    return None


async def geocode(address: str) -> Optional[dict]:
    """
    Convert address to GPS coordinates
    """
    try:
        async with httpx.AsyncClient() as client:
            url = "https://nominatim.openstreetmap.org/search"
            params = {
                "q": address,
                "format": "json",
                "limit": 1
            }
            headers = {
                "User-Agent": "EcoVision/1.0"
            }
            
            response = await client.get(url, params=params, headers=headers, timeout=5.0)
            if response.status_code == 200:
                data = response.json()
                if data:
                    location = data[0]
                    return {
                        "latitude": float(location["lat"]),
                        "longitude": float(location["lon"]),
                        "address": location.get("display_name", address)
                    }
    except Exception:
        pass
    
    return None

