# API Authentication

## Overview
ProofPay API uses JWT (JSON Web Tokens) for authentication.

## Getting Started

### 1. Connect Wallet
```javascript
const signature = await signer.signMessage("Sign in to ProofPay");
```

### 2. Request Token
```bash
POST /api/auth/login
{
  "wallet_address": "0x...",
  "signature": "0x..."
}
```

### 3. Use Token
```bash
Authorization: Bearer <your_jwt_token>
```

## Token Expiration
Tokens expire after 24 hours. Refresh before expiration.

## Rate Limits
- 100 requests per minute
- 1000 requests per hour
