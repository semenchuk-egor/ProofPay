from fastapi import APIRouter

router = APIRouter(prefix="/api/analytics", tags=["analytics"])

@router.get("/stats")
async def get_platform_stats():
    return {
        "total_users": 0,
        "total_transactions": 0,
        "total_volume": "0",
        "active_users_24h": 0
    }

@router.get("/user/{wallet_address}/stats")
async def get_user_analytics(wallet_address: str):
    return {
        "wallet": wallet_address,
        "total_sent": "0",
        "total_received": "0",
        "transaction_count": 0
    }
