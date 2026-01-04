"""
Firebase Cloud Messaging client
"""
from typing import Dict, Optional
from app.config import settings
import httpx


class FCMClient:
    """Firebase Cloud Messaging client"""
    
    def __init__(self):
        self.server_key = settings.FCM_SERVER_KEY
        self.api_url = "https://fcm.googleapis.com/fcm/send"
    
    async def send_notification(
        self,
        device_token: str,
        title: str,
        body: str,
        data: Optional[Dict] = None
    ) -> bool:
        """Send FCM notification"""
        if not self.server_key:
            return False
        
        try:
            headers = {
                "Authorization": f"key={self.server_key}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "to": device_token,
                "notification": {
                    "title": title,
                    "body": body
                }
            }
            
            if data:
                payload["data"] = data
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.api_url,
                    json=payload,
                    headers=headers,
                    timeout=10.0
                )
                return response.status_code == 200
        except Exception as e:
            print(f"FCM error: {e}")
            return False


fcm_client = FCMClient()

