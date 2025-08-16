"""
EAS (Ethereum Attestation Service) integration service
"""
from web3 import Web3
from typing import Dict, Optional
import os

class EASService:
    """Service for interacting with Ethereum Attestation Service"""
    
    def __init__(self):
        # Base network RPC
        self.w3 = Web3(Web3.HTTPProvider(os.getenv('BASE_RPC_URL', 'https://mainnet.base.org')))
        self.eas_address = os.getenv('EAS_CONTRACT_ADDRESS', '0x4200000000000000000000000000000000000021')
        
        # EAS ABI (simplified)
        self.eas_abi = [
            {
                "inputs": [{"name": "uid", "type": "bytes32"}],
                "name": "getAttestation",
                "outputs": [
                    {
                        "components": [
                            {"name": "uid", "type": "bytes32"},
                            {"name": "schema", "type": "bytes32"},
                            {"name": "time", "type": "uint64"},
                            {"name": "expirationTime", "type": "uint64"},
                            {"name": "revocationTime", "type": "uint64"},
                            {"name": "refUID", "type": "bytes32"},
                            {"name": "recipient", "type": "address"},
                            {"name": "attester", "type": "address"},
                            {"name": "revocable", "type": "bool"},
                            {"name": "data", "type": "bytes"}
                        ],
                        "name": "",
                        "type": "tuple"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            }
        ]
        
        self.contract = self.w3.eth.contract(
            address=Web3.to_checksum_address(self.eas_address),
            abi=self.eas_abi
        )
    
    def get_attestation(self, uid: str) -> Optional[Dict]:
        """
        Get attestation by UID
        
        Args:
            uid: Attestation unique identifier (hex string)
            
        Returns:
            Attestation data or None if not found
        """
        try:
            uid_bytes = bytes.fromhex(uid.replace('0x', ''))
            attestation = self.contract.functions.getAttestation(uid_bytes).call()
            
            return {
                'uid': attestation[0].hex(),
                'schema': attestation[1].hex(),
                'time': attestation[2],
                'expirationTime': attestation[3],
                'revocationTime': attestation[4],
                'refUID': attestation[5].hex(),
                'recipient': attestation[6],
                'attester': attestation[7],
                'revocable': attestation[8],
                'data': attestation[9].hex()
            }
        except Exception as e:
            print(f"Error fetching attestation: {e}")
            return None
    
    def verify_attestation(self, uid: str) -> bool:
        """
        Verify if attestation is valid
        
        Args:
            uid: Attestation unique identifier
            
        Returns:
            True if valid, False otherwise
        """
        attestation = self.get_attestation(uid)
        
        if not attestation:
            return False
        
        # Check if revoked
        if attestation['revocationTime'] > 0:
            return False
        
        # Check if expired
        import time
        current_time = int(time.time())
        if attestation['expirationTime'] > 0 and attestation['expirationTime'] < current_time:
            return False
        
        return True
    
    def decode_kyc_data(self, data_hex: str) -> Optional[Dict]:
        """
        Decode KYC attestation data
        
        Args:
            data_hex: Hex encoded attestation data
            
        Returns:
            Decoded KYC data
        """
        try:
            from eth_abi import decode
            data_bytes = bytes.fromhex(data_hex.replace('0x', ''))
            
            # Decode: (uint8 level, uint256 timestamp, bytes32 documentHash)
            decoded = decode(['uint8', 'uint256', 'bytes32'], data_bytes)
            
            return {
                'level': decoded[0],
                'timestamp': decoded[1],
                'documentHash': decoded[2].hex()
            }
        except Exception as e:
            print(f"Error decoding KYC data: {e}")
            return None


# Singleton instance
eas_service = EASService()
