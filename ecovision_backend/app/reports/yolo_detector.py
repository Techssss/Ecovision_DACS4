"""
YOLOv8 object detection for pollution reports
"""
from typing import List, Dict, Optional
from pathlib import Path
import io
import asyncio
import torch
from ultralytics import YOLO
from PIL import Image
from app.config import settings
import json
import logging

logger = logging.getLogger(__name__)

# Mapping từ class names sang tiếng Việt
CLASS_NAME_VI = {
    'Graffiti': 'Graffiti',
    'garbage': 'Rác thải',
    'sand on road': 'Cát trên đường',
    'air_pollution': 'Ô nhiễm không khí',
    'water_pollution': 'Ô nhiễm nước',
    'trash': 'Rác thải',
    'dust': 'Khói bụi',
    'industrial': 'Ô nhiễm công nghiệp',
}


def generate_description_from_detections(detections: List[Dict], min_confidence: float = 0.3) -> str:
    """
    Tự động tạo mô tả chi tiết từ YOLO detection results dựa trên ảnh
    
    Args:
        detections: List of detection dicts
        min_confidence: Minimum confidence threshold
        
    Returns:
        Description string in Vietnamese - mô tả chi tiết theo ảnh
    """
    if not detections:
        logger.debug("No detections provided")
        return ""
    
    # Log tất cả detections để debug
    logger.info(f"YOLO detected {len(detections)} objects: {[d.get('class_name') for d in detections]}")
    
    # Lọc detections theo confidence
    filtered_detections = [d for d in detections if d.get('confidence', 0) >= min_confidence]
    
    if not filtered_detections:
        logger.debug(f"No detections above confidence threshold {min_confidence}")
        return ""
    
    logger.info(f"Filtered to {len(filtered_detections)} detections above threshold")
    
    # Đếm số lượng từng loại và tính confidence trung bình
    class_info = {}
    for det in filtered_detections:
        class_name = det.get('class_name', '')
        vi_name = CLASS_NAME_VI.get(class_name, class_name)
        confidence = det.get('confidence', 0)
        
        if vi_name not in class_info:
            class_info[vi_name] = {
                'count': 0,
                'confidences': [],
                'avg_confidence': 0
            }
        
        class_info[vi_name]['count'] += 1
        class_info[vi_name]['confidences'].append(confidence)
    
    # Tính confidence trung bình cho mỗi loại
    for vi_name, info in class_info.items():
        if info['confidences']:
            info['avg_confidence'] = sum(info['confidences']) / len(info['confidences'])
    
    # Tạo mô tả đơn giản và chính xác dựa trên những gì detect được
    descriptions = []
    
    # Mô tả từng loại phát hiện được (theo thứ tự confidence cao xuống thấp)
    sorted_classes = sorted(
        class_info.items(), 
        key=lambda x: x[1]['avg_confidence'], 
        reverse=True
    )
    
    for vi_name, info in sorted_classes:
        count = info['count']
        
        if count == 1:
            desc = vi_name
        else:
            desc = f"{count} {vi_name}"
        
        descriptions.append(desc)
    
    # Tạo mô tả tự nhiên
    if len(descriptions) == 1:
        result = f"Phát hiện {descriptions[0]} trong ảnh."
    elif len(descriptions) == 2:
        result = f"Phát hiện {descriptions[0]} và {descriptions[1]} trong ảnh."
    else:
        # Nhiều hơn 2 loại
        last = descriptions[-1]
        others = ", ".join(descriptions[:-1])
        result = f"Phát hiện {others} và {last} trong ảnh."
    
    logger.info(f"Generated description: {result}")
    return result


