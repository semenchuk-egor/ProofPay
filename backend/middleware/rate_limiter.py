"""
Rate limiting middleware
"""
from fastapi import HTTPException, Request
from datetime import datetime, timedelta
from typing import Dict

class RateLimiter:
    def __init__(self, requests_per_minute: int = 100):
        self.requests_per_minute = requests_per_minute
        self.requests: Dict[str, list] = {}
    
    def check_rate_limit(self, client_ip: str) -> bool:
        now = datetime.utcnow()
        minute_ago = now - timedelta(minutes=1)
        
        if client_ip not in self.requests:
            self.requests[client_ip] = []
        
        # Clean old requests
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if req_time > minute_ago
        ]
        
        if len(self.requests[client_ip]) >= self.requests_per_minute:
            return False
        
        self.requests[client_ip].append(now)
        return True

rate_limiter = RateLimiter()
