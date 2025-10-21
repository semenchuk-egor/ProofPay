"""
Simple caching service
"""
from datetime import datetime, timedelta
from typing import Any, Optional

class CacheService:
    def __init__(self):
        self.cache = {}
    
    def get(self, key: str) -> Optional[Any]:
        if key in self.cache:
            entry = self.cache[key]
            if entry['expires_at'] > datetime.utcnow():
                return entry['value']
            else:
                del self.cache[key]
        return None
    
    def set(self, key: str, value: Any, ttl_seconds: int = 300):
        self.cache[key] = {
            'value': value,
            'expires_at': datetime.utcnow() + timedelta(seconds=ttl_seconds)
        }
    
    def delete(self, key: str):
        if key in self.cache:
            del self.cache[key]

cache_service = CacheService()
