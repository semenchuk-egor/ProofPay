# Deployment Guide

## Prerequisites
- Node.js 18+
- Python 3.11+
- Foundry
- MongoDB

## Smart Contracts Deployment

### 1. Configure Environment
```bash
cp contracts/.env.example contracts/.env
# Edit with your private key and network details
```

### 2. Deploy to Base Testnet
```bash
cd contracts
forge script script/DeployAll.s.sol --rpc-url base-goerli --broadcast --verify
```

### 3. Deploy to Base Mainnet
```bash
forge script script/DeployAll.s.sol --rpc-url base --broadcast --verify
```

## Backend Deployment

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment
```bash
cp .env.example .env
# Add your configuration
```

### 3. Start Server
```bash
uvicorn server:app --host 0.0.0.0 --port 8001
```

## Frontend Deployment

### 1. Install Dependencies
```bash
cd frontend
yarn install
```

### 2. Build for Production
```bash
yarn build
```

### 3. Deploy
- Vercel: `vercel --prod`
- Netlify: `netlify deploy --prod`
- AWS S3: Upload build/ directory

## Post-Deployment

1. Verify all contracts on Basescan
2. Test all API endpoints
3. Monitor logs for errors
4. Set up alerts