class YOLODetector:
    """YOLOv8 detector for pollution detection - Optimized for speed"""
    
    def __init__(self):
        self.model: Optional[YOLO] = None
        self.model_path = Path(settings.YOLO_MODEL_PATH)
        self._load_model()
        # Thread pool for async operations
        self._executor = None
    
    def _load_model(self):
        """Load YOLOv8 model - cached singleton"""
        try:
            # Resolve to absolute path
            abs_path = self.model_path.resolve()
            if abs_path.exists():
                logger.info(f"Loading YOLO model from {abs_path}")
                self.model = YOLO(str(abs_path))
                logger.info(f"Model loaded successfully. Classes: {list(self.model.names.values())}")
                # Note: FP16 conversion removed due to compatibility issues
                # Model will use default precision (FP32 for CPU, FP16/FP32 for GPU based on model)
            else:
                logger.warning(f"Model not found at {abs_path}, trying relative path...")
                # Try relative path from current working directory
                if self.model_path.exists():
                    logger.info(f"Loading YOLO model from relative path: {self.model_path}")
                    self.model = YOLO(str(self.model_path))
                    logger.info(f"Model loaded successfully. Classes: {list(self.model.names.values())}")
                else:
                    logger.warning(f"Model not found at {self.model_path}, using fallback yolov8n.pt")
                    # Fallback to pretrained model if custom model not found
                    self.model = YOLO("yolov8n.pt")
                    logger.warning("Using default yolov8n.pt model (not pollution-specific)")
        except Exception as e:
            logger.error(f"Error loading YOLO model: {e}", exc_info=True)
            self.model = None
    
    def detect(self, image_path: str, conf: float = 0.25) -> List[Dict]:
        """
        Detect objects in image
        Returns list of detections with class, confidence, bbox
        
        Args:
            image_path: Path to image file
            conf: Confidence threshold (lower = faster but less accurate)
        """
        if self.model is None:
            return []
        
        try:
            # Run inference with optimized settings
            results = self.model(
                image_path,
                conf=conf,
                imgsz=640,  # Standard size for speed
                verbose=False  # Disable verbose output
            )
            
            detections = []
            for result in results:
                boxes = result.boxes
                for box in boxes:
                    detection = {
                        "class": int(box.cls[0]),
                        "class_name": self.model.names[int(box.cls[0])],
                        "confidence": float(box.conf[0]),
                        "bbox": box.xyxy[0].tolist()  # [x1, y1, x2, y2]
                    }
                    detections.append(detection)
            
            return detections
        except Exception as e:
            logger.error(f"Error during detection: {e}")
            return []
    
    def detect_from_bytes(self, image_bytes: bytes, conf: float = 0.25) -> List[Dict]:
        """
        Detect objects from image bytes - optimized version
        
        Args:
            image_bytes: Image bytes
            conf: Confidence threshold
        """
        if self.model is None:
            logger.warning("YOLO model is None, cannot perform detection")
            return []
        
        try:
            # Convert bytes to PIL Image
            image = Image.open(io.BytesIO(image_bytes))
            logger.debug(f"Image size: {image.size}, mode: {image.mode}")
            
            # Run inference with optimized settings
            results = self.model(
                image,
                conf=conf,
                imgsz=640,
                verbose=False
            )
            
            detections = []
            for result in results:
                if result.boxes is not None and len(result.boxes) > 0:
                    boxes = result.boxes
                    for box in boxes:
                        detection = {
                            "class": int(box.cls[0]),
                            "class_name": self.model.names[int(box.cls[0])],
                            "confidence": float(box.conf[0]),
                            "bbox": box.xyxy[0].tolist()
                        }
                        detections.append(detection)
                else:
                    logger.debug("No detections found in image")
            
            if detections:
                logger.info(f"Found {len(detections)} detections: {[d['class_name'] for d in detections]}")
            
            return detections
        except Exception as e:
            logger.error(f"Error during detection from bytes: {e}", exc_info=True)
            return []
    
    async def detect_from_bytes_async(self, image_bytes: bytes, conf: float = 0.25) -> List[Dict]:
        """
        Async version of detect_from_bytes for concurrent processing
        Compatible with Windows and uvicorn reload
        """
        try:
            # Try to get running loop (preferred for async context)
            loop = asyncio.get_running_loop()
        except RuntimeError:
            # Fallback if no running loop (shouldn't happen in FastAPI context)
            loop = asyncio.get_event_loop()
        
        # Run detection in thread pool to avoid blocking
        return await loop.run_in_executor(None, self.detect_from_bytes, image_bytes, conf)
    
    def detect_batch(self, image_bytes_list: List[bytes], conf: float = 0.25) -> List[List[Dict]]:
        """
        Batch detection for multiple images - faster than sequential
        
        Args:
            image_bytes_list: List of image bytes
            conf: Confidence threshold
        """
        if self.model is None:
            return [[] for _ in image_bytes_list]
        
        try:
            # Convert all bytes to PIL Images
            images = [Image.open(io.BytesIO(img_bytes)) for img_bytes in image_bytes_list]
            
            # Run batch inference
            results = self.model(
                images,
                conf=conf,
                imgsz=640,
                verbose=False
            )
            
            all_detections = []
            for result in results:
                detections = []
                boxes = result.boxes
                for box in boxes:
                    detection = {
                        "class": int(box.cls[0]),
                        "class_name": self.model.names[int(box.cls[0])],
                        "confidence": float(box.conf[0]),
                        "bbox": box.xyxy[0].tolist()
                    }
                    detections.append(detection)
                all_detections.append(detections)
            
            return all_detections
        except Exception as e:
            logger.error(f"Error during batch detection: {e}")
            return [[] for _ in image_bytes_list]


# Global detector instance (singleton)
detector = YOLODetector()


def get_detector() -> YOLODetector:
    """Get YOLO detector instance (singleton)"""
    return detector

