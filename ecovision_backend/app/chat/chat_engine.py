"""
Chat Engine with Groq Integration
Handles prompt engineering and Groq API calls for chatbot
"""
from typing import Dict, Optional, List
from app.config import settings
import httpx
import json
import logging

logger = logging.getLogger(__name__)

# Quick action keywords mapping
QUICK_ACTIONS = {
    'ô nhiễm gần tôi': 'nearby_pollution',
    'hướng dẫn báo cáo': 'report_guide',
    'xem điểm': 'view_points',
    'đổi quà': 'redeem_rewards',
    'điểm của tôi': 'view_points',
    'hạng của tôi': 'view_rank',
    'thống kê': 'view_stats',
}


def detect_quick_action(message: str) -> Optional[str]:
    """
    Detect if message is a quick action
    
    Args:
        message: User message
        
    Returns:
        Quick action type or None
    """
    message_lower = message.lower().strip()
    
    # Check exact matches
    if message_lower in QUICK_ACTIONS:
        return QUICK_ACTIONS[message_lower]
    
    # Check partial matches
    for keyword, action in QUICK_ACTIONS.items():
        if keyword in message_lower:
            return action
    
    return None


def is_greeting_or_general(message: str) -> bool:
    """
    Check if message is a greeting or general question
    
    Args:
        message: User message
        
    Returns:
        True if greeting/general, False if specific question
    """
    message_lower = message.lower().strip()
    
    # First check for specific keywords - these are ALWAYS specific questions
    specific_keywords = [
        'aqi', 'dự báo', 'ô nhiễm', 'báo cáo', 'điểm', 'hạng', 'đổi quà', 'hướng dẫn',
        'hiện tại', 'hiện tại đang', 'bao nhiêu', 'thế nào', 'là gì', 'ở đâu',
        'gần tôi', 'gần đây', 'chất lượng không khí', 'dự báo', 'đang bao nhiêu',
        'hiện tại đang bao nhiêu', 'hiện tại là', 'hiện tại'
    ]
    
    # If contains specific keywords, it's a specific question
    if any(keyword in message_lower for keyword in specific_keywords):
        return False
    
    # Then check for greetings
    greetings = ['xin chào', 'chào', 'hello', 'hi', 'bạn làm được gì', 'bạn là ai', 'giới thiệu', 'bạn có thể làm gì']
    
    # Check if it's a greeting (exact match or very short)
    if any(greeting in message_lower for greeting in greetings):
        return True
    
    # If message is very short (1-2 words), likely greeting
    if len(message_lower.split()) <= 2:
        return True
    
    # Default: treat as specific question (longer messages are usually questions)
    return False


