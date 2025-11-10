# ProofPay

Payments without KYC using on-chain proofs on Base. Upgradeable UUPS smart contract, zk-proof verifier interface. Built via GitHub Actions only.

## Networks

- Base Mainnet (8453) — deployed; see `deployments/8453.json`
- Base Sepolia (84532) — deployed; see `deployments/84532.json`

## Contract

- `ProofPay` — UUPS upgradeable escrow-like payments gated by zk-proof verification.

## Workflows

- `upgrade` — upgrade implementation on Base or Base Sepolia using the existing proxy from `deployments/*.json`. Produces a tag and updates `implementation` + `timestamp`.

## Setup

Secrets: `BASE_MAINNET_RPC_URL`, `BASE_SEPOLIA_RPC_URL`, `PRIVATE_KEY`, `BASESCAN_API_KEY`.

## Topics

base base-mainnet base-sepolia onchain uups upgrades zk-proof payments solidity foundry github-actions basescan
