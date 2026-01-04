"""
Route routes
"""
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth.dependencies import get_current_user
from app.auth.models import User
from app.routes.schemas import RouteRequest, RouteResponse, RouteCalculationResponse
from app.routes.service import RouteService
from app.utils.response import success_response

router = APIRouter()


@router.post("/calculate", response_model=dict)
async def calculate_routes(
    route_request: RouteRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Calculate routes based on strategy"""
    routes = await RouteService.calculate_routes(
        db,
        route_request.start_latitude,
        route_request.start_longitude,
        route_request.end_latitude,
        route_request.end_longitude,
        route_request.strategy
    )
    
    return success_response(
        data={
            "routes": [RouteResponse.from_orm(r).dict() for r in routes],
            "best_route_id": routes[0].id if routes else None
        }
    )


@router.get("/user", response_model=dict)
async def get_user_routes(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get saved routes for current user"""
    routes = RouteService.get_user_saved_routes(db, current_user.id)
    return success_response(
        data=[RouteResponse.from_orm(r).dict() for r in routes]
    )


@router.post("/{route_id}/save", response_model=dict)
async def save_route(
    route_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Save route for user"""
    user_route = RouteService.save_route_for_user(db, current_user, route_id)
    return success_response(
        message="Route saved successfully"
    )


@router.delete("/{route_id}/save", response_model=dict)
async def delete_saved_route(
    route_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete saved route"""
    deleted = RouteService.delete_saved_route(db, current_user.id, route_id)
    if deleted:
        return success_response(message="Route deleted successfully")
    else:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Saved route")