def build_system_prompt(
    quick_action: Optional[str] = None,
    user_context: Optional[Dict] = None,
    user_message: Optional[str] = None
) -> str:
    """
    Build optimized system prompt with better structure
    
    Args:
        quick_action: Type of quick action (if any)
        user_context: User context dictionary
        user_message: User's message for context
        
    Returns:
        System prompt string
    """
    # Check if this is a greeting or specific question
    is_greeting = user_message and is_greeting_or_general(user_message)
    
    # Base identity and role
    base_prompt = """Bạn là EcoBot - trợ lý AI thông minh của ứng dụng EcoVision.

🎯 VAI TRÒ:
- Tư vấn về chất lượng không khí và môi trường
- Hướng dẫn sử dụng ứng dụng EcoVision
- Động viên người dùng bảo vệ môi trường

📋 NGUYÊN TẮC TRẢ LỜI:
1. TRỰC TIẾP: Trả lời ngay câu hỏi, không dài dòng
2. NGẮN GỌN: 2-3 câu, dễ hiểu
3. THÂN THIỆN: Dùng emoji phù hợp 😊 🌱 🌍
4. TIẾNG VIỆT: Luôn trả lời bằng tiếng Việt
5. HÀNH ĐỘNG: Khuyến khích người dùng hành động cụ thể

❌ TUYỆT ĐỐI KHÔNG:
- Lặp lại câu chào "Tôi có thể giúp gì cho bạn?"
- Liệt kê danh sách chức năng khi người dùng hỏi cụ thể
- Trả lời chung chung khi có câu hỏi rõ ràng
- Dài dòng, lan man

"""
    
    # Add specific instruction for non-greeting messages
    if not is_greeting and user_message:
        base_prompt += f"""
⚠️ NGƯỜI DÙNG HỎI CỤ THỂ: "{user_message}"
→ TRẢ LỜI TRỰC TIẾP, KHÔNG GIỚI THIỆU LẠI CHỨC NĂNG

"""
    
    # Add user context to prompt (personalization)
    if user_context:
        user_name = user_context.get('user_name', 'bạn')
        user_points = user_context.get('user_points', 0)
        user_rank = user_context.get('user_rank', 'Người Mới')
        total_reports = user_context.get('total_reports', 0)
        
        context_info = f"""
👤 NGƯỜI DÙNG: {user_name}
📊 THỐNG KÊ:
- Hạng: {user_rank} ({user_points} điểm)
- Đã báo cáo: {total_reports} lần
- Độ chính xác: {user_context.get('accuracy_rate', 0)}%

💡 GỢI Ý: Gọi người dùng là "{user_name}" để thân thiện hơn.
"""
        base_prompt += context_info
        
        # Add current AQI if available
        current_aqi = user_context.get('current_aqi')
        if current_aqi:
            aqi_info = f"""
🌍 CHẤT LƯỢNG KHÔNG KHÍ HIỆN TẠI:
- AQI: {current_aqi.get('aqi')} ({current_aqi.get('status')})
- PM2.5: {current_aqi.get('pm25', 'N/A')} µg/m³
- PM10: {current_aqi.get('pm10', 'N/A')} µg/m³
- Vị trí: {current_aqi.get('location', 'Đà Nẵng')}
- Cập nhật: {current_aqi.get('recorded_at', 'N/A')}

💡 QUAN TRỌNG: Khi người dùng hỏi về AQI, hãy dùng số liệu THẬT này, KHÔNG dùng template!
"""
            base_prompt += aqi_info
    
    # Add context-specific instructions based on quick action
    if quick_action == 'nearby_pollution':
        base_prompt += """
📍 CÂU HỎI VỀ Ô NHIỄM GẦN ĐÂY:
→ Trả lời: "Đang kiểm tra ô nhiễm gần bạn... Bạn có thể xem chi tiết trong phần Bản đồ hoặc báo cáo mới nếu phát hiện ô nhiễm."
"""
    elif quick_action == 'report_guide':
        base_prompt += """
📝 CÂU HỎI VỀ HƯỚNG DẪN BÁO CÁO:
→ Hướng dẫn ngắn gọn: "Để báo cáo: 1) Chụp ảnh rõ ràng 2) Chọn loại ô nhiễm 3) Mô tả chi tiết 4) Gửi. Ảnh rõ sẽ được AI phát hiện và +1 điểm! 🎯"
"""
    elif quick_action == 'view_points':
        if user_context:
            points = user_context.get('user_points', 0)
            rank = user_context.get('user_rank', 'Người Mới')
            base_prompt += f"""
🏆 CÂU HỎI VỀ ĐIỂM:
→ Trả lời: "Bạn đang có {points} điểm, hạng {rank}. Tiếp tục báo cáo để tăng điểm nhé! 💪"
"""
    elif quick_action == 'redeem_rewards':
        base_prompt += """
🎁 CÂU HỎI VỀ ĐỔI QUÀ:
→ Trả lời: "Tính năng đổi quà đang phát triển. Hãy tiếp tục tích điểm để sẵn sàng đổi quà khi ra mắt! 🎉"
"""
    
    # Final instructions
    base_prompt += """
✅ CHECKLIST TRƯỚC KHI TRẢ LỜI:
□ Đã trả lời trực tiếp câu hỏi?
□ Ngắn gọn 2-3 câu?
□ Có emoji phù hợp?
□ Không lặp lại giới thiệu chức năng?
□ Khuyến khích hành động cụ thể?

📌 VÍ DỤ TRẢ LỜI TỐT:
- "AQI hiện tại?" → "AQI đang ở mức 45 (Tốt) 🌱 Bạn có thể hoạt động ngoài trời thoải mái!"
- "Ô nhiễm gần tôi?" → "Đang kiểm tra... Bạn xem trong Bản đồ hoặc báo cáo mới nếu thấy ô nhiễm nhé!"
- "Điểm của tôi?" → "Bạn có {points} điểm, hạng {rank}! Tiếp tục báo cáo để lên hạng 🚀"

❌ VÍ DỤ TRẢ LỜI XẤU:
- "Tôi có thể giúp gì cho bạn?" (Khi người dùng đã hỏi cụ thể)
- "Tôi có thể: ✓ Tư vấn AQI ✓ Gợi ý địa điểm..." (Liệt kê chức năng không cần thiết)
"""
    
    return base_prompt


