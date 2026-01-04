"""
Admin dashboard routes
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, desc
from typing import Optional
from datetime import datetime, timedelta
from app.database import get_db
from app.auth.models import User
from app.admin.dependencies import get_admin_user
from app.reports.models import Report, ReportImage, ReportResponse
from app.aqi.models import AQIReading, AQIStation
from app.utils.response import success_response, paginated_response
import json

router = APIRouter()


@router.get("/dashboard/stats", response_model=dict)
async def get_dashboard_stats(
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Get dashboard statistics"""
    # TODO: Add admin role check
    
    # AQI Statistics - Get from last 7 days or all time if no recent data
    aqi_stats_recent = db.query(
        func.avg(AQIReading.aqi).label('avg_aqi'),
        func.max(AQIReading.aqi).label('max_aqi'),
        func.min(AQIReading.aqi).label('min_aqi'),
        func.count(AQIReading.id).label('total_readings')
    ).filter(
        AQIReading.recorded_at >= datetime.now() - timedelta(days=7)
    ).first()
    
    # Fallback to all-time stats if no recent data
    if not aqi_stats_recent or (aqi_stats_recent.total_readings and aqi_stats_recent.total_readings == 0):
        aqi_stats = db.query(
            func.avg(AQIReading.aqi).label('avg_aqi'),
            func.max(AQIReading.aqi).label('max_aqi'),
            func.min(AQIReading.aqi).label('min_aqi'),
            func.count(AQIReading.id).label('total_readings')
        ).first()
    else:
        aqi_stats = aqi_stats_recent
    
    # Report Statistics
    total_reports = db.query(func.count(Report.id)).scalar() or 0
    pending_reports = db.query(func.count(Report.id)).filter(Report.status == 'pending').scalar() or 0
    resolved_reports = db.query(func.count(Report.id)).filter(Report.status == 'resolved').scalar() or 0
    reviewing_reports = db.query(func.count(Report.id)).filter(Report.status == 'reviewing').scalar() or 0
    
    # Reports by type - ensure all types are included
    reports_by_type_query = db.query(
        Report.type,
        func.count(Report.id).label('count')
    ).group_by(Report.type).all()
    
    reports_by_type = {r.type: r.count for r in reports_by_type_query}
    
    # Reports by severity - ensure all severities are included
    reports_by_severity_query = db.query(
        Report.severity,
        func.count(Report.id).label('count')
    ).group_by(Report.severity).all()
    
    reports_by_severity = {r.severity: r.count for r in reports_by_severity_query}
    
    return success_response(
        data={
            "aqi": {
                "average": float(aqi_stats.avg_aqi) if aqi_stats and aqi_stats.avg_aqi else 0.0,
                "max": int(aqi_stats.max_aqi) if aqi_stats and aqi_stats.max_aqi else 0,
                "min": int(aqi_stats.min_aqi) if aqi_stats and aqi_stats.min_aqi else 0,
                "total_readings": aqi_stats.total_readings if aqi_stats else 0
            },
            "reports": {
                "total": total_reports,
                "pending": pending_reports,
                "resolved": resolved_reports,
                "reviewing": reviewing_reports,
                "by_type": reports_by_type,
                "by_severity": reports_by_severity
            }
        }
    )


