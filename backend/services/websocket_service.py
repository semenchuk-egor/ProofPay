from fastapi import WebSocket
from typing import Dict, Set
import json

class WebSocketService:
    def __init__(self):
        self.active_connections: Dict[str, Set[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, address: str):
        await websocket.accept()
        
        if address not in self.active_connections:
            self.active_connections[address] = set()
        
        self.active_connections[address].add(websocket)
    
    def disconnect(self, websocket: WebSocket, address: str):
        if address in self.active_connections:
            self.active_connections[address].discard(websocket)
            
            if not self.active_connections[address]:
                del self.active_connections[address]
    
    async def send_personal_message(self, message: dict, websocket: WebSocket):
        await websocket.send_text(json.dumps(message))
    
    async def broadcast_to_address(self, message: dict, address: str):
        if address in self.active_connections:
            for connection in self.active_connections[address]:
                try:
                    await connection.send_text(json.dumps(message))
                except:
                    pass
    
    async def broadcast_payment_update(self, payment_data: dict):
        sender = payment_data.get('sender')
        recipient = payment_data.get('recipient')
        
        message = {
            'type': 'payment_update',
            'data': payment_data
        }
        
        await self.broadcast_to_address(message, sender)
        await self.broadcast_to_address(message, recipient)

websocket_service = WebSocketService()
