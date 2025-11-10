# ProofPay

Payments without KYC using on-chain proofs on Base. Upgradeable UUPS smart contract + zk-proof verification interface. Built and deployed via GitHub Actions only.

## Networks

- Base Mainnet (8453) — planned
- Base Sepolia (84532) — deploy via workflow

## Contracts

- `ProofPay` — UUPS upgradeable, escrow-like payments with zk-proof gated settlement.

## Deploy

- Configure secrets: `BASE_SEPOLIA_RPC_URL`, `PRIVATE_KEY`, `OWNER_ADDRESS`, `VERIFIER_ADDRESS`, `BASESCAN_API_KEY`.
- Run workflow **deploy-basesepolia** (manual).

## Verify

- Auto verification via Basescan API (see workflow). Guides and explorer: Base docs / Basescan. 
