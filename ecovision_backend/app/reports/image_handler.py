"""
Image handling for reports
"""
from typing import List, Optional
from fastapi import UploadFile
from PIL import Image
import io
import uuid
import asyncio
from app.config import settings
from app.utils.file_handler import save_uploaded_file, compress_image
from app.reports.yolo_detector import get_detector, generate_description_from_detections
import logging

logger = logging.getLogger(__name__)

# Try to import Cloudinary service
CLOUDINARY_AVAILABLE = False
CloudinaryService = None

try:
    import cloudinary
    from app.utils.cloudinary_service import CloudinaryService
    CLOUDINARY_AVAILABLE = True
    logger.info("Cloudinary service available")
except ImportError as e:
    logger.warning(f"Cloudinary not available (package not installed): {str(e)}")
except Exception as e:
    logger.warning(f"Cloudinary not available: {str(e)}")


async def process_report_image(
    file: UploadFile,
    run_detection: bool = True
) -> dict:
    """
    Process uploaded report image:
    - Compress if needed
    - Upload to Cloudinary (if configured) or save locally
    - Generate thumbnail
    - Run YOLO detection if requested
    """
    # Read file for processing
    await file.seek(0)
    image_data = await file.read()
    
    # Compress image
    compressed_data = await compress_image(image_data, max_size=1024 * 1024)  # 1MB
    
    # Upload to Cloudinary or save locally
    image_url = None
    thumbnail_url = None
    
    if settings.USE_CLOUDINARY and CLOUDINARY_AVAILABLE and CloudinaryService is not None:
        try:
            # Generate unique public_id
            public_id = f"report_{uuid.uuid4()}"
            
            # Upload to Cloudinary with thumbnail
            result = CloudinaryService.upload_image_with_thumbnail(
                image_bytes=compressed_data,
                folder="ecovision/reports",
                public_id=public_id
            )
            
            image_url = result.get("image_url")
            thumbnail_url = result.get("thumbnail_url")
            
            logger.info(f"Image uploaded to Cloudinary: {public_id}")
            
        except Exception as e:
            logger.error(f"Failed to upload to Cloudinary: {str(e)}, falling back to local storage")
            # Fallback to local storage
            await file.seek(0)
            file_path = await save_uploaded_file(file, subdirectory="reports")
            image_url = f"/uploads/reports/{file_path}"
            thumbnail_url = None
    
    else:
        # Save to local storage
        await file.seek(0)
        file_path = await save_uploaded_file(file, subdirectory="reports")
        image_url = f"/uploads/reports/{file_path}"
        thumbnail_url = None
    
    # Run YOLO detection (async for better performance)
    detections = []
    if run_detection:
        try:
            detector = get_detector()
            if detector.model is None:
                logger.warning("YOLO model is not loaded, skipping detection")
            else:
                logger.info(f"Running YOLO detection on image (size: {len(compressed_data)} bytes)")
                # Use async detection with lower confidence for better detection
                detections = await detector.detect_from_bytes_async(compressed_data, conf=0.1)
                logger.info(f"YOLO detection completed: found {len(detections)} objects")
                if detections:
                    for det in detections:
                        logger.debug(f"  - {det.get('class_name')}: {det.get('confidence'):.2%}")
        except Exception as e:
            logger.error(f"YOLO detection failed: {str(e)}", exc_info=True)
            detections = []
    
    return {
        "image_url": image_url,
        "thumbnail_url": thumbnail_url,
        "detections": detections
    }


async def process_multiple_images(
    files: List[UploadFile],
    run_detection: bool = True
) -> List[dict]:
    """
    Process multiple report images - optimized with parallel processing
    """
    if not files:
        return []
    
    # Process all images in parallel for faster response
    tasks = []
    for i, file in enumerate(files):
        task = process_report_image(file, run_detection)
        tasks.append((i, task))
    
    # Wait for all images to be processed concurrently
    task_results = await asyncio.gather(*[task for _, task in tasks], return_exceptions=True)
    
    # Combine results with order_index
    processed_results = []
    for (original_idx, _), result in zip(tasks, task_results):
        if isinstance(result, Exception):
            logger.error(f"Error processing image {original_idx}: {result}")
            continue
        result["order_index"] = original_idx
        processed_results.append(result)
    
    # Sort by order_index to maintain original order
    processed_results.sort(key=lambda x: x.get("order_index", 0))
    
    return processed_results

