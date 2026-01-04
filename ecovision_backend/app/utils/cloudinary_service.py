"""
Cloudinary service for image upload and management
"""
import cloudinary
import cloudinary.uploader
import cloudinary.api
from typing import Optional, Dict, Any
from app.config import settings
import logging

logger = logging.getLogger(__name__)

# Flag to track if Cloudinary is initialized
_cloudinary_initialized = False


def _ensure_cloudinary_initialized():
    """Initialize Cloudinary if not already initialized"""
    global _cloudinary_initialized
    if not _cloudinary_initialized:
        if settings.CLOUDINARY_CLOUD_NAME and settings.CLOUDINARY_API_KEY and settings.CLOUDINARY_API_SECRET:
            try:
                cloudinary.config(
                    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
                    api_key=settings.CLOUDINARY_API_KEY,
                    api_secret=settings.CLOUDINARY_API_SECRET,
                    secure=True
                )
                _cloudinary_initialized = True
                logger.info("Cloudinary initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Cloudinary: {str(e)}")
                _cloudinary_initialized = False
                raise
        else:
            logger.warning("Cloudinary credentials not configured")
            _cloudinary_initialized = False
            raise ValueError("Cloudinary credentials not configured")


class CloudinaryService:
    """Service for Cloudinary operations"""
    
    @staticmethod
    def upload_image(
        image_bytes: bytes,
        folder: str = "ecovision/reports",
        public_id: Optional[str] = None,
        transformation: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Upload image to Cloudinary
        
        Args:
            image_bytes: Image file bytes
            folder: Cloudinary folder path
            public_id: Optional public ID (if not provided, Cloudinary generates one)
            transformation: Optional transformation parameters
        
        Returns:
            Dict with upload result containing 'secure_url', 'public_id', etc.
        """
        _ensure_cloudinary_initialized()
        try:
            upload_options = {
                "folder": folder,
                "resource_type": "image",
            }
            
            if public_id:
                upload_options["public_id"] = public_id
            
            if transformation:
                upload_options["transformation"] = transformation
            
            # Upload to Cloudinary
            result = cloudinary.uploader.upload(
                image_bytes,
                **upload_options
            )
            
            logger.info(f"Image uploaded to Cloudinary: {result.get('public_id')}")
            return result
            
        except Exception as e:
            logger.error(f"Error uploading to Cloudinary: {str(e)}")
            raise Exception(f"Failed to upload image to Cloudinary: {str(e)}")
    
    @staticmethod
    def upload_image_with_thumbnail(
        image_bytes: bytes,
        folder: str = "ecovision/reports",
        public_id: Optional[str] = None
    ) -> Dict[str, str]:
        """
        Upload image and generate thumbnail
        
        Returns:
            Dict with 'image_url' and 'thumbnail_url'
        """
        _ensure_cloudinary_initialized()
        try:
            # Upload original image
            original_result = CloudinaryService.upload_image(
                image_bytes=image_bytes,
                folder=folder,
                public_id=public_id
            )
            
            # Generate thumbnail URL (using Cloudinary transformation)
            public_id = original_result.get('public_id')
            thumbnail_url = cloudinary.CloudinaryImage(public_id).build_url(
                transformation=[
                    {'width': 300, 'height': 300, 'crop': 'fill', 'quality': 'auto'}
                ]
            )
            
            return {
                "image_url": original_result.get('secure_url'),
                "thumbnail_url": thumbnail_url,
                "public_id": public_id
            }
            
        except Exception as e:
            logger.error(f"Error uploading image with thumbnail: {str(e)}")
            raise
    
    @staticmethod
    def delete_image(public_id: str) -> bool:
        """
        Delete image from Cloudinary
        
        Args:
            public_id: Cloudinary public ID
        
        Returns:
            True if successful, False otherwise
        """
        _ensure_cloudinary_initialized()
        try:
            result = cloudinary.uploader.destroy(public_id)
            return result.get('result') == 'ok'
        except Exception as e:
            logger.error(f"Error deleting image from Cloudinary: {str(e)}")
            return False
    
    @staticmethod
    def generate_url(
        public_id: str,
        transformation: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Generate Cloudinary URL with optional transformations
        
        Args:
            public_id: Cloudinary public ID
            transformation: Optional transformation parameters
        
        Returns:
            Cloudinary URL
        """
        _ensure_cloudinary_initialized()
        try:
            if transformation:
                return cloudinary.CloudinaryImage(public_id).build_url(
                    transformation=[transformation]
                )
            else:
                return cloudinary.CloudinaryImage(public_id).build_url()
        except Exception as e:
            logger.error(f"Error generating Cloudinary URL: {str(e)}")
            raise

