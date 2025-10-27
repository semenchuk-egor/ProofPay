"""
Cryptographic utilities
"""
import hashlib
from eth_account.messages import encode_defunct
from web3 import Web3

def hash_message(message: str) -> str:
    return hashlib.sha256(message.encode()).hexdigest()

def verify_signature(message: str, signature: str, address: str) -> bool:
    try:
        w3 = Web3()
        message_hash = encode_defunct(text=message)
        recovered_address = w3.eth.account.recover_message(message_hash, signature=signature)
        return recovered_address.lower() == address.lower()
    except:
        return False
