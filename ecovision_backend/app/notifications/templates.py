"""
Notification templates
"""
from typing import Dict


class NotificationTemplates:
    """Notification message templates"""
    
    @staticmethod
    def aqi_alert(aqi: int, location: str) -> Dict[str, str]:
        """AQI alert notification"""
        if aqi > 150:
            return {
                "title": "⚠️ High Air Pollution Alert",
                "body": f"Air quality in {location} is unhealthy (AQI: {aqi}). Limit outdoor activities."
            }
        elif aqi > 100:
            return {
                "title": "Air Quality Warning",
                "body": f"Air quality in {location} is moderate (AQI: {aqi}). Sensitive groups should take precautions."
            }
        return {
            "title": "Good Air Quality",
            "body": f"Air quality in {location} is good (AQI: {aqi}). Safe for outdoor activities."
        }
    
    @staticmethod
    def report_response(tracking_code: str) -> Dict[str, str]:
        """Report response notification"""
        return {
            "title": "Report Update",
            "body": f"Your report {tracking_code} has been reviewed and updated."
        }
    
    @staticmethod
    def exercise_reminder() -> Dict[str, str]:
        """Exercise reminder notification"""
        return {
            "title": "Time for Exercise",
            "body": "The air quality is good now. Perfect time for outdoor activities!"
        }

