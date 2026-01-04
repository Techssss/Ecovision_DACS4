"""
Redis caching utilities
"""
import json
from typing import Any, Optional
from redis import Redis
from app.config import settings

# Initialize Redis client
redis_client: Optional[Redis] = None


def get_redis() -> Optional[Redis]:
    """Get Redis client"""
    global redis_client
    if redis_client is None:
        try:
            redis_client = Redis.from_url(settings.REDIS_URL, decode_responses=True)
        except Exception:
            return None
    return redis_client


async def get_cache(key: str) -> Optional[Any]:
    """Get value from cache"""
    redis = get_redis()
    if redis is None:
        return None
    
    try:
        value = redis.get(key)
        if value:
            return json.loads(value)
        return None
    except Exception:
        return None


async def set_cache(key: str, value: Any, ttl: int = None) -> bool:
    """Set value in cache"""
    redis = get_redis()
    if redis is None:
        return False
    
    try:
        if ttl is None:
            ttl = settings.REDIS_CACHE_TTL
        redis.setex(key, ttl, json.dumps(value))
        return True
    except Exception:
        return False


async def delete_cache(key: str) -> bool:
    """Delete key from cache"""
    redis = get_redis()
    if redis is None:
        return False
    
    try:
        redis.delete(key)
        return True
    except Exception:
        return False


async def clear_cache_pattern(pattern: str) -> int:
    """Clear cache keys matching pattern"""
    redis = get_redis()
    if redis is None:
        return 0
    
    try:
        keys = redis.keys(pattern)
        if keys:
            return redis.delete(*keys)
        return 0
    except Exception:
        return 0