@router.get("/reports", response_model=dict)
async def get_all_reports(
    status: Optional[str] = Query(None, description="Filter by status"),
    type: Optional[str] = Query(None, description="Filter by pollution type"),
    severity: Optional[str] = Query(None, description="Filter by severity"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Get all reports for admin (with YOLOv8 detections)"""
    # TODO: Add admin role check
    
    # Base query with eager loading for images to avoid N+1 queries
    query = db.query(Report).options(
        joinedload(Report.images)
    )
    
    if status:
        query = query.filter(Report.status == status)
    if type:
        query = query.filter(Report.type == type)
    if severity:
        query = query.filter(Report.severity == severity)
    
    total = query.count()
    reports = query.order_by(desc(Report.created_at)).offset(offset).limit(limit).all()
    
    # Get all user IDs and load users in one query
    user_ids = list(set([report.user_id for report in reports]))
    users = {user.id: user for user in db.query(User).filter(User.id.in_(user_ids)).all()} if user_ids else {}
    
    # Format reports with images and YOLO detections
    reports_data = []
    for report in reports:
        # Images are already loaded via joinedload
        images_data = []
        for img in sorted(report.images, key=lambda x: x.order_index):
            detections = []
            if img.yolo_detections:
                try:
                    # Parse YOLO detections (stored as string)
                    detections = json.loads(img.yolo_detections) if isinstance(img.yolo_detections, str) else img.yolo_detections
                except:
                    detections = []
            
            images_data.append({
                "id": img.id,
                "image_url": img.image_url,
                "thumbnail_url": img.thumbnail_url,
                "order_index": img.order_index,
                "yolo_detections": detections  # Array of {class, class_name, confidence, bbox}
            })
        
        # Get user from pre-loaded users dict
        user = users.get(report.user_id)
        
        reports_data.append({
            "id": report.id,
            "type": report.type,
            "description": report.description,
            "latitude": float(report.latitude),
            "longitude": float(report.longitude),
            "address": report.address,
            "severity": report.severity,
            "status": report.status,
            "tracking_code": report.tracking_code,
            "created_at": report.created_at.isoformat() if report.created_at else None,
            "updated_at": report.updated_at.isoformat() if report.updated_at else None,
            "user": {
                "id": user.id if user else None,
                "name": user.name if user else None,
                "email": user.email if user else None
            },
            "images": images_data
        })
    
    return paginated_response(
        data=reports_data,
        total=total,
        limit=limit,
        offset=offset
    )


@router.get("/reports/{report_id}", response_model=dict)
async def get_report_detail(
    report_id: str,
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Get detailed report information with YOLOv8 analysis"""
    # TODO: Add admin role check
    
    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Report")
    
    # Get images with YOLO detections
    images = db.query(ReportImage).filter(
        ReportImage.report_id == report.id
    ).order_by(ReportImage.order_index).all()
    
    images_data = []
    all_detections = []
    
    for img in images:
        detections = []
        if img.yolo_detections:
            try:
                detections = json.loads(img.yolo_detections) if isinstance(img.yolo_detections, str) else img.yolo_detections
            except:
                detections = []
        
        all_detections.extend(detections)
        
        images_data.append({
            "id": img.id,
            "image_url": img.image_url,
            "thumbnail_url": img.thumbnail_url,
            "order_index": img.order_index,
            "yolo_detections": detections
        })
    
    # Analyze YOLO detections
    detection_summary = {}
    for det in all_detections:
        class_name = det.get('class_name', 'unknown')
        if class_name not in detection_summary:
            detection_summary[class_name] = {
                "count": 0,
                "avg_confidence": 0,
                "max_confidence": 0
            }
        detection_summary[class_name]["count"] += 1
        conf = det.get('confidence', 0)
        detection_summary[class_name]["avg_confidence"] += conf
        detection_summary[class_name]["max_confidence"] = max(
            detection_summary[class_name]["max_confidence"], conf
        )
    
    # Calculate average confidence
    for class_name in detection_summary:
        count = detection_summary[class_name]["count"]
        detection_summary[class_name]["avg_confidence"] /= count
    
    # Get user info
    user = db.query(User).filter(User.id == report.user_id).first()
    
    # Get responses
    responses = db.query(ReportResponse).filter(
        ReportResponse.report_id == report.id
    ).order_by(desc(ReportResponse.created_at)).all()
    
    return success_response(
        data={
            "id": report.id,
            "type": report.type,
            "description": report.description,
            "latitude": float(report.latitude),
            "longitude": float(report.longitude),
            "address": report.address,
            "severity": report.severity,
            "status": report.status,
            "tracking_code": report.tracking_code,
            "created_at": report.created_at.isoformat() if report.created_at else None,
            "updated_at": report.updated_at.isoformat() if report.updated_at else None,
            "user": {
                "id": user.id if user else None,
                "name": user.name if user else None,
                "email": user.email if user else None
            },
            "images": images_data,
            "yolo_analysis": {
                "total_detections": len(all_detections),
                "detection_summary": detection_summary,
                "detected_classes": list(detection_summary.keys())
            },
            "responses": [
                {
                    "id": r.id,
                    "message": r.message,
                    "status": r.status,
                    "created_at": r.created_at.isoformat() if r.created_at else None
                }
                for r in responses
            ]
        }
    )


@router.put("/reports/{report_id}/status", response_model=dict)
async def update_report_status(
    report_id: str,
    new_status: str = Query(..., description="New status: pending, reviewing, resolved, rejected"),
    message: Optional[str] = Query(None, description="Response message"),
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Update report status (admin only)"""
    # TODO: Add admin role check
    
    from app.reports.service import ReportService
    
    report = ReportService.update_report_status(
        db, report_id, new_status, current_user.id, message
    )
    
    if not report:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Report")
    
    return success_response(
        data={"id": report.id, "status": report.status},
        message="Report status updated successfully"
    )


@router.delete("/reports/{report_id}", response_model=dict)
async def delete_report(
    report_id: str,
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Delete report (admin only)
    
    IMPORTANT: When admin deletes a report:
    - Report is deleted from database
    - User's points are NOT decreased (points are permanent)
    - User's total_reports count is NOT decreased (count is permanent)
    - Only the report record is removed
    """
    # TODO: Add admin role check
    
    # Find report
    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Report")
    
    # IMPORTANT: Do NOT update user points or total_reports when deleting
    # Points and total_reports are permanent and should not decrease
    # Only delete the report record itself
    
    user_id = report.user_id
    report_points = report.points_awarded or 0
    
    # Delete associated images first (cascade)
    db.query(ReportImage).filter(ReportImage.report_id == report_id).delete()
    
    # Delete responses
    db.query(ReportResponse).filter(ReportResponse.report_id == report_id).delete()
    
    # Delete report
    db.delete(report)
    db.commit()
    
    # Log deletion (but don't modify user points)
    import logging
    logger = logging.getLogger(__name__)
    logger.info(
        f"Admin deleted report {report_id} for user {user_id}. "
        f"Report had {report_points} points, but user points remain unchanged."
    )
    
    return success_response(
        data={"id": report_id},
        message="Report deleted successfully. User points and total_reports remain unchanged."
    )


@router.post("/reports/{report_id}/detect", response_model=dict)
async def run_detection_on_report(
    report_id: str,
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Run YOLOv8 detection on report images (on-demand)"""
    # TODO: Add admin role check
    
    # Find report
    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Report")
    
    # Get images
    images = db.query(ReportImage).filter(
        ReportImage.report_id == report_id
    ).order_by(ReportImage.order_index).all()
    
    if not images:
        return success_response(
            data={"message": "No images to process"},
            message="No images found"
        )
    
    # Run detection on each image
    from app.reports.yolo_detector import get_detector
    import requests
    from io import BytesIO
    
    detector = get_detector()
    updated_count = 0
    
    for img in images:
        try:
            # Download image
            if img.image_url.startswith('http'):
                response = requests.get(img.image_url)
                image_bytes = response.content
            else:
                # Local file
                from pathlib import Path
                image_path = Path("uploads") / img.image_url.replace("/uploads/", "")
                with open(image_path, 'rb') as f:
                    image_bytes = f.read()
            
            # Run detection
            detections = detector.detect_from_bytes(image_bytes)
            
            # Update database
            img.yolo_detections = json.dumps(detections)
            updated_count += 1
            
        except Exception as e:
            print(f"Error processing image {img.id}: {e}")
            continue
    
    db.commit()
    
    return success_response(
        data={
            "report_id": report_id,
            "images_processed": updated_count,
            "total_images": len(images)
        },
        message=f"Detection completed on {updated_count} images"
    )


@router.get("/aqi/stats", response_model=dict)
async def get_aqi_stats(
    days: int = Query(7, ge=1, le=30, description="Number of days"),
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Get AQI statistics for dashboard"""
    # TODO: Add admin role check
    
    start_date = datetime.now() - timedelta(days=days)
    
    # Average AQI by day
    daily_aqi = db.query(
        func.date(AQIReading.recorded_at).label('date'),
        func.avg(AQIReading.aqi).label('avg_aqi'),
        func.max(AQIReading.aqi).label('max_aqi'),
        func.min(AQIReading.aqi).label('min_aqi')
    ).filter(
        AQIReading.recorded_at >= start_date
    ).group_by(
        func.date(AQIReading.recorded_at)
    ).order_by(
        func.date(AQIReading.recorded_at)
    ).all()
    
    # Overall statistics
    overall = db.query(
        func.avg(AQIReading.aqi).label('avg_aqi'),
        func.max(AQIReading.aqi).label('max_aqi'),
        func.min(AQIReading.aqi).label('min_aqi'),
        func.count(AQIReading.id).label('total_readings')
    ).filter(
        AQIReading.recorded_at >= start_date
    ).first()
    
    return success_response(
        data={
            "period_days": days,
            "overall": {
                "average": float(overall.avg_aqi) if overall.avg_aqi else 0,
                "max": int(overall.max_aqi) if overall.max_aqi else 0,
                "min": int(overall.min_aqi) if overall.min_aqi else 0,
                "total_readings": overall.total_readings or 0
            },
            "daily": [
                {
                    "date": str(daily.date),
                    "average": float(daily.avg_aqi) if daily.avg_aqi else 0,
                    "max": int(daily.max_aqi) if daily.max_aqi else 0,
                    "min": int(daily.min_aqi) if daily.min_aqi else 0
                }
                for daily in daily_aqi
            ]
        }
    )


@router.get("/trend-forecast", response_model=dict)
async def get_trend_forecast(
    historical_days: int = Query(14, ge=7, le=30, description="Days of historical data"),
    forecast_days: int = Query(7, ge=1, le=14, description="Days to forecast"),
    current_user: Optional[User] = Depends(get_admin_user),
    db: Session = Depends(get_db)
):
    """Get trend forecast using Prophet or linear regression"""
    # TODO: Add admin role check
    
    from app.admin.forecast import TrendForecastService
    
    try:
        # Get historical data
        df = TrendForecastService.get_historical_data(db, days=historical_days)
        
        # Generate forecast
        forecast_result = TrendForecastService.forecast_with_prophet(df, periods=forecast_days)
        
        return success_response(
            data=forecast_result,
            message="Trend forecast generated successfully"
        )
        
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Forecast error: {e}")
        
        # Return error with fallback data
        return success_response(
            data={
                "error": str(e),
                "historical": [],
                "forecast": [],
                "trend": {
                    "change_percent": 0,
                    "direction": "stable",
                    "last_week_avg": 0,
                    "next_week_avg": 0
                },
                "insights": {
                    "severity": "error",
                    "icon": "⚠️",
                    "summary": "Không thể tạo dự báo. Vui lòng thử lại sau.",
                    "recommendations": ["Kiểm tra dữ liệu lịch sử", "Liên hệ admin nếu lỗi tiếp diễn"],
                    "trend_change": 0,
                    "next_week_avg": 0
                },
                "model": "error"
            },
            message="Error generating forecast"
        )