async def call_groq_api(
    system_prompt: str,
    user_message: str,
    conversation_history: Optional[List[Dict]] = None
) -> Dict:
    """
    Call Groq API with prompt and message
    
    Args:
        system_prompt: System prompt for the conversation
        user_message: User's message
        conversation_history: Optional conversation history
        
    Returns:
        Dictionary with bot response and metadata
    """
    if not settings.GROQ_API_KEY:
        logger.error("GROQ_API_KEY not configured")
        return {
            'bot_message': 'Xin loi, chatbot dang bao tri. Vui long thu lai sau!',
            'suggested_actions': [],
            'error': 'GROQ_API_KEY not configured'
        }
    
    # Build messages array
    messages = [
        {
            'role': 'system',
            'content': system_prompt
        }
    ]
    
    # Add conversation history if available
    if conversation_history:
        for msg in conversation_history[-5:]:  # Last 5 messages for context
            role = 'user' if msg.get('is_user', True) else 'assistant'
            messages.append({
                'role': role,
                'content': msg.get('content', '')
            })
    
    # Add current user message
    messages.append({
        'role': 'user',
        'content': user_message
    })
    
    # Prepare API request
    url = f"{settings.GROQ_BASE_URL}/chat/completions"
    headers = {
        'Authorization': f'Bearer {settings.GROQ_API_KEY}',
        'Content-Type': 'application/json'
    }
    payload = {
        'model': settings.GROQ_MODEL,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 500,  # Limit response length
        'top_p': 0.9,
    }
    
    try:
        async with httpx.AsyncClient(timeout=settings.GROQ_TIMEOUT) as client:
            response = await client.post(url, headers=headers, json=payload)
            response.raise_for_status()
            
            data = response.json()
            
            # Extract bot message
            bot_message = data['choices'][0]['message']['content'].strip()
            
            # Extract suggested actions from response (if any)
            suggested_actions = extract_suggested_actions(bot_message)
            
            return {
                'bot_message': bot_message,
                'suggested_actions': suggested_actions,
                'raw_api_response': data
            }
            
    except httpx.TimeoutException:
        logger.error("Groq API timeout")
        return {
            'bot_message': 'Xin loi, phan hoi hoi cham. Vui long thu lai!',
            'suggested_actions': [],
            'error': 'timeout'
        }
    except httpx.HTTPStatusError as e:
        logger.error(f"Groq API error: {e.response.status_code} - {e.response.text}")
        return {
            'bot_message': 'Xin loi, co loi xay ra. Vui long thu lai sau!',
            'suggested_actions': [],
            'error': f'http_error_{e.response.status_code}'
        }
    except Exception as e:
        logger.error(f"Error calling Groq API: {e}", exc_info=True)
        return {
            'bot_message': 'Xin loi, chatbot dang gap su co. Vui long thu lai sau!',
            'suggested_actions': [],
            'error': str(e)
        }


