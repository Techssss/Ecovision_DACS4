"""
Embeddings service for semantic search
"""
from typing import List, Optional
import openai
from app.config import settings


class EmbeddingsService:
    """Embeddings service for semantic search"""
    
    def __init__(self):
        if settings.OPENAI_API_KEY:
            openai.api_key = settings.OPENAI_API_KEY
    
    async def get_embedding(self, text: str) -> Optional[List[float]]:
        """Get embedding for text"""
        if not settings.OPENAI_API_KEY:
            return None
        
        try:
            response = openai.Embedding.create(
                model=settings.EMBEDDING_MODEL,
                input=text
            )
            return response["data"][0]["embedding"]
        except Exception as e:
            print(f"Error getting embedding: {e}")
            return None
    
    async def get_embeddings(self, texts: List[str]) -> List[Optional[List[float]]]:
        """Get embeddings for multiple texts"""
        if not settings.OPENAI_API_KEY:
            return [None] * len(texts)
        
        try:
            response = openai.Embedding.create(
                model=settings.EMBEDDING_MODEL,
                input=texts
            )
            return [item["embedding"] for item in response["data"]]
        except Exception as e:
            print(f"Error getting embeddings: {e}")
            return [None] * len(texts)


embeddings_service = EmbeddingsService()

