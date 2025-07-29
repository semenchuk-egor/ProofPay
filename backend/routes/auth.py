from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from middleware.auth import create_access_token, create_signature_challenge, verify_token
from eth_account.messages import encode_defunct
from web3 import Web3
import os

router = APIRouter(prefix='/api/auth', tags=['auth'])

class ChallengeRequest(BaseModel):
    address: str

class VerifyRequest(BaseModel):
    address: str
    signature: str
    message: str

@router.post('/challenge')
async def get_challenge(request: ChallengeRequest):
    """Generate authentication challenge for wallet signature"""
    if not Web3.is_address(request.address):
        raise HTTPException(status_code=400, detail='Invalid address')
    
    message = create_signature_challenge(request.address)
    
    return {
        'message': message,
        'address': request.address
    }

@router.post('/verify')
async def verify_signature(request: VerifyRequest):
    """Verify wallet signature and issue JWT token"""
    if not Web3.is_address(request.address):
        raise HTTPException(status_code=400, detail='Invalid address')
    
    try:
        # Verify signature
        w3 = Web3()
        message = encode_defunct(text=request.message)
        recovered_address = w3.eth.account.recover_message(message, signature=request.signature)
        
        if recovered_address.lower() != request.address.lower():
            raise HTTPException(status_code=401, detail='Invalid signature')
        
        # Create JWT token
        access_token = create_access_token({
            'address': request.address,
            'type': 'wallet'
        })
        
        return {
            'access_token': access_token,
            'token_type': 'bearer',
            'address': request.address
        }
        
    except Exception as e:
        raise HTTPException(status_code=401, detail=f'Verification failed: {str(e)}')

@router.get('/me')
async def get_current_user_info(current_user: dict = Depends(verify_token)):
    """Get current authenticated user info"""
    return {
        'address': current_user.get('address'),
        'type': current_user.get('type')
    }