def filter_welcome_message(message: str, user_message: str) -> str:
    """
    Aggressively filter out welcome messages from bot response
    
    Args:
        message: Bot response message
        user_message: Original user message
        
    Returns:
        Filtered message without welcome content
    """
    if not message:
        return message
    
    # Check if user asked specific question
    is_specific = not is_greeting_or_general(user_message)
    if not is_specific:
        return message  # Don't filter if it's a greeting
    
    welcome_patterns = [
        r'tôi có thể giúp gì cho bạn[?]?',
        r'tôi có thể:?',
        r'hãy thử hỏi tôi về',
        r'bạn có thể hỏi tôi về',
        r'tư vấn chất lượng không khí',
        r'gợi ý địa điểm sạch',
        r'chỉ đường tránh ô nhiễm',
        r'dự báo aqi',
    ]
    
    import re
    cleaned = message
    
    # Remove lines containing welcome patterns
    lines = cleaned.split('\n')
    filtered_lines = []
    for line in lines:
        line_lower = line.lower().strip()
        is_welcome_line = False
        
        for pattern in welcome_patterns:
            if re.search(pattern, line_lower):
                is_welcome_line = True
                break
        
        # Also skip list items (checkmarks, bullets)
        if line_lower.startswith('✓') or line_lower.startswith('-') or line_lower.startswith('*'):
            is_welcome_line = True
        
        if not is_welcome_line:
            filtered_lines.append(line)
    
    cleaned = '\n'.join(filtered_lines).strip()
    
    # Remove welcome phrases from text
    for pattern in welcome_patterns:
        cleaned = re.sub(pattern, '', cleaned, flags=re.IGNORECASE)
    
    # Clean up whitespace
    cleaned = ' '.join(cleaned.split())
    
    return cleaned if cleaned else message


def extract_suggested_actions(message: str) -> List[str]:
    """
    Extract suggested actions from bot message
    Currently returns default actions, can be enhanced with NLP
    
    Args:
        message: Bot message
        
    Returns:
        List of suggested action labels
    """
    # Default suggested actions
    default_actions = [
        'Ô nhiễm gần tôi',
        'Hướng dẫn báo cáo',
        'Xem điểm',
    ]
    
    # Can be enhanced to extract from message content
    # For now, return default actions
    return default_actions


