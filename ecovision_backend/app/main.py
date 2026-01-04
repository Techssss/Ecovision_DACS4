"""
FastAPI application entry point
"""
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from app.config import settings
from app.database import engine, Base
from app.core.exceptions import setup_exception_handlers
from app.core.rate_limiter import RateLimiterMiddleware
import asyncio
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

# Import routers
from app.auth.routes import router as auth_router
from app.aqi.routes import router as aqi_router
from app.reports.routes import router as reports_router
from app.routes.routes import router as routes_router
from app.chat.routes import router as chat_router
from app.recommendations.routes import router as recommendations_router
from app.users.routes import router as users_router
from app.admin.routes import router as admin_router

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

# Setup exception handlers
setup_exception_handlers(app)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=settings.CORS_CREDENTIALS,
    allow_methods=settings.CORS_METHODS,
    allow_headers=settings.CORS_HEADERS,
)

# Trusted host middleware - Disabled for development
# if not settings.DEBUG:
#     app.add_middleware(
#         TrustedHostMiddleware,
#         allowed_hosts=["api.ecovision.com", "*.ecovision.com"]
#     )

# Rate limiting middleware
app.add_middleware(RateLimiterMiddleware)

# Mount static files for uploads
# This allows serving uploaded images at /uploads/* URLs
upload_dir = Path(settings.UPLOAD_DIR)
upload_dir.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(upload_dir)), name="uploads")

# Include routers
app.include_router(auth_router, prefix=f"{settings.API_V1_PREFIX}/auth", tags=["Authentication"])
app.include_router(aqi_router, prefix=f"{settings.API_V1_PREFIX}/aqi", tags=["AQI"])
app.include_router(reports_router, prefix=f"{settings.API_V1_PREFIX}/reports", tags=["Reports"])
app.include_router(routes_router, prefix=f"{settings.API_V1_PREFIX}/routes", tags=["Routes"])
app.include_router(chat_router, prefix=f"{settings.API_V1_PREFIX}/chat", tags=["Chat"])
app.include_router(recommendations_router, prefix=f"{settings.API_V1_PREFIX}/recommendations", tags=["Recommendations"])
app.include_router(users_router, prefix=f"{settings.API_V1_PREFIX}/user", tags=["Users"])
app.include_router(admin_router, prefix=f"{settings.API_V1_PREFIX}/admin", tags=["Admin"])


@app.on_event("startup")
async def startup_event():
    """Initialize database tables and start background jobs"""
    Base.metadata.create_all(bind=engine)
    
    # Start AQI background job to save data periodically
    try:
        from app.aqi.background_job import get_aqi_background_job
        background_job = get_aqi_background_job()
        # Start background job in background task
        asyncio.create_task(background_job.start())
        logger.info("AQI background job started")
    except Exception as e:
        logger.error(f"Failed to start AQI background job: {e}")


@app.on_event("shutdown")
async def shutdown_event():
    """Stop background jobs on shutdown"""
    try:
        from app.aqi.background_job import get_aqi_background_job
        background_job = get_aqi_background_job()
        background_job.stop()
        logger.info("AQI background job stopped")
    except Exception as e:
        logger.error(f"Error stopping AQI background job: {e}")


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "EcoVision Backend API",
        "version": settings.APP_VERSION,
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": settings.APP_VERSION
    }

