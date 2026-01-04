"""
Email service for sending emails
"""
from typing import Optional
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.config import settings
import logging

logger = logging.getLogger(__name__)


class EmailService:
    """Email service for sending emails"""
    
    @staticmethod
    async def send_password_reset_email(
        email: str,
        reset_token: str,
        frontend_url: Optional[str] = None
    ) -> bool:
        """
        Send password reset email
        
        Args:
            email: Recipient email
            reset_token: Password reset token
            frontend_url: Frontend URL for reset link (optional)
        
        Returns:
            bool: True if email sent successfully, False otherwise
        """
        # Try to send actual email if SMTP is configured
        email_sent = False
        
        # Debug: Check SMTP configuration
        logger.info(f"SMTP Config Check - USER: {bool(settings.SMTP_USER)}, PASSWORD: {bool(settings.SMTP_PASSWORD)}")
        logger.info(f"SMTP_HOST: {settings.SMTP_HOST}, SMTP_PORT: {settings.SMTP_PORT}")
        
        if settings.SMTP_USER and settings.SMTP_PASSWORD:
            try:
                # Get email settings
                smtp_host = settings.SMTP_HOST or "smtp.gmail.com"
                smtp_port = settings.SMTP_PORT
                smtp_user = settings.SMTP_USER
                smtp_password = settings.SMTP_PASSWORD
                from_email = settings.FROM_EMAIL or smtp_user
                
                logger.info(f"Attempting to send email to {email} via {smtp_host}:{smtp_port}")
                
                # Create message
                msg = MIMEMultipart("alternative")
                msg["Subject"] = "Khôi phục mật khẩu - EcoVision"
                msg["From"] = from_email
                msg["To"] = email
                
                # Create reset link
                if frontend_url:
                    reset_link = f"{frontend_url}/reset-password?token={reset_token}"
                else:
                    reset_link = f"Reset token: {reset_token}"
                
                # Email body
                text = f"""
Xin chào,

Bạn đã yêu cầu khôi phục mật khẩu cho tài khoản EcoVision.

Vui lòng click vào link sau để đặt lại mật khẩu:
{reset_link}

Link này có hiệu lực trong 1 giờ.

Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng bỏ qua email này.

Trân trọng,
Đội ngũ EcoVision
"""
                
                html = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #00D9A3 0%, #00B8D4 100%); 
                  color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .button {{ display: inline-block; padding: 12px 30px; background: #00D9A3; 
                  color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Khôi phục mật khẩu</h1>
        </div>
        <div class="content">
            <p>Xin chào,</p>
            <p>Bạn đã yêu cầu khôi phục mật khẩu cho tài khoản EcoVision.</p>
            <p>Vui lòng click vào nút bên dưới để đặt lại mật khẩu:</p>
            <div style="text-align: center;">
                <a href="{reset_link}" class="button">Đặt lại mật khẩu</a>
            </div>
            <p>Hoặc copy link sau vào trình duyệt:</p>
            <p style="word-break: break-all; background: #fff; padding: 10px; border-radius: 5px;">
                {reset_link}
            </p>
            <p><strong>Lưu ý:</strong> Link này có hiệu lực trong 1 giờ.</p>
            <p>Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng bỏ qua email này.</p>
        </div>
        <div class="footer">
            <p>Trân trọng,<br>Đội ngũ EcoVision</p>
        </div>
    </div>
</body>
</html>
"""
                
                # Attach parts
                part1 = MIMEText(text, "plain", "utf-8")
                part2 = MIMEText(html, "html", "utf-8")
                msg.attach(part1)
                msg.attach(part2)
                
                # Send email
                with smtplib.SMTP(smtp_host, smtp_port) as server:
                    server.starttls()
                    server.login(smtp_user, smtp_password)
                    server.send_message(msg)
                
                logger.info(f"Password reset email sent to {email}")
                email_sent = True
                
            except Exception as e:
                logger.error(f"Failed to send email: {e}")
                logger.error(f"Error type: {type(e).__name__}")
                import traceback
                logger.error(f"Traceback: {traceback.format_exc()}")
                print(f"\n❌ EMAIL SEND ERROR:")
                print(f"Error: {e}")
                print(f"Type: {type(e).__name__}")
                email_sent = False
        else:
            logger.warning("SMTP credentials not configured. Email will not be sent.")
            print(f"\n⚠️  SMTP not configured:")
            print(f"SMTP_USER: {bool(settings.SMTP_USER)}")
            print(f"SMTP_PASSWORD: {bool(settings.SMTP_PASSWORD)}")
        
        # If email not sent (no SMTP config or failed), log to console
        if not email_sent:
            logger.info(f"🔐 Password Reset Token for {email}:")
            logger.info(f"Token: {reset_token}")
            if frontend_url:
                reset_link = f"{frontend_url}/reset-password?token={reset_token}"
                logger.info(f"Reset Link: {reset_link}")
            print(f"\n{'='*60}")
            print(f"📧 PASSWORD RESET EMAIL (Development Mode - Email not sent)")
            print(f"{'='*60}")
            print(f"To: {email}")
            print(f"Token: {reset_token}")
            if frontend_url:
                print(f"Reset Link: {frontend_url}/reset-password?token={reset_token}")
            print(f"{'='*60}\n")
        
        return True  # Always return True (email sent or logged to console)

