"""
File handling utilities
"""
import os
import uuid
from pathlib import Path
from typing import Optional
from fastapi import UploadFile
from PIL import Image
import io
from app.config import settings


def ensure_upload_dir() -> Path:
    """Ensure upload directory exists"""
    upload_path = Path(settings.UPLOAD_DIR)
    upload_path.mkdir(parents=True, exist_ok=True)
    return upload_path


async def save_uploaded_file(
    file: UploadFile,
    subdirectory: str = "",
    max_size: int = None
) -> Optional[str]:
    """
    Save uploaded file and return file path
    """
    if max_size is None:
        max_size = settings.MAX_UPLOAD_SIZE
    
    # Validate file size
    contents = await file.read()
    if len(contents) > max_size:
        raise ValueError(f"File size exceeds maximum allowed size of {max_size} bytes")
    
    # Validate file extension
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in settings.ALLOWED_EXTENSIONS:
        raise ValueError(f"File type {file_ext} not allowed")
    
    # Generate unique filename
    filename = f"{uuid.uuid4()}{file_ext}"
    
    # Create subdirectory if specified
    upload_dir = ensure_upload_dir()
    if subdirectory:
        upload_dir = upload_dir / subdirectory
        upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Save file
    file_path = upload_dir / filename
    with open(file_path, "wb") as f:
        f.write(contents)
    
    # Return relative path
    return str(file_path.relative_to(Path(settings.UPLOAD_DIR)))


async def compress_image(
    image_data: bytes,
    max_size: int = 1024 * 1024,  # 1MB
    quality: int = 85
) -> bytes:
    """
    Compress image to reduce file size
    """
    try:
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary
        if image.mode in ("RGBA", "P"):
            background = Image.new("RGB", image.size, (255, 255, 255))
            if image.mode == "P":
                image = image.convert("RGBA")
            background.paste(image, mask=image.split()[-1] if image.mode == "RGBA" else None)
            image = background
        
        # Compress
        output = io.BytesIO()
        image.save(output, format="JPEG", quality=quality, optimize=True)
        compressed_data = output.getvalue()
        
        # If still too large, reduce quality
        while len(compressed_data) > max_size and quality > 50:
            quality -= 10
            output = io.BytesIO()
            image.save(output, format="JPEG", quality=quality, optimize=True)
            compressed_data = output.getvalue()
        
        return compressed_data
    except Exception as e:
        raise ValueError(f"Failed to compress image: {str(e)}")


def delete_file(file_path: str) -> bool:
    """Delete a file"""
    try:
        full_path = Path(settings.UPLOAD_DIR) / file_path
        if full_path.exists():
            full_path.unlink()
            return True
        return False
    except Exception:
        return False

