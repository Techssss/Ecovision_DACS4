"""
Chat business logic
"""
from sqlalchemy.orm import Session
from typing import List, Optional, Dict
from app.chat.models import Message
from app.chat.chat_engine import get_chatbot_response
from app.auth.models import User
from app.reports.models import Report
from sqlalchemy import func, and_
import uuid
import logging

logger = logging.getLogger(__name__)


class ChatService:
    """Chat service"""
    
    @staticmethod
    async def send_message(
        db: Session,
        user: User,
        content: str,
        session_id: Optional[str] = None
    ) -> tuple[Message, Message]:
        """Send user message and get bot response"""
        # Create or use session ID
        if not session_id:
            session_id = str(uuid.uuid4())
        
        # Save user message
        user_message = Message(
            user_id=user.id,
            content=content,
            is_user=True,
            session_id=session_id
        )
        db.add(user_message)
        db.flush()
        
        # Get conversation history
        history = ChatService._get_conversation_history(db, user.id, session_id)
        
        # Get user context for better responses
        user_context = ChatService._get_user_context(db, user)
        
        # Get bot response using Groq
        try:
            result = await get_chatbot_response(
                user_message=content,
                user_context=user_context,
                conversation_history=history
            )
            
            bot_response_text = result.get('bot_message', 'Xin lỗi, tôi đang gặp sự cố. Vui lòng thử lại!')
            suggested_actions = result.get('suggested_actions', [])
            
        except Exception as e:
            logger.error(f"Error getting chatbot response: {e}", exc_info=True)
            bot_response_text = "Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau!"
            suggested_actions = []
        
        # Save bot response
        bot_message = Message(
            user_id=user.id,
            content=bot_response_text,
            is_user=False,
            session_id=session_id,
            message_metadata={
                "suggested_actions": suggested_actions,
                "user_context_used": bool(user_context)
            }
        )
        db.add(bot_message)
        db.commit()
        
        db.refresh(user_message)
        db.refresh(bot_message)
        
        return user_message, bot_message
    
    @staticmethod
    def _get_user_context(db: Session, user: User) -> Dict:
        """Get user context for personalized responses"""
        try:
            # Get user stats
            total_reports = db.query(func.count(Report.id)).filter(
                Report.user_id == user.id
            ).scalar() or 0
            
            verified_reports = db.query(func.count(Report.id)).filter(
                and_(
                    Report.user_id == user.id,
                    Report.status == 'resolved'
                )
            ).scalar() or 0
            
            # Calculate accuracy rate
            accuracy_rate = (verified_reports / total_reports * 100) if total_reports > 0 else 0
            
            # Get user rank based on points (simple logic)
            user_points = 0  # TODO: Implement points system
            if user_points >= 1000:
                rank = "Kim Cương"
            elif user_points >= 500:
                rank = "Vàng"
            elif user_points >= 200:
                rank = "Bạc"
            elif user_points >= 50:
                rank = "Đồng"
            else:
                rank = "Người Mới"
            
            return {
                'user_name': user.name or 'Bạn',
                'user_points': user_points,
                'user_rank': rank,
                'total_reports': total_reports,
                'verified_reports': verified_reports,
                'accuracy_rate': round(accuracy_rate, 1)
            }
        except Exception as e:
            logger.error(f"Error getting user context: {e}")
            return {
                'user_name': user.name or 'Bạn',
                'user_points': 0,
                'user_rank': 'Người Mới',
                'total_reports': 0,
                'verified_reports': 0,
                'accuracy_rate': 0.0
            }
    
    @staticmethod
    def _get_conversation_history(
        db: Session,
        user_id: str,
        session_id: str,
        limit: int = 5
    ) -> List[dict]:
        """Get conversation history (last 5 messages for context)"""
        messages = db.query(Message).filter(
            Message.user_id == user_id,
            Message.session_id == session_id
        ).order_by(Message.created_at.desc()).limit(limit).all()
        
        return [
            {
                "content": msg.content,
                "is_user": msg.is_user
            }
            for msg in reversed(messages)
        ]
    
    @staticmethod
    def get_chat_history(
        db: Session,
        user_id: str,
        session_id: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> tuple[List[Message], int]:
        """Get chat history for user"""
        query = db.query(Message).filter(Message.user_id == user_id)
        
        if session_id:
            query = query.filter(Message.session_id == session_id)
        
        total = query.count()
        messages = query.order_by(Message.created_at.desc()).offset(offset).limit(limit).all()
        
        return list(reversed(messages)), total
    
    @staticmethod
    def delete_session(
        db: Session,
        user_id: str,
        session_id: str
    ) -> bool:
        """Delete chat session"""
        deleted = db.query(Message).filter(
            Message.user_id == user_id,
            Message.session_id == session_id
        ).delete()
        
        db.commit()
        return deleted > 0

