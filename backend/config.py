"""
Application configuration
"""
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # API
    API_TITLE = "ProofPay API"
    API_VERSION = "1.0.0"
    
    # Database
    MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017/proofpay")
    
    # Blockchain
    BASE_RPC_URL = os.getenv("BASE_RPC_URL", "https://mainnet.base.org")
    EAS_CONTRACT_ADDRESS = os.getenv("EAS_CONTRACT_ADDRESS", "0x4200000000000000000000000000000000000021")
    
    # Security
    JWT_SECRET = os.getenv("JWT_SECRET", "your-secret-key")
    RATE_LIMIT_PER_MINUTE = 100

config = Config()
