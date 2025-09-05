# API Reference

## Base URL
```
Production: https://api.proofpay.io
Development: http://localhost:8001
```

## Authentication
Currently, API endpoints do not require authentication. This will be added in future versions with JWT tokens.

---

## Attestation Endpoints

### Verify Attestation
Quickly verify if an attestation is valid.

**Endpoint:** `GET /api/attestation/verify/{uid}`

**Parameters:**
- `uid` (path): Attestation UID (hex string)

**Response:**
```json
{
  "uid": "0xabc123...",
  "valid": true
}
```

---

### Get Attestation Details
Retrieve full attestation information including decoded KYC data.

**Endpoint:** `GET /api/attestation/{uid}`

**Parameters:**
- `uid` (path): Attestation UID (hex string)

**Response:**
```json
{
  "uid": "0xabc123...",
  "schema": "0xdef456...",
  "recipient": "0x742d35Cc...",
  "attester": "0x8ba1f109...",
  "time": 1693526400,
  "expirationTime": 0,
  "revocationTime": 0,
  "valid": true,
  "data": {
    "level": 3,
    "timestamp": 1693526400,
    "documentHash": "0x789..."
  }
}
```

---

### Link Attestation
Link an attestation to a user account.

**Endpoint:** `POST /api/attestation/link`

**Request Body:**
```json
{
  "uid": "0xabc123..."
}
```

**Response:**
```json
{
  "success": true,
  "attestation": {
    "uid": "0xabc123...",
    "recipient": "0x742d35Cc...",
    "valid": true
  }
}
```

**Error Responses:**
- `400`: Invalid or expired attestation

---

## User Endpoints

### Create User
Register a new user account.

**Endpoint:** `POST /api/users/`

**Request Body:**
```json
{
  "wallet_address": "0x742d35Cc..."
}
```

**Response:**
```json
{
  "id": "user_123",
  "wallet_address": "0x742d35Cc...",
  "attestation_uid": null,
  "created_at": "2025-08-20T10:00:00",
  "updated_at": "2025-08-20T10:00:00"
}
```

---

### Get User by ID
Retrieve user information by user ID.

**Endpoint:** `GET /api/users/{user_id}`

**Response:** User object

---

### Get User by Wallet
Retrieve user information by wallet address.

**Endpoint:** `GET /api/users/wallet/{wallet_address}`

**Response:** User object

---

### Update User
Update user information.

**Endpoint:** `PATCH /api/users/{user_id}`

**Request Body:**
```json
{
  "attestation_uid": "0xabc123..."
}
```

**Response:** Updated user object

---

### Get User Statistics
Retrieve user payment statistics.

**Endpoint:** `GET /api/users/{user_id}/stats`

**Response:**
```json
{
  "total_payments": 15,
  "total_received": 8,
  "attestation_linked": true,
  "kyc_level": 3
}
```

---

## Error Responses

All endpoints may return the following error responses:

**400 Bad Request**
```json
{
  "detail": "Error message"
}
```

**404 Not Found**
```json
{
  "detail": "Resource not found"
}
```

**500 Internal Server Error**
```json
{
  "detail": "Internal server error"
}
```

---

## Rate Limiting
Currently no rate limiting is implemented. Future versions will include:
- 100 requests per minute per IP
- 1000 requests per hour per IP

---

## Pagination
Endpoints returning lists will support pagination in future versions:
```
?page=1&limit=20
```

---

## Webhooks
Webhook support for payment events is planned for future releases.
