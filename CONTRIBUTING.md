# Contributing to ProofPay

Thank you for your interest in contributing to ProofPay!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/ProofPay.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Commit with conventional commits: `git commit -m "feat: add new feature"`
6. Push: `git push origin feature/your-feature-name`
7. Create a Pull Request

## Development Setup

### Smart Contracts
```bash
cd contracts
forge install
forge build
forge test
```

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn server:app --reload
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `test:` Tests
- `refactor:` Code refactoring
- `chore:` Maintenance

## Code Style

### Solidity
- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use natspec comments
- Run `forge fmt`

### Python
- Follow PEP 8
- Use type hints
- Run `black` and `flake8`

### JavaScript/React
- Use ESLint
- Use Prettier
- Functional components with hooks

## Testing

- Write tests for new features
- Ensure all tests pass: `forge test`, `pytest`, `npm test`
- Aim for >80% coverage

## Pull Request Process

1. Update README if needed
2. Add tests for new features
3. Ensure CI passes
4. Request review from maintainers
5. Address feedback

## Questions?

Open an issue or join our Discord.
