# ProofPay Architecture

## Overview

ProofPay is a decentralized payment system that enables payments without KYC using on-chain proof verification through Ethereum Attestation Service (EAS) on Base blockchain.

## System Components

### Smart Contracts (Solidity)

#### Core Contracts
- **PaymentProcessor**: Main contract for processing payments with attestation verification
- **AttestationVerifier**: Verifies EAS attestations for payment authorization
- **PaymentStorage**: Centralized storage for payment data with mappings and structs

#### Token Contracts
- **ProofToken (PROOF)**: ERC-20 utility token for the platform
- **PaymentProofNFT**: ERC-721 NFT representing payment proofs

#### Libraries
- **PaymentDataEncoder**: Encodes/decodes payment data for attestations

#### Patterns Used
- UUPS Proxy Pattern for upgradeability
- ReentrancyGuard for security
- Custom errors for gas efficiency
- Event-driven architecture

### Backend (FastAPI + Python)

#### API Routes
- `/api/payments`: Payment creation and retrieval
- `/api/attestations`: EAS attestation management
- `/api/auth`: JWT authentication

#### Services
- **EASService**: Integration with Ethereum Attestation Service
- **PaymentService**: Business logic for payments

#### Database
- MongoDB for payment history and metadata

### Frontend (React)

#### Components
- **WalletConnect**: Wallet connection management
- **PaymentForm**: Payment creation interface
- **Dashboard**: Main user interface

#### Hooks
- **useWeb3**: Web3 provider and wallet management

#### Services
- API client with axios
- Authentication management

## Data Flow

1. User connects wallet (MetaMask/WalletConnect)
2. User creates payment through frontend
3. Frontend calls backend to create EAS attestation
4. Backend interacts with EAS contract on Base
5. Frontend calls PaymentProcessor contract with attestation UID
6. Contract verifies attestation through AttestationVerifier
7. Payment is processed and NFT proof is minted
8. Event is emitted and indexed

## Security

- All contracts use UUPS proxy pattern for upgradeability
- ReentrancyGuard prevents reentrancy attacks
- Trusted attesters whitelist
- JWT authentication for backend
- Signature-based wallet authentication

## Deployment

### Smart Contracts
Deployed on Base Sepolia testnet and Base mainnet using Foundry.

### Backend
FastAPI application running on cloud infrastructure.

### Frontend
React SPA deployed on Vercel/Netlify.

## Integration

### Ethereum Attestation Service (EAS)
- Contract: 0x4200000000000000000000000000000000000021 (Base)
- Used for creating payment attestations
- Provides on-chain proof without revealing sensitive data
