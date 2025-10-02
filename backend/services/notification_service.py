"""
Notification service for user alerts
"""
from typing import List, Dict
from datetime import datetime

class NotificationService:
    def __init__(self):
        self.notifications = {}
    
    def send_payment_notification(
        self,
        user_id: str,
        payment_id: str,
        amount: str,
        type: str
    ):
        """Send payment notification to user"""
        notification = {
            'id': f"notif_{datetime.now().timestamp()}",
            'user_id': user_id,
            'type': 'payment',
            'title': f'Payment {"Received" if type == "received" else "Sent"}',
            'message': f'Amount: {amount} ETH',
            'timestamp': datetime.utcnow(),
            'read': False
        }
        
        if user_id not in self.notifications:
            self.notifications[user_id] = []
        
        self.notifications[user_id].append(notification)
        return notification
    
    def get_user_notifications(
        self,
        user_id: str,
        unread_only: bool = False
    ) -> List[Dict]:
        """Get notifications for user"""
        user_notifs = self.notifications.get(user_id, [])
        
        if unread_only:
            return [n for n in user_notifs if not n['read']]
        
        return user_notifs
    
    def mark_as_read(self, user_id: str, notification_id: str):
        """Mark notification as read"""
        user_notifs = self.notifications.get(user_id, [])
        
        for notif in user_notifs:
            if notif['id'] == notification_id:
                notif['read'] = True
                break

notification_service = NotificationService()
