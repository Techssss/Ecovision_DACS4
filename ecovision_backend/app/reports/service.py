"""
Report business logic
"""
from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List, Optional
from datetime import datetime
from app.reports.models import Report, ReportImage, ReportResponse
from app.reports.schemas import ReportCreate
from app.auth.models import User
from app.utils.geocoding import reverse_geocode
import uuid
import json


class ReportService:
    """Report service"""
    
    @staticmethod
    def create_report(
        db: Session,
        user: User,
        report_data: ReportCreate,
        images: List[dict],
        verification_data: Optional[dict] = None
    ) -> Report:
        """Create a new pollution report with optional verification data"""
        # Generate tracking code
        tracking_code = f"ECO-{datetime.now().strftime('%Y')}-{str(uuid.uuid4())[:6].upper()}"
        
        # Create report
        report = Report(
            user_id=user.id,
            type=report_data.type,
            description=report_data.description,
            latitude=report_data.latitude,
            longitude=report_data.longitude,
            address=report_data.address,
            severity=report_data.severity,
            tracking_code=tracking_code
        )
        
        # Add verification data if provided
        if verification_data:
            report.verification_status = verification_data.get('verification_status')
            report.verification_accuracy = verification_data.get('verification_accuracy')
            report.ai_severity = verification_data.get('ai_severity')
            report.points_awarded = verification_data.get('points_awarded', 0)
            report.ai_feedback = verification_data.get('ai_feedback')
            report.needs_admin_review = verification_data.get('needs_admin_review', False)
            # Set status to needs_review if no detections found
            if verification_data.get('needs_admin_review', False):
                report.status = 'needs_review'
        
        db.add(report)
        db.flush()
        
        # Add images
        for img_data in images:
            # Convert detections to JSON string for storage
            detections_json = None
            detections = img_data.get("detections", [])
            if detections:
                try:
                    detections_json = json.dumps(detections)
                except Exception as e:
                    # If JSON serialization fails, log and continue without detections
                    import logging
                    logger = logging.getLogger(__name__)
                    logger.warning(f"Failed to serialize detections to JSON: {e}")
                    detections_json = None
            
            image = ReportImage(
                report_id=report.id,
                image_url=img_data["image_url"],
                thumbnail_url=img_data.get("thumbnail_url"),
                order_index=img_data.get("order_index", 0),
                yolo_detections=detections_json
            )
            db.add(image)
        
        db.commit()
        db.refresh(report)
        return report
    
    @staticmethod
    def get_user_reports(
        db: Session,
        user_id: str,
        status: Optional[str] = None,
        limit: int = 20,
        offset: int = 0
    ) -> tuple[List[Report], int]:
        """Get reports for a user"""
        query = db.query(Report).filter(Report.user_id == user_id)
        
        if status:
            query = query.filter(Report.status == status)
        
        total = query.count()
        reports = query.order_by(desc(Report.created_at)).offset(offset).limit(limit).all()
        
        return reports, total
    
    @staticmethod
    def get_report_by_id(db: Session, report_id: str, user_id: Optional[str] = None) -> Optional[Report]:
        """Get report by ID"""
        query = db.query(Report).filter(Report.id == report_id)
        
        if user_id:
            query = query.filter(Report.user_id == user_id)
        
        return query.first()
    
    @staticmethod
    def update_report_status(
        db: Session,
        report_id: str,
        status: str,
        responder_id: Optional[str] = None,
        message: Optional[str] = None
    ) -> Optional[Report]:
        """Update report status"""
        report = db.query(Report).filter(Report.id == report_id).first()
        if not report:
            return None
        
        report.status = status
        
        if message:
            response = ReportResponse(
                report_id=report_id,
                responder_id=responder_id,
                message=message,
                status=status
            )
            db.add(response)
        
        db.commit()
        db.refresh(report)
        return report

