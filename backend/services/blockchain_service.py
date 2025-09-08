"""
Blockchain interaction service
"""
from web3 import Web3
from typing import Dict, Optional
import os
import json

class BlockchainService:
    """Service for interacting with Base blockchain"""
    
    def __init__(self):
        # Base network configuration
        self.w3 = Web3(Web3.HTTPProvider(os.getenv('BASE_RPC_URL', 'https://mainnet.base.org')))
        self.chain_id = 8453
        
        # Contract addresses
        self.payment_validator_address = os.getenv('PAYMENT_VALIDATOR_ADDRESS')
        self.proof_token_address = os.getenv('PROOF_TOKEN_ADDRESS')
        
        # Load ABIs
        self.payment_validator_abi = self._load_abi('PaymentValidator')
        self.erc20_abi = self._load_abi('ERC20')
    
    def _load_abi(self, contract_name: str) -> list:
        """Load contract ABI from file"""
        # Placeholder - in production, load from compiled contracts
        if contract_name == 'PaymentValidator':
            return []  # TODO: Load actual ABI
        elif contract_name == 'ERC20':
            return [
                {
                    "constant": True,
                    "inputs": [{"name": "account", "type": "address"}],
                    "name": "balanceOf",
                    "outputs": [{"name": "", "type": "uint256"}],
                    "type": "function"
                },
                {
                    "constant": False,
                    "inputs": [
                        {"name": "recipient", "type": "address"},
                        {"name": "amount", "type": "uint256"}
                    ],
                    "name": "transfer",
                    "outputs": [{"name": "", "type": "bool"}],
                    "type": "function"
                }
            ]
        return []
    
    def get_balance(self, address: str) -> float:
        """Get ETH balance for address"""
        try:
            balance_wei = self.w3.eth.get_balance(Web3.to_checksum_address(address))
            return float(self.w3.from_wei(balance_wei, 'ether'))
        except Exception as e:
            print(f"Error getting balance: {e}")
            return 0.0
    
    def get_token_balance(self, token_address: str, wallet_address: str) -> float:
        """Get ERC20 token balance"""
        try:
            contract = self.w3.eth.contract(
                address=Web3.to_checksum_address(token_address),
                abi=self.erc20_abi
            )
            balance = contract.functions.balanceOf(
                Web3.to_checksum_address(wallet_address)
            ).call()
            return float(self.w3.from_wei(balance, 'ether'))
        except Exception as e:
            print(f"Error getting token balance: {e}")
            return 0.0
    
    def get_transaction(self, tx_hash: str) -> Optional[Dict]:
        """Get transaction details"""
        try:
            tx = self.w3.eth.get_transaction(tx_hash)
            receipt = self.w3.eth.get_transaction_receipt(tx_hash)
            
            return {
                'hash': tx_hash,
                'from': tx['from'],
                'to': tx['to'],
                'value': str(tx['value']),
                'gas_used': receipt['gasUsed'],
                'status': receipt['status'],
                'block_number': receipt['blockNumber']
            }
        except Exception as e:
            print(f"Error getting transaction: {e}")
            return None
    
    def verify_transaction(self, tx_hash: str, expected_from: str, expected_to: str) -> bool:
        """Verify transaction details"""
        tx = self.get_transaction(tx_hash)
        if not tx:
            return False
        
        return (
            tx['from'].lower() == expected_from.lower() and
            tx['to'].lower() == expected_to.lower() and
            tx['status'] == 1
        )
    
    def estimate_gas(self, from_address: str, to_address: str, value: int) -> int:
        """Estimate gas for transaction"""
        try:
            gas_estimate = self.w3.eth.estimate_gas({
                'from': Web3.to_checksum_address(from_address),
                'to': Web3.to_checksum_address(to_address),
                'value': value
            })
            return gas_estimate
        except Exception as e:
            print(f"Error estimating gas: {e}")
            return 21000  # Default gas limit
    
    def get_gas_price(self) -> int:
        """Get current gas price"""
        try:
            return self.w3.eth.gas_price
        except Exception as e:
            print(f"Error getting gas price: {e}")
            return self.w3.to_wei(1, 'gwei')


# Singleton instance
blockchain_service = BlockchainService()
