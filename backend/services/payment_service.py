from models.payment import Payment
from config.database import get_database
from typing import List, Optional
from datetime import datetime

class PaymentService:
    def __init__(self):
        self.db = None
    
    async def _get_collection(self):
        if not self.db:
            self.db = await get_database()
        return self.db['payments']
    
    async def create_payment(self, payment_data: dict) -> Payment:
        """Create new payment record"""
        collection = await self._get_collection()
        
        payment = Payment(
            payment_id=payment_data['payment_id'],
            sender=payment_data['sender'],
            recipient=payment_data['recipient'],
            amount=payment_data['amount'],
            attestation_uid=payment_data.get('attestation_uid'),
            timestamp=datetime.utcnow(),
            status='pending'
        )
        
        await collection.insert_one(payment.dict())
        return payment
    
    async def get_payment(self, payment_id: str) -> Optional[Payment]:
        """Get payment by ID"""
        collection = await self._get_collection()
        payment_data = await collection.find_one({'payment_id': payment_id})
        
        if payment_data:
            return Payment(**payment_data)
        return None
    
    async def list_payments(
        self, 
        address: Optional[str] = None,
        filter_type: str = 'all'
    ) -> List[Payment]:
        """List payments with optional filtering"""
        collection = await self._get_collection()
        
        query = {}
        if address:
            if filter_type == 'sent':
                query['sender'] = address
            elif filter_type == 'received':
                query['recipient'] = address
            else:  # all
                query['$or'] = [{'sender': address}, {'recipient': address}]
        
        cursor = collection.find(query).sort('timestamp', -1).limit(100)
        payments = await cursor.to_list(length=100)
        
        return [Payment(**p) for p in payments]
    
    async def update_payment_status(self, payment_id: str, status: str) -> bool:
        """Update payment status"""
        collection = await self._get_collection()
        result = await collection.update_one(
            {'payment_id': payment_id},
            {'$set': {'status': status}}
        )
        return result.modified_count > 0
    
    async def get_user_stats(self, address: str) -> dict:
        """Get user payment statistics"""
        collection = await self._get_collection()
        
        pipeline = [
            {'$match': {'$or': [{'sender': address}, {'recipient': address}]}},
            {'$group': {
                '_id': None,
                'total_sent': {'$sum': {'$cond': [{'$eq': ['$sender', address]}, '$amount', 0]}},
                'total_received': {'$sum': {'$cond': [{'$eq': ['$recipient', address]}, '$amount', 0]}},
                'total_payments': {'$sum': 1}
            }}
        ]
        
        result = await collection.aggregate(pipeline).to_list(length=1)
        
        if result:
            return result[0]
        return {'total_sent': 0, 'total_received': 0, 'total_payments': 0}
