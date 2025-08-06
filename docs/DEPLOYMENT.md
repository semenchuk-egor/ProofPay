# Deployment Guide

## Prerequisites
- Foundry installed
- Node.js 18+
- Python 3.11+
- MongoDB
- Base RPC access
- Private keys for deployment

## Smart Contracts Deployment

### 1. Install Dependencies
```bash
cd contracts
forge install
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your values
```

Required variables:
- `PRIVATE_KEY`: Deployer private key
- `BASESCAN_API_KEY`: For contract verification
- `BASE_RPC_URL`: Base network RPC

### 3. Deploy to Base Sepolia (Testnet)
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base-sepolia \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY
```

### 4. Deploy to Base Mainnet
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY
```

## Backend Deployment

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment
```bash
MONGO_URL=mongodb://localhost:27017
DB_NAME=proofpay
JWT_SECRET=your-secret-key
BASE_RPC_URL=https://mainnet.base.org
```

### 3. Run with Docker
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 4. Deploy to Cloud
- **AWS**: Use ECS/Fargate
- **Google Cloud**: Use Cloud Run
- **Heroku**: Direct deployment

## Frontend Deployment

### 1. Install Dependencies
```bash
cd frontend
npm install
```

### 2. Configure Environment
```bash
REACT_APP_BACKEND_URL=https://api.proofpay.xyz
REACT_APP_PAYMENT_PROCESSOR_ADDRESS=0x...
REACT_APP_CHAIN_ID=8453
```

### 3. Build
```bash
npm run build
```

### 4. Deploy
- **Vercel**: Connect GitHub repo
- **Netlify**: Drag & drop build folder
- **S3 + CloudFront**: Upload to S3, configure CloudFront

## Post-Deployment

### 1. Verify Contracts
```bash
forge verify-contract <address> <contract> \
  --chain-id 8453 \
  --etherscan-api-key $BASESCAN_API_KEY
```

### 2. Initialize Contracts
- Add trusted attesters to AttestationVerifier
- Set platform fee in PaymentProcessor
- Transfer ownership if needed

### 3. Monitor
- Set up monitoring for API endpoints
- Configure alerts for contract events
- Monitor gas usage and optimize

## Security Checklist
- [ ] Private keys secured
- [ ] HTTPS enabled
- [ ] Rate limiting configured
- [ ] CORS properly set
- [ ] Database backup enabled
- [ ] Contracts audited
- [ ] Multi-sig for admin functions
