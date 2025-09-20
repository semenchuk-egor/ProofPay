# ProofPay

> KYC-free payments using on-chain proof on Base network

ProofPay is a decentralized payment platform that leverages [Ethereum Attestation Service (EAS)](https://attest.sh/) on the [Base](https://base.org/) network to enable secure, verified payments without traditional KYC processes.

## 🌟 Key Features

- **Privacy-Preserving**: Use on-chain attestations instead of sharing personal documents
- **Secure**: Smart contract-based validation and escrow mechanisms
- **Fast & Cheap**: Built on Base L2 for lightning-fast transactions with minimal fees
- **Upgradeable**: All contracts use UUPS proxy pattern for future improvements
- **Batch Payments**: Send to multiple recipients in a single transaction
- **Escrow Support**: Secure escrow for conditional payments

## 🏗️ Architecture

### Smart Contracts (Solidity + Foundry)
- **PaymentValidator**: Core contract for attestation-based payment validation
- **ProofToken**: ERC-20 utility token for platform rewards
- **PaymentBatch**: Execute batch payments efficiently
- **PaymentEscrow**: Secure escrow with attestation validation

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
- Foundry (for smart contracts)
- MongoDB (for backend)

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
forge script script/DeployAll.s.sol --rpc-url http://localhost:8545 --broadcast
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

### Base Mainnet
- **Network**: Base Mainnet
- **Chain ID**: 8453
- **RPC**: https://mainnet.base.org
- **Explorer**: https://basescan.org

Contract addresses will be published after mainnet deployment.

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
