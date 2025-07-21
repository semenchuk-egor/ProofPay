# ProofPay API Documentation

## Base URL
```
https://api.proofpay.xyz
```

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

### Get Authentication Challenge
```http
POST /api/auth/challenge
Content-Type: application/json

{
  "address": "0x..."
}
```

**Response:**
```json
{
  "message": "Sign this message to authenticate...",
  "nonce": "..."
}
```

### Verify Signature
```http
POST /api/auth/verify
Content-Type: application/json

{
  "address": "0x...",
  "signature": "0x..."
}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "token_type": "bearer"
}
```

## Payments

### Create Payment
```http
POST /api/payments
Content-Type: application/json
Authorization: Bearer <token>

{
  "sender": "0x...",
  "recipient": "0x...",
  "amount": 0.1,
  "description": "Payment for services"
}
```

**Response:**
```json
{
  "status": "success",
  "attestation_uid": "0x...",
  "message": "Payment attestation created"
}
```

### Get Payment
```http
GET /api/payments/{payment_id}
```

**Response:**
```json
{
  "payment_id": "0x...",
  "sender": "0x...",
  "recipient": "0x...",
  "amount": 0.1,
  "status": "completed",
  "timestamp": 1234567890
}
```

### List Payments
```http
GET /api/payments?address=0x...
```

## Attestations

### Create Attestation
```http
POST /api/attestations
Content-Type: application/json

{
  "recipient": "0x...",
  "amount": 0.1,
  "description": "Payment attestation"
}
```

**Response:**
```json
{
  "uid": "0x...",
  "schema": "0x...",
  "recipient": "0x...",
  "attester": "0x...",
  "timestamp": 1234567890
}
```

### Get Attestation
```http
GET /api/attestations/{uid}
```

### Verify Attestation
```http
POST /api/attestations/{uid}/verify
```

**Response:**
```json
{
  "uid": "0x...",
  "valid": true,
  "verified_at": 1234567890
}
```

## Error Responses

```json
{
  "detail": "Error message",
  "status_code": 400
}
```

### Status Codes
- `200 OK` - Success
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Authentication required
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error
