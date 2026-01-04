"""
Points and Ranking Service
Manages user points, ranks, and statistics
"""
from typing import Dict, Optional
from sqlalchemy.orm import Session
from app.auth.models import User
from app.reports.models import Report
import logging

logger = logging.getLogger(__name__)

# Rank thresholds
RANK_THRESHOLDS = {
    'Người Mới': (0, 49),
    'Eco Warrior': (50, 199),
    'Guardian': (200, 499),
    'Champion': (500, 999),
    'Legend': (1000, float('inf'))
}


def calculate_rank(points: int) -> str:
    """
    Calculate user rank based on points
    
    Args:
        points: User's total points
        
    Returns:
        Rank name
    """
    for rank_name, (min_points, max_points) in RANK_THRESHOLDS.items():
        if min_points <= points <= max_points:
            return rank_name
    
    # Fallback
    return 'Người Mới'


def update_user_points(
    db: Session,
    user_id: str,
    points_to_add: int,
    is_verified: bool = False,
    increment_total_reports: bool = True
) -> User:
    """
    Update user points and statistics
    
    Args:
        db: Database session
        user_id: User ID
        points_to_add: Points to add (can be negative)
        is_verified: Whether this is a verified report
        increment_total_reports: Whether to increment total_reports (default True)
                                 Set to False when admin deletes report to keep count
        
    Returns:
        Updated User object
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise ValueError(f"User {user_id} not found")
    
    # Log before update
    old_points = user.points or 0
    old_total_reports = user.total_reports or 0
    old_verified_reports = user.verified_reports or 0
    
    logger.info(
        f"update_user_points called: user_id={user_id}, "
        f"points_to_add={points_to_add}, is_verified={is_verified}, "
        f"increment_total_reports={increment_total_reports}"
    )
    logger.info(
        f"Current state: points={old_points}, total_reports={old_total_reports}, "
        f"verified_reports={old_verified_reports}, rank={user.rank}"
    )
    
    # Update points
    user.points = old_points + points_to_add
    if user.points < 0:
        user.points = 0
    
    # Update rank
    user.rank = calculate_rank(user.points)
    
    # Update statistics - total_reports only increases, never decreases
    # This ensures that when admin deletes a report, total_reports count remains
    if increment_total_reports:
        user.total_reports = old_total_reports + 1
        logger.info(f"Incremented total_reports: {old_total_reports} → {user.total_reports}")
    if is_verified:
        user.verified_reports = old_verified_reports + 1
        logger.info(f"Incremented verified_reports: {old_verified_reports} → {user.verified_reports}")
    
    # Commit changes
    try:
        db.commit()
        logger.info(f"✅ Committed changes to database")
    except Exception as e:
        logger.error(f"❌ Failed to commit: {e}", exc_info=True)
        db.rollback()
        raise
    
    # Refresh to get latest data
    db.refresh(user)
    
    logger.info(
        f"✅ Updated user {user_id}: "
        f"points: {old_points} → {user.points} (+{points_to_add}), "
        f"rank: {user.rank}, "
        f"total_reports: {old_total_reports} → {user.total_reports}, "
        f"verified_reports: {old_verified_reports} → {user.verified_reports}"
    )
    
    return user


def get_user_stats(db: Session, user_id: str) -> Dict:
    """
    Get user statistics including points, rank, accuracy rate
    
    Args:
        db: Database session
        user_id: User ID
        
    Returns:
        Dictionary with user stats
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise ValueError(f"User {user_id} not found")
    
    # Calculate accuracy rate
    total = user.total_reports or 0
    verified = user.verified_reports or 0
    accuracy_rate = (verified / total * 100) if total > 0 else 0.0
    
    # Get report breakdown by verification status
    reports = db.query(Report).filter(Report.user_id == user_id).all()
    
    status_counts = {
        'verified': 0,
        'partially_verified': 0,
        'needs_review': 0,
        'rejected': 0
    }
    
    for report in reports:
        if report.verification_status:
            status_counts[report.verification_status] = status_counts.get(report.verification_status, 0) + 1
    
    return {
        'user_id': user.id,
        'name': user.name,
        'email': user.email,
        'points': user.points or 0,
        'rank': user.rank or 'Người Mới',
        'total_reports': total,
        'verified_reports': verified,
        'accuracy_rate': round(accuracy_rate, 2),
        'verification_breakdown': status_counts,
        'next_rank': _get_next_rank(user.points or 0),
        'points_to_next_rank': _get_points_to_next_rank(user.points or 0)
    }


def _get_next_rank(current_points: int) -> Optional[str]:
    """Get next rank user can achieve"""
    ranks = ['Người Mới', 'Eco Warrior', 'Guardian', 'Champion', 'Legend']
    current_rank = calculate_rank(current_points)
    
    try:
        current_idx = ranks.index(current_rank)
        if current_idx < len(ranks) - 1:
            return ranks[current_idx + 1]
    except ValueError:
        pass
    
    return None


def _get_points_to_next_rank(current_points: int) -> int:
    """Get points needed to reach next rank"""
    next_rank = _get_next_rank(current_points)
    if not next_rank:
        return 0
    
    min_points = RANK_THRESHOLDS.get(next_rank, (0, 0))[0]
    return max(0, min_points - current_points)

