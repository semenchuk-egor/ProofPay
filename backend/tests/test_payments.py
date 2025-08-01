import pytest
from services.payment_service import PaymentService
from models.payment import Payment

@pytest.mark.asyncio
async def test_create_payment():
    service = PaymentService()
    
    payment_data = {
        'payment_id': '0x123',
        'sender': '0xabc',
        'recipient': '0xdef',
        'amount': 0.1,
        'attestation_uid': '0x456'
    }
    
    payment = await service.create_payment(payment_data)
    
    assert payment.payment_id == '0x123'
    assert payment.sender == '0xabc'
    assert payment.status == 'pending'

@pytest.mark.asyncio
async def test_get_payment():
    service = PaymentService()
    
    # Create payment first
    payment_data = {
        'payment_id': '0x789',
        'sender': '0xabc',
        'recipient': '0xdef',
        'amount': 0.1
    }
    await service.create_payment(payment_data)
    
    # Get payment
    payment = await service.get_payment('0x789')
    assert payment is not None
    assert payment.payment_id == '0x789'

@pytest.mark.asyncio
async def test_list_payments():
    service = PaymentService()
    
    payments = await service.list_payments(address='0xabc')
    assert isinstance(payments, list)
