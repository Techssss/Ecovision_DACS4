"""
Report routes
"""
from fastapi import APIRouter, Depends, UploadFile, File, Query, status, HTTPException, Form, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
import logging
import traceback
from app.database import get_db
from app.auth.dependencies import get_current_user
from app.auth.models import User
from app.reports.schemas import ReportCreate, ReportResponse
from app.reports.service import ReportService
from app.reports.image_handler import process_multiple_images
from app.reports.yolo_detector import generate_description_from_detections
from app.reports.verification_service import verify_report, calculate_ai_severity
from app.reports.points_service import update_user_points
from app.utils.response import success_response, paginated_response

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/analyze-image", response_model=dict)
async def analyze_image(
    image: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Analyze image with YOLO and return auto-generated description
    This endpoint allows frontend to preview description before submitting report
    """
    try:
        from app.reports.yolo_detector import get_detector
        
        # Read image
        image_data = await image.read()
        
        # Run YOLO detection
        detector = get_detector()
        if detector.model is None:
            return success_response(
                data={
                    "description": "",
                    "detections": [],
                    "message": "YOLO model not loaded"
                }
            )
        
        detections = await detector.detect_from_bytes_async(image_data, conf=0.1)
        
        # Generate description from detections
        auto_description = ""
        if detections:
            auto_description = generate_description_from_detections(detections, min_confidence=0.1)
        
        return success_response(
            data={
                "description": auto_description,
                "detections": detections,
                "detection_count": len(detections)
            },
            message="Image analyzed successfully"
        )
    except Exception as e:
        logger.error(f"Error analyzing image: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to analyze image: {str(e)}"
        )


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_report(
    type: str = Form(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    severity: str = Form("medium"),
    description: Optional[str] = Form(None),
    address: Optional[str] = Form(None),
    images: List[UploadFile] = File(default=[]),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new pollution report"""
    try:
        logger.info("=" * 80)
        logger.info(f"🚀 CREATE REPORT STARTED - type: {type}, lat: {latitude}, lng: {longitude}, severity: {severity}, images: {len(images) if images else 0}")
        logger.info(f"User: {current_user.id} ({current_user.email})")
        # Validate severity
        if severity not in ["low", "medium", "high", "critical"]:
            severity = "medium"
        
        # Validate coordinates
        if not (-90 <= latitude <= 90):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Latitude must be between -90 and 90"
            )
        if not (-180 <= longitude <= 180):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Longitude must be between -180 and 180"
            )
        
        # Process images with YOLO detection (optimized and parallel)
        processed_images = []
        all_detections = []
        if images:
            try:
                logger.info(f"📸 Processing {len(images)} images with YOLO detection...")
                # Process all images in parallel with detection enabled
                processed_images = await process_multiple_images(images, run_detection=True)
                logger.info(f"✅ Processed {len(processed_images)} images")
                
                # Collect all detections from all images
                for idx, img_data in enumerate(processed_images):
                    img_detections = img_data.get("detections", [])
                    if img_detections:
                        logger.info(f"  Image {idx}: Found {len(img_detections)} detections: {[d.get('class_name', 'unknown') for d in img_detections[:3]]}")
                        all_detections.extend(img_detections)
                    else:
                        logger.info(f"  Image {idx}: No detections found")
                
                logger.info(f"📊 Total detections across all images: {len(all_detections)}")
            except Exception as e:
                logger.error(f"❌ Error processing images: {str(e)}", exc_info=True)
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Failed to process images: {str(e)}"
                )
        else:
            logger.warning("⚠️ No images provided in report")
        
        # Auto-generate description from YOLO detections - ALWAYS use YOLO if detections found
        # This ensures description matches what's actually in the image
        final_description = description  # Start with user description as fallback
        
        # Simple detection-based logic: +1 point if any detections found
        has_detections = len(all_detections) > 0
        points_to_award = 1 if has_detections else 0
        logger.info(f"🎯 Detection summary: has_detections={has_detections}, total_detections={len(all_detections)}, points_to_award={points_to_award}")
        
        if all_detections:
            auto_description = generate_description_from_detections(all_detections, min_confidence=0.1)
            if auto_description:
                # Always use YOLO description to match the image content
                final_description = auto_description
                logger.info(f"Using YOLO auto-generated description: {auto_description}")
                if description and description.strip():
                    logger.info(f"User provided description was: {description} (replaced with YOLO description)")
            else:
                logger.info("YOLO detections found but no description generated, keeping user description")
        else:
            logger.info("No YOLO detections found, using user description if provided")
        
        # Prepare verification data based on detections
        verification_data = None
        if has_detections:
            # Detections found: award 1 point and note it
            verification_data = {
                'verification_status': 'verified',
                'verification_accuracy': 100.0,
                'ai_severity': calculate_ai_severity(all_detections),
                'points_awarded': 1,
                'ai_feedback': f"Đã phát hiện {len(all_detections)} object(s) trong ảnh. Đã +1 điểm cho người dùng."
            }
            logger.info(f"Detections found: {len(all_detections)} objects. Awarding +1 point.")
        else:
            # No detections: mark for admin review
            verification_data = {
                'verification_status': 'needs_review',
                'verification_accuracy': 0.0,
                'ai_severity': 'low',
                'points_awarded': 0,
                'ai_feedback': 'Báo cáo cần được admin xem xét - không phát hiện được gì trong ảnh.',
                'needs_admin_review': True
            }
            logger.warning("No detections found - marking report for admin review")
        
        # Create ReportCreate object from form data
        report_data = ReportCreate(
            type=type,
            latitude=latitude,
            longitude=longitude,
            severity=severity,
            description=final_description,  # Use merged description
            address=address
        )
        
        # Create report with verification data
        try:
            report = ReportService.create_report(
                db, 
                current_user, 
                report_data, 
                processed_images,
                verification_data=verification_data
            )
            
            # Log detection status
            logger.info(f"Report created: ID={report.id}, has_detections={has_detections}, detections_count={len(all_detections)}")
            
            # Update user points and total_reports AFTER report is committed
            # Always increment total_reports when creating a report
            # Points only added if detections found
            logger.info("=" * 80)
            logger.info("💰 STARTING POINTS UPDATE PROCESS")
            logger.info(f"  - Report ID: {report.id}")
            logger.info(f"  - User ID: {current_user.id}")
            logger.info(f"  - Has detections: {has_detections}")
            logger.info(f"  - Detections count: {len(all_detections)}")
            
            # IMPORTANT: Update points MUST happen, even if there's an error
            # Get fresh user data from database (after report commit)
            db.refresh(current_user)
            old_points = current_user.points or 0
            old_total_reports = current_user.total_reports or 0
            old_verified_reports = current_user.verified_reports or 0
            
            logger.info(f"📊 BEFORE UPDATE:")
            logger.info(f"  - Points: {old_points}")
            logger.info(f"  - Total reports: {old_total_reports}")
            logger.info(f"  - Verified reports: {old_verified_reports}")
            logger.info(f"  - Rank: {current_user.rank}")
            
            # Calculate points to add
            points_to_add = 1 if has_detections else 0
            logger.info(f"🎯 UPDATE PLAN:")
            logger.info(f"  - Points to add: {points_to_add}")
            logger.info(f"  - Increment total_reports: True")
            logger.info(f"  - Is verified: {has_detections}")
            
            # Call update function - this MUST succeed
            try:
                logger.info("🔄 Calling update_user_points()...")
                updated_user = update_user_points(
                    db=db,
                    user_id=current_user.id,
                    points_to_add=points_to_add,
                    is_verified=has_detections,
                    increment_total_reports=True
                )
                
                logger.info("=" * 80)
                logger.info("✅ POINTS UPDATE SUCCESSFUL:")
                logger.info(f"  - Points: {old_points} → {updated_user.points} (+{points_to_add})")
                logger.info(f"  - Total reports: {old_total_reports} → {updated_user.total_reports} (+1)")
                logger.info(f"  - Verified reports: {old_verified_reports} → {updated_user.verified_reports}")
                logger.info(f"  - Rank: {current_user.rank} → {updated_user.rank}")
                logger.info("=" * 80)
            except Exception as e:
                logger.error("=" * 80)
                logger.error("❌ POINTS UPDATE FAILED - ATTEMPTING MANUAL UPDATE:")
                logger.error(f"  - Error: {e}")
                logger.error(f"  - Traceback: {traceback.format_exc()}")
                
                # Fallback: Try to update manually
                try:
                    logger.info("🔄 Attempting manual update...")
                    user = db.query(User).filter(User.id == current_user.id).first()
                    if user:
                        user.points = (user.points or 0) + points_to_add
                        if user.points < 0:
                            user.points = 0
                        user.total_reports = (user.total_reports or 0) + 1
                        if has_detections:
                            user.verified_reports = (user.verified_reports or 0) + 1
                        from app.reports.points_service import calculate_rank
                        user.rank = calculate_rank(user.points)
                        db.commit()
                        db.refresh(user)
                        logger.info(f"✅ Manual update successful: points={user.points}, total_reports={user.total_reports}")
                    else:
                        logger.error("❌ User not found for manual update")
                except Exception as e2:
                    logger.error(f"❌ Manual update also failed: {e2}")
                
                logger.error("=" * 80)
                # Don't fail report creation if points update fails
        except Exception as e:
            logger.error(f"Error creating report: {str(e)}", exc_info=True)
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create report: {str(e)}"
            )
        
        # Prepare response with verification info
        report_response = ReportResponse.from_orm(report).dict()
        
        # Add verification summary to message
        message = "Report created successfully"
        if verification_data:
            if has_detections:
                message = f"Report created successfully. Đã phát hiện {len(all_detections)} object(s) trong ảnh. Đã +1 điểm cho người dùng."
            else:
                message = "Report created successfully. Không phát hiện được gì trong ảnh - báo cáo đã được gửi cho admin xem xét."
        
        return success_response(
            data=report_response,
            message=message
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error creating report: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create report: {str(e)}"
        )


@router.get("/user", response_model=dict)
async def get_user_reports(
    status: Optional[str] = Query(None, description="Filter by status"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get reports for current user"""
    reports, total = ReportService.get_user_reports(
        db, current_user.id, status, limit, offset
    )
    
    return paginated_response(
        data=[ReportResponse.from_orm(r).dict() for r in reports],
        total=total,
        limit=limit,
        offset=offset
    )


@router.get("/{report_id}", response_model=dict)
async def get_report(
    report_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get report by ID"""
    report = ReportService.get_report_by_id(db, report_id, current_user.id)
    if not report:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Report")
    
    return success_response(data=ReportResponse.from_orm(report).dict())

