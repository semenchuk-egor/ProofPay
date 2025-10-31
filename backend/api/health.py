from fastapi import APIRouter

router = APIRouter(tags=["health"])

@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "version": "1.0.0",
        "services": {
            "api": "operational",
            "database": "operational"
        }
    }

@router.get("/ping")
async def ping():
    return {"message": "pong"}