async def get_chatbot_response(
    user_message: str,
    user_context: Optional[Dict] = None,
    conversation_history: Optional[List[Dict]] = None
) -> Dict:
    """
    Main function to get chatbot response
    
    Args:
        user_message: User's message
        user_context: User context dictionary
        conversation_history: Optional conversation history
        
    Returns:
        Dictionary with bot_message, suggested_actions, and metadata
    """
    # Detect quick action
    quick_action = detect_quick_action(user_message)
    
    # Build system prompt (pass user_message to detect if it's greeting)
    system_prompt = build_system_prompt(quick_action, user_context, user_message)
    
    # Check if user asked specific question BEFORE calling Groq
    is_specific_question = not is_greeting_or_general(user_message)
    
    # List of welcome phrases to detect
    welcome_phrases = [
        'tôi có thể giúp gì cho bạn',
        'tôi có thể:',
        'hãy thử hỏi tôi về',
        'bạn có thể hỏi tôi về',
        'tư vấn chất lượng không khí',
        'gợi ý địa điểm sạch',
        'chỉ đường tránh ô nhiễm',
        'dự báo aqi',
        'tôi có thể',
        'bạn có thể',
        'hãy thử'
    ]
    
    # Call Groq API
    result = await call_groq_api(system_prompt, user_message, conversation_history)
    
    # First pass: Filter welcome message immediately
    if result.get('bot_message'):
        result['bot_message'] = filter_welcome_message(result['bot_message'], user_message)
    
    # Post-process: Remove welcome message if it's a specific question (second pass)
    if result.get('bot_message'):
        bot_msg = result['bot_message']
        
        if is_specific_question:
            # Check if response contains welcome message
            bot_msg_lower = bot_msg.lower()
            has_welcome = any(phrase in bot_msg_lower for phrase in welcome_phrases)
            
            if has_welcome:
                logger.warning(f"Bot returned welcome message for specific question: {user_message[:50]}")
                logger.warning(f"Bot response: {bot_msg[:100]}")
                
                # REPLACE ENTIRE RESPONSE with template-based answer
                # Don't try to clean, just replace completely
                user_msg_lower = user_message.lower()
                
                # Generate template response based on question type (WITH PROPER VIETNAMESE DIACRITICS)
                if 'aqi' in user_msg_lower or 'chất lượng không khí' in user_msg_lower:
                    if 'hiện tại' in user_msg_lower or 'đang' in user_msg_lower or 'bao nhiêu' in user_msg_lower:
                        result['bot_message'] = "Tôi đang lấy thông tin AQI hiện tại cho bạn. Bạn có thể xem chi tiết trong phần Trang chủ của ứng dụng."
                    elif 'dự báo' in user_msg_lower or 'dự đoán' in user_msg_lower:
                        result['bot_message'] = "Tôi đang lấy dự báo AQI cho bạn. Dự báo sẽ hiển thị trong phần Trang chủ."
                    else:
                        result['bot_message'] = "Bạn muốn biết thông tin về AQI? Bạn có thể xem trong phần Trang chủ hoặc hỏi cụ thể hơn về vị trí."
                
                elif 'ô nhiễm' in user_msg_lower or 'o nhiem' in user_msg_lower:
                    if 'gần' in user_msg_lower or 'gần tôi' in user_msg_lower or 'gần đây' in user_msg_lower:
                        result['bot_message'] = "Tôi đang tìm kiếm thông tin ô nhiễm gần bạn. Bạn có thể xem trong phần Bản đồ hoặc gửi báo cáo mới."
                    else:
                        result['bot_message'] = "Bạn muốn biết về ô nhiễm? Bạn có thể xem trong phần Bản đồ hoặc gửi báo cáo về ô nhiễm."
                
                elif 'điểm' in user_msg_lower or 'điểm của tôi' in user_msg_lower:
                    points = user_context.get('user_points', 0) if user_context else 0
                    rank = user_context.get('user_rank', 'Người Mới') if user_context else 'Người Mới'
                    result['bot_message'] = f"Hiện tại bạn có {points} điểm và đang ở hạng {rank}. Tiếp tục báo cáo để tăng điểm nhé!"
                
                elif 'hạng' in user_msg_lower or 'rank' in user_msg_lower:
                    rank = user_context.get('user_rank', 'Người Mới') if user_context else 'Người Mới'
                    result['bot_message'] = f"Bạn đang ở hạng {rank}. Tiếp tục báo cáo để lên hạng cao hơn nhé!"
                
                elif 'báo cáo' in user_msg_lower or 'hướng dẫn' in user_msg_lower:
                    result['bot_message'] = "Để báo cáo ô nhiễm: 1) Chụp ảnh, 2) Chọn loại ô nhiễm, 3) Mô tả, 4) Gửi. Ảnh rõ ràng sẽ được +1 điểm khi AI phát hiện được!"
                
                elif 'đổi quà' in user_msg_lower or 'redeem' in user_msg_lower:
                    result['bot_message'] = "Tính năng đổi quà đang phát triển. Tiếp tục tích điểm để sẵn sàng đổi quà khi tính năng ra mắt nhé!"
                
                else:
                    # Generic fallback
                    result['bot_message'] = "Tôi đang xử lý câu hỏi của bạn. Bạn có thể hỏi cụ thể hơn về AQI, ô nhiễm, điểm, hoặc hướng dẫn báo cáo."
                
                logger.info(f"Replaced welcome message with template response: {result['bot_message'][:50]}")
    
    return result

