# ProofPay

> KYC-free payments using on-chain proof on Base network

ProofPay is a decentralized payment platform that leverages [Ethereum Attestation Service (EAS)](https://attest.sh/) on the [Base](https://base.org/) network to enable secure, verified payments without traditional KYC processes.

## 🌟 Key Features

- **Privacy-Preserving**: Use on-chain attestations instead of sharing personal documents
- **Policy-Based Verification**: Flexible proof requirements with trusted issuers
- **Session Management**: Complete lifecycle from creation to execution
- **Fast & Cheap**: Built on Base L2 for lightning-fast transactions with minimal fees
- **Upgradeable**: All contracts use UUPS proxy pattern for future improvements
- **Multiple Proof Types**: Support for EAS attestations, ZK proofs, and signatures

## 🏗️ Architecture

### Smart Contracts (Solidity + Foundry)

**Core Contracts:**
- **PolicyManager**: Manages payment policies with flexible proof requirements
- **SessionManager**: Handles payment session lifecycle with proof verification

**Key Features:**
- Multiple proof types (EAS attestations, ZK proofs, signatures)
- Policy-based verification with trusted issuers
- Session lifecycle management (Pending → Verified → Executed)
- Automatic expiration and refund handling
- UUPS upgradeable proxy pattern

### Backend (Python + FastAPI)
- RESTful API for user and payment management
- EAS integration service
- Web3 blockchain interactions
- Real-time transaction monitoring

### Frontend (React + Tailwind CSS)
- Modern, responsive UI
- Web3 wallet integration (MetaMask, etc.)
- Real-time transaction updates
- Attestation verification interface

## 🚀 Quick Start

### Prerequisites
- Node.js v18+
- Python 3.11+
- [Foundry](https://getfoundry.sh/) (for smart contracts)
- MongoDB (for backend)

### Using ProofPay

**1. Create a Payment Policy:**
```solidity
// Policy with KYC requirement
uint256 policyId = policyManager.createPolicy(
    "KYC Required",
    "Payments require valid KYC attestation",
    block.timestamp,      // Valid from now
    0,                    // No expiration
    1                     // Minimum 1 proof required
);

// Add EAS attestation requirement
policyManager.addProofRequirement(
    policyId,
    ProofType.EASAttestation,
    kycSchemaUID,
    trustedIssuer,
    true,                // Required
    30 days             // Validity period
);
```

**2. Create a Payment Session:**
```solidity
// Create session with 1 ETH payment
bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
    payeeAddress,
    address(0),         // Native ETH
    1 ether,
    policyId,
    block.timestamp + 7 days,  // Expires in 7 days
    "Payment for services"
);
```

**3. Attach Proof and Execute:**
```solidity
// Attach EAS attestation
sessionManager.attachProof(
    sessionId,
    ProofType.EASAttestation,
    attestationUID,
    issuer,
    0                  // No expiration
);

// Verify session
bool verified = sessionManager.verifySession(sessionId);

// Execute payment
sessionManager.executeSession(sessionId);
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/ProofPay.git
cd ProofPay
```

2. **Install smart contract dependencies**
```bash
cd contracts
forge install
forge build
```

3. **Install backend dependencies**
```bash
cd ../backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your configuration
```

4. **Install frontend dependencies**
```bash
cd ../frontend
yarn install
cp .env.example .env
# Edit .env with your configuration
```

### Running Locally

1. **Start backend**
```bash
cd backend
uvicorn server:app --reload --port 8001
```

2. **Start frontend**
```bash
cd frontend
yarn start
```

3. **Deploy contracts (local)**
```bash
cd contracts
anvil  # Start local node
forge script script/DeployBase.s.sol --rpc-url http://localhost:8545 --broadcast
```

## 📚 Documentation

- [Smart Contracts Documentation](./docs/smart-contracts.md)
- [API Reference](./docs/api-reference.md)
- [EAS Integration Guide](./docs/eas-integration.md)
- [Development Roadmap](./docs/development-roadmap.md)
- [Contributing Guidelines](./docs/CONTRIBUTING.md)

## 🧪 Testing

### Smart Contracts
```bash
cd contracts
forge test -vvv
forge coverage
```

### Backend
```bash
cd backend
pytest tests/ -v --cov
```

### Frontend
```bash
cd frontend
yarn test
```

## 🔐 Security

- All smart contracts are upgradeable using UUPS pattern
- Reentrancy protection on all payment functions
- Regular security audits (coming soon)
- Bug bounty program (coming soon)

**⚠️ This project is in active development. Do not use in production without thorough security review.**

## 🌐 Deployment

### Base Sepolia (Testnet)
- **Network**: Base Sepolia
- **Chain ID**: 84532
- **RPC**: https://sepolia.base.org
- **Explorer**: https://sepolia.basescan.org
- **EAS Registry**: `0x4200000000000000000000000000000000000021`

**Contract Addresses** (Testnet):
```
PolicyManager Proxy:  0xC879C9fe4Dd2ec91125074CE98E64b44218EB970
SessionManager Proxy: 0x4c03a6C94D75933AA7793489CFAf32b646A36887
EAS Registry:         0x4200000000000000000000000000000000000021
```

### Base Mainnet
- **Network**: Base Mainnet
- **Chain ID**: 8453
- **RPC**: https://mainnet.base.org
- **Explorer**: https://basescan.org
- **EAS Registry**: `0x4200000000000000000000000000000000000021`

**Contract Addresses** (Mainnet):
```
PolicyManager Proxy:  0x553c710b560344ad6B9e674BC963120b0b9DC571
SessionManager Proxy: 0x2dDE05bfaB88Ce59Eebc317Dd81E05288bBcbF84
EAS Registry:         0x4200000000000000000000000000000000000021
```

### Deployment Instructions

1. **Set up environment variables:**
```bash
export PRIVATE_KEY="your-private-key"
export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"
```

2. **Deploy to Base Sepolia:**
```bash
cd contracts
forge script script/DeployBase.s.sol:DeployBase \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

3. **Deploy to Base Mainnet:**
```bash
export BASE_MAINNET_RPC_URL="https://mainnet.base.org"
forge script script/DeployBase.s.sol:DeployBase \
  --rpc-url $BASE_MAINNET_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

Deployment info is automatically saved to `deployments/` directory.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](./docs/CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Ethereum Attestation Service](https://attest.sh/) for the attestation infrastructure
- [Base](https://base.org/) for the fast and cheap L2 network
- [OpenZeppelin](https://openzeppelin.com/) for secure smart contract libraries
- [Foundry](https://getfoundry.sh/) for the blazing fast development framework

## 📞 Contact

- Website: [proofpay.io](https://proofpay.io) (coming soon)
- Twitter: [@ProofPay](https://twitter.com/ProofPay)
- Discord: [Join our community](https://discord.gg/proofpay)

---

**Built with ❤️ on Base**
