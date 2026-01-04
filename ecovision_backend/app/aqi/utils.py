"""
AQI utility functions
"""
from typing import Optional
import httpx
from app.config import settings


async def fetch_aqi_from_external_api(latitude: float, longitude: float) -> Optional[dict]:
    """
    Fetch AQI data from external API (AQICN or similar)
    """
    if not settings.AQI_API_KEY:
        return None
    
    try:
        async with httpx.AsyncClient() as client:
            # Example: AQICN API
            url = f"https://api.waqi.info/feed/geo:{latitude};{longitude}/"
            params = {"token": settings.AQI_API_KEY}
            
            response = await client.get(url, params=params, timeout=10.0)
            if response.status_code == 200:
                data = response.json()
                if data.get("status") == "ok":
                    aqi_data = data.get("data", {})
                    return {
                        "aqi": aqi_data.get("aqi", 0),
                        "pm25": aqi_data.get("iaqi", {}).get("pm25", {}).get("v"),
                        "pm10": aqi_data.get("iaqi", {}).get("pm10", {}).get("v"),
                        "o3": aqi_data.get("iaqi", {}).get("o3", {}).get("v"),
                        "no2": aqi_data.get("iaqi", {}).get("no2", {}).get("v"),
                        "temperature": aqi_data.get("iaqi", {}).get("t", {}).get("v"),
                        "humidity": aqi_data.get("iaqi", {}).get("h", {}).get("v"),
                    }
    except Exception:
        pass
    
    return None


def calculate_aqi_category(aqi: int) -> str:
    """Calculate AQI category"""
    if aqi <= 50:
        return "Good"
    elif aqi <= 100:
        return "Moderate"
    elif aqi <= 150:
        return "Unhealthy for Sensitive Groups"
    elif aqi <= 200:
        return "Unhealthy"
    elif aqi <= 300:
        return "Very Unhealthy"
    else:
        return "Hazardous"


def calculate_aqi_from_pollutants(pm25: float, pm10: float) -> int:
    """
    Calculate AQI from pollutant concentrations
    Simplified calculation - in production, use proper AQI formula
    """
    # This is a simplified version
    # Real AQI calculation is more complex
    if pm25:
        # Convert PM2.5 to AQI (simplified)
        if pm25 <= 12:
            aqi = int((pm25 / 12) * 50)
        elif pm25 <= 35.4:
            aqi = int(50 + ((pm25 - 12) / (35.4 - 12)) * 50)
        elif pm25 <= 55.4:
            aqi = int(100 + ((pm25 - 35.4) / (55.4 - 35.4)) * 50)
        else:
            aqi = int(150 + ((pm25 - 55.4) / (150.4 - 55.4)) * 100)
        return min(aqi, 500)
    
    return 0

