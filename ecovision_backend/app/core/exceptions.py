"""
Custom exceptions and exception handlers
"""
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException


class EcoVisionException(Exception):
    """Base exception for EcoVision"""
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class NotFoundError(EcoVisionException):
    """Resource not found"""
    def __init__(self, resource: str = "Resource"):
        super().__init__(f"{resource} not found", status_code=404)


class UnauthorizedError(EcoVisionException):
    """Unauthorized access"""
    def __init__(self, message: str = "Unauthorized"):
        super().__init__(message, status_code=401)


class ForbiddenError(EcoVisionException):
    """Forbidden access"""
    def __init__(self, message: str = "Forbidden"):
        super().__init__(message, status_code=403)


class ValidationError(EcoVisionException):
    """Validation error"""
    def __init__(self, message: str = "Validation error"):
        super().__init__(message, status_code=422)


class RateLimitError(EcoVisionException):
    """Rate limit exceeded"""
    def __init__(self, message: str = "Rate limit exceeded"):
        super().__init__(message, status_code=429)


def setup_exception_handlers(app: FastAPI):
    """Setup exception handlers for the app"""
    
    @app.exception_handler(EcoVisionException)
    async def ecovision_exception_handler(request: Request, exc: EcoVisionException):
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "success": False,
                "error": {
                    "message": exc.message,
                    "code": exc.__class__.__name__
                }
            }
        )
    
    @app.exception_handler(StarletteHTTPException)
    async def http_exception_handler(request: Request, exc: StarletteHTTPException):
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "success": False,
                "error": {
                    "message": exc.detail,
                    "code": "HTTPException"
                }
            }
        )
    
    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Validation error: {exc.errors()}")
        logger.error(f"Request path: {request.url.path}")
        logger.error(f"Request method: {request.method}")
        
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "success": False,
                "error": {
                    "message": "Validation error",
                    "code": "ValidationError",
                    "details": exc.errors()
                }
            }
        )
    
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        from app.config import settings
        import traceback
        
        error_message = "Internal server error"
        error_details = None
        
        if settings.DEBUG:
            error_message = str(exc)
            error_details = traceback.format_exc()
        
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "success": False,
                "error": {
                    "message": error_message,
                    "code": "InternalServerError",
                    "details": error_details
                }
            }
        )

