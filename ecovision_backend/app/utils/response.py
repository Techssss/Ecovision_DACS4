"""
Standard API response utilities
"""
from typing import Any, Optional


def success_response(
    data: Any = None,
    message: str = "Success",
    status_code: int = 200
) -> dict:
    """Create a standard success response"""
    response = {
        "success": True,
        "message": message
    }
    if data is not None:
        response["data"] = data
    return response


def error_response(
    message: str = "An error occurred",
    code: str = "Error",
    details: Optional[dict] = None
) -> dict:
    """Create a standard error response"""
    response = {
        "success": False,
        "error": {
            "message": message,
            "code": code
        }
    }
    if details:
        response["error"]["details"] = details
    return response


def paginated_response(
    data: list,
    total: int,
    limit: int,
    offset: int,
    message: str = "Success"
) -> dict:
    """Create a paginated response"""
    return {
        "success": True,
        "message": message,
        "data": data,
        "pagination": {
            "total": total,
            "limit": limit,
            "offset": offset,
            "hasMore": offset + limit < total
        }
    }

