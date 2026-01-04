"""
Rate limiting middleware
"""
from fastapi import Request, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
from datetime import datetime, timedelta
from collections import defaultdict
from app.core.exceptions import RateLimitError
from app.config import settings


class RateLimiterMiddleware(BaseHTTPMiddleware):
    """Rate limiting middleware"""
    
    def __init__(self, app: ASGIApp):
        super().__init__(app)
        self.requests = defaultdict(list)
        self.cleanup_interval = timedelta(minutes=1)
        self.last_cleanup = datetime.utcnow()
    
    async def dispatch(self, request: Request, call_next):
        # Skip rate limiting for health check
        if request.url.path in ["/health", "/docs", "/redoc", "/openapi.json"]:
            return await call_next(request)
        
        # Get client identifier
        client_id = request.client.host if request.client else "unknown"
        
        # Cleanup old entries periodically
        if datetime.utcnow() - self.last_cleanup > self.cleanup_interval:
            self._cleanup_old_entries()
            self.last_cleanup = datetime.utcnow()
        
        # Check rate limit
        now = datetime.utcnow()
        minute_ago = now - timedelta(minutes=1)
        hour_ago = now - timedelta(hours=1)
        
        # Filter requests in time windows
        recent_requests = [
            req_time for req_time in self.requests[client_id]
            if req_time > minute_ago
        ]
        hourly_requests = [
            req_time for req_time in self.requests[client_id]
            if req_time > hour_ago
        ]
        
        # Check limits
        if len(recent_requests) >= settings.RATE_LIMIT_PER_MINUTE:
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={
                    "success": False,
                    "error": {
                        "message": "Rate limit exceeded. Too many requests per minute.",
                        "code": "RateLimitError"
                    }
                }
            )
        
        if len(hourly_requests) >= settings.RATE_LIMIT_PER_HOUR:
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={
                    "success": False,
                    "error": {
                        "message": "Rate limit exceeded. Too many requests per hour.",
                        "code": "RateLimitError"
                    }
                }
            )
        
        # Record request
        self.requests[client_id].append(now)
        
        # Process request
        response = await call_next(request)
        return response
    
    def _cleanup_old_entries(self):
        """Remove old entries from rate limit tracking"""
        hour_ago = datetime.utcnow() - timedelta(hours=1)
        for client_id in list(self.requests.keys()):
            self.requests[client_id] = [
                req_time for req_time in self.requests[client_id]
                if req_time > hour_ago
            ]
            if not self.requests[client_id]:
                del self.requests[client_id]

