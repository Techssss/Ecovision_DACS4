"""
Chat routes
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth.dependencies import get_current_user
from app.auth.models import User
from app.chat.schemas import MessageRequest, MessageResponse
from app.chat.service import ChatService
from app.utils.response import success_response, paginated_response

router = APIRouter()


@router.post("/message", response_model=dict)
async def send_message(
    message_request: MessageRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Send message and get bot response"""
    user_msg, bot_msg = await ChatService.send_message(
        db, current_user, message_request.content, message_request.session_id
    )
    
    return success_response(
        data={
            "user_message": MessageResponse.from_orm(user_msg).dict(),
            "bot_message": MessageResponse.from_orm(bot_msg).dict()
        }
    )


@router.get("/history", response_model=dict)
async def get_chat_history(
    session_id: str = Query(None, description="Filter by session ID"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get chat history"""
    messages, total = ChatService.get_chat_history(
        db, current_user.id, session_id, limit, offset
    )
    
    return paginated_response(
        data=[MessageResponse.from_orm(m).dict() for m in messages],
        total=total,
        limit=limit,
        offset=offset
    )


@router.delete("/sessions/{session_id}", response_model=dict)
async def delete_session(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete chat session"""
    deleted = ChatService.delete_session(db, current_user.id, session_id)
    if deleted:
        return success_response(message="Session deleted successfully")
    else:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Session")

