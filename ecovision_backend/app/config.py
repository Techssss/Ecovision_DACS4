"""
Application configuration and settings
"""
from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    """Application settings"""
    
    # App
    APP_NAME: str = "EcoVision Backend"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "sqlite:///./ecovision.db"
    )
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # CORS
    CORS_ORIGINS: list[str] = ["*"]
    CORS_CREDENTIALS: bool = True
    CORS_METHODS: list[str] = ["*"]
    CORS_HEADERS: list[str] = ["*"]
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    REDIS_CACHE_TTL: int = 900  # 15 minutes
    
    # File Upload
    UPLOAD_DIR: str = "uploads"
    MAX_UPLOAD_SIZE: int = 5 * 1024 * 1024  # 5MB
    ALLOWED_EXTENSIONS: list[str] = [".jpg", ".jpeg", ".png"]
    
    # AQI
    AQI_API_KEY: Optional[str] = os.getenv("AQI_API_KEY")
    AQI_CACHE_TTL: int = 900  # 15 minutes
    
    # OSRM
    OSRM_URL: str = os.getenv("OSRM_URL", "http://router.project-osrm.org")
    
    # AI/ML
    YOLO_MODEL_PATH: str = "models/yolov8_pollution.pt"
    OPENAI_API_KEY: Optional[str] = os.getenv("OPENAI_API_KEY")
    EMBEDDING_MODEL: str = "text-embedding-3-small"
    
    # Groq API for Chatbot
    GROQ_API_KEY: Optional[str] = os.getenv("GROQ_API_KEY")
    GROQ_MODEL: str = "llama-3.3-70b-versatile"
    GROQ_BASE_URL: str = "https://api.groq.com/openai/v1"
    GROQ_TIMEOUT: int = 30  # seconds
    
    # Firebase Cloud Messaging
    FCM_SERVER_KEY: Optional[str] = os.getenv("FCM_SERVER_KEY")
    
    # Geocoding
    GEOCODING_API_KEY: Optional[str] = os.getenv("GEOCODING_API_KEY")
    
    # Email
    FRONTEND_URL: str = os.getenv("FRONTEND_URL", "http://localhost:3000")
    SMTP_HOST: Optional[str] = os.getenv("SMTP_HOST")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USER: Optional[str] = os.getenv("SMTP_USER")
    SMTP_PASSWORD: Optional[str] = os.getenv("SMTP_PASSWORD")
    FROM_EMAIL: Optional[str] = os.getenv("FROM_EMAIL")
    
    # Cloudinary
    CLOUDINARY_CLOUD_NAME: Optional[str] = os.getenv("CLOUDINARY_CLOUD_NAME")
    CLOUDINARY_API_KEY: Optional[str] = os.getenv("CLOUDINARY_API_KEY")
    CLOUDINARY_API_SECRET: Optional[str] = os.getenv("CLOUDINARY_API_SECRET")
    USE_CLOUDINARY: bool = os.getenv("USE_CLOUDINARY", "false").lower() == "true"
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60
    RATE_LIMIT_PER_HOUR: int = 1000
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

