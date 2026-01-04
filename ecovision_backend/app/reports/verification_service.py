"""
AI Verification Service
Compares user input with YOLO detections and calculates verification accuracy
"""
from typing import List, Dict, Optional, Tuple
from app.reports.yolo_detector import CLASS_NAME_VI
import logging

logger = logging.getLogger(__name__)

# Mapping từ YOLO class names sang pollution types
YOLO_TO_POLLUTION_TYPE = {
    'Graffiti': 'other',  # Graffiti không có trong pollution types, map to 'other'
    'garbage': 'trash',
    'trash': 'trash',
    'sand on road': 'other',
    'air_pollution': 'air',
    'water_pollution': 'water',
    'dust': 'air',
    'industrial': 'other',
}

# Reverse mapping từ pollution type sang YOLO classes
# Frontend sends: air_pollution, water_pollution, trash, noise_pollution, dust, other
POLLUTION_TYPE_TO_YOLO = {
    'air': ['air_pollution', 'dust'],
    'air_pollution': ['air_pollution', 'dust'],  # Support both formats
    'water': ['water_pollution'],
    'water_pollution': ['water_pollution'],  # Support both formats
    'trash': ['garbage', 'trash'],
    'dust': ['dust'],
    'other': ['Graffiti', 'sand on road', 'industrial'],
    'noise': [],  # Noise không có trong YOLO
    'noise_pollution': [],  # Noise không có trong YOLO
}


def calculate_ai_severity(detections: List[Dict]) -> str:
    """
    Calculate severity from YOLO detections based on:
    - Number of detections
    - Average confidence
    - Types detected
    
    Returns: 'low', 'medium', 'high', 'critical'
    """
    if not detections:
        return 'low'
    
    # Filter by confidence >= 0.3
    valid_detections = [d for d in detections if d.get('confidence', 0) >= 0.3]
    
    if not valid_detections:
        return 'low'
    
    detection_count = len(valid_detections)
    avg_confidence = sum(d.get('confidence', 0) for d in valid_detections) / len(valid_detections)
    max_confidence = max(d.get('confidence', 0) for d in valid_detections)
    
    # Severity calculation
    if detection_count >= 5 or (detection_count >= 3 and avg_confidence >= 0.8):
        return 'critical'
    elif detection_count >= 3 or (detection_count >= 2 and avg_confidence >= 0.7):
        return 'high'
    elif detection_count >= 2 or avg_confidence >= 0.6:
        return 'medium'
    else:
        return 'low'


def match_pollution_type(user_type: str, detections: List[Dict]) -> Tuple[bool, float]:
    """
    Check if user-selected pollution type matches YOLO detections
    
    Returns: (is_match, confidence_score 0-1)
    """
    if not detections:
        return False, 0.0
    
    # Get expected YOLO classes for user type
    expected_classes = POLLUTION_TYPE_TO_YOLO.get(user_type, [])
    
    if not expected_classes:
        # Type không có trong YOLO (như noise) → không thể verify
        return False, 0.0
    
    # Get detected classes
    detected_classes = set()
    for det in detections:
        class_name = det.get('class_name', '')
        if class_name:
            detected_classes.add(class_name)
    
    # Check if any detected class matches expected
    has_match = bool(detected_classes.intersection(set(expected_classes)))
    
    if not has_match:
        return False, 0.0
    
    # Calculate confidence score based on matching detections
    matching_detections = [
        d for d in detections 
        if d.get('class_name', '') in expected_classes
    ]
    
    if not matching_detections:
        return False, 0.0
    
    # Average confidence of matching detections
    avg_confidence = sum(d.get('confidence', 0) for d in matching_detections) / len(matching_detections)
    
    return True, avg_confidence


def match_severity(user_severity: str, ai_severity: str) -> Tuple[bool, float]:
    """
    Check if user-selected severity matches AI-calculated severity
    
    Returns: (is_match, score 0-1)
    """
    severity_order = ['low', 'medium', 'high', 'critical']
    
    try:
        user_idx = severity_order.index(user_severity)
        ai_idx = severity_order.index(ai_severity)
    except ValueError:
        return False, 0.0
    
    # Exact match
    if user_idx == ai_idx:
        return True, 1.0
    
    # Close match (1 level difference)
    diff = abs(user_idx - ai_idx)
    if diff == 1:
        return True, 0.7  # 70% score for close match
    
    # Far match (2 levels difference)
    if diff == 2:
        return True, 0.4  # 40% score
    
    # Too far (3 levels difference)
    return False, 0.0


def verify_report(
    user_type: str,
    user_severity: str,
    detections: List[Dict]
) -> Dict:
    """
    Main verification function
    
    Args:
        user_type: User-selected pollution type (e.g., 'air', 'water', 'trash')
        user_severity: User-selected severity ('low', 'medium', 'high', 'critical')
        detections: List of YOLO detections
        
    Returns:
        {
            'verification_status': 'verified' | 'partially_verified' | 'needs_review' | 'rejected',
            'verification_accuracy': float 0-100,
            'ai_severity': 'low' | 'medium' | 'high' | 'critical',
            'points_awarded': int,
            'ai_feedback': str,
            'type_match': bool,
            'type_score': float,
            'severity_match': bool,
            'severity_score': float
        }
    """
    # Calculate AI severity from detections
    ai_severity = calculate_ai_severity(detections)
    
    # Check type matching (60% weight)
    type_match, type_score = match_pollution_type(user_type, detections)
    type_accuracy = type_score * 100  # Convert to 0-100
    
    # Check severity matching (40% weight)
    severity_match, severity_score = match_severity(user_severity, ai_severity)
    severity_accuracy = severity_score * 100
    
    # Calculate overall accuracy (weighted)
    overall_accuracy = (type_accuracy * 0.6) + (severity_accuracy * 0.4)
    
    # Determine verification status and points
    if overall_accuracy >= 90:
        status = 'verified'
        points = 10
    elif overall_accuracy >= 60:
        status = 'partially_verified'
        points = 5
    elif overall_accuracy >= 40:
        status = 'needs_review'
        points = 2
    else:
        status = 'rejected'
        points = 0
    
    # Generate feedback message
    feedback_parts = []
    
    if type_match:
        feedback_parts.append(f"Loại ô nhiễm khớp với AI ({type_accuracy:.0f}%)")
    else:
        feedback_parts.append(f"Loại ô nhiễm không khớp với AI")
    
    if severity_match:
        feedback_parts.append(f"Độ nghiêm trọng khớp với AI ({severity_accuracy:.0f}%)")
    else:
        feedback_parts.append(f"Độ nghiêm trọng: bạn chọn '{user_severity}', AI tính '{ai_severity}'")
    
    if detections:
        detected_types = [CLASS_NAME_VI.get(d.get('class_name', ''), d.get('class_name', '')) for d in detections[:3]]
        feedback_parts.append(f"AI phát hiện: {', '.join(detected_types)}")
    
    ai_feedback = ". ".join(feedback_parts) + "."
    
    logger.info(
        f"Verification: type_match={type_match}({type_accuracy:.1f}%), "
        f"severity_match={severity_match}({severity_accuracy:.1f}%), "
        f"overall={overall_accuracy:.1f}%, status={status}, points={points}"
    )
    
    return {
        'verification_status': status,
        'verification_accuracy': round(overall_accuracy, 2),
        'ai_severity': ai_severity,
        'points_awarded': points,
        'ai_feedback': ai_feedback,
        'type_match': type_match,
        'type_score': type_score,
        'severity_match': severity_match,
        'severity_score': severity_score
    }

