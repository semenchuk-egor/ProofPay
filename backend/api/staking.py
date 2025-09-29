"""
Staking API endpoints
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/api/staking", tags=["staking"])


class StakeRequest(BaseModel):
    amount: str
    wallet_address: str


class StakeInfo(BaseModel):
    wallet_address: str
    staked_amount: str
    rewards: str
    timestamp: int


@router.post("/stake")
async def stake_tokens(request: StakeRequest):
    """Stake PROOF tokens"""
    return {
        "success": True,
        "tx_hash": "0xabc...",
        "amount": request.amount
    }


@router.post("/unstake")
async def unstake_tokens(request: StakeRequest):
    """Unstake PROOF tokens"""
    return {
        "success": True,
        "tx_hash": "0xdef...",
        "amount": request.amount
    }


@router.get("/{wallet_address}", response_model=StakeInfo)
async def get_stake_info(wallet_address: str):
    """Get staking information for wallet"""
    return StakeInfo(
        wallet_address=wallet_address,
        staked_amount="0",
        rewards="0",
        timestamp=0
    )


@router.post("/claim-rewards")
async def claim_rewards(wallet_address: str):
    """Claim staking rewards"""
    return {
        "success": True,
        "tx_hash": "0xghi...",
        "rewards": "0"
    }
