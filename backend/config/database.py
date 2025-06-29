from motor.motor_asyncio import AsyncIOMotorClient
import os

class Database:
    client: AsyncIOMotorClient = None
    
    @classmethod
    async def connect_db(cls):
        cls.client = AsyncIOMotorClient(os.getenv('MONGO_URL', 'mongodb://localhost:27017'))
        return cls.client['proofpay']
    
    @classmethod
    async def close_db(cls):
        if cls.client:
            cls.client.close()

async def get_database():
    return await Database.connect_db()
