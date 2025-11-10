# ProofPay

Payments without KYC using on-chain proofs on Base. Upgradeable UUPS smart contract and zk-proof verifier interface. Built and operated **only via GitHub Actions**.

## Networks

- Base Mainnet (8453) — deployed; see `deployments/8453.json`
- Base Sepolia (84532) — deployed; see `deployments/84532.json`

## Workflows

- `deploy-basesepolia.yml` — idempotent deploy of proxy to Base Sepolia with guard and artifact append.
- `deploy-basemainnet.yml` — idempotent deploy of proxy to Base Mainnet with guard and artifact append.
- `upgrade.yml` — upgrade-only pipeline using existing proxy from `deployments/*.json`.

## How to release

1. Create a pre-release tag (e.g. `v0.1.0`).
2. If proxy is not deployed yet on a network, run:
   - **Deploy Sepolia:** `deploy-basesepolia` → input `tag: v0.1.0` (use `FORCE_DEPLOY=true` only if you really need a new proxy).
   - **Deploy Mainnet:** `deploy-basemainnet` → input `tag: v0.1.0`.
3. For logic updates run `upgrade` (no new proxy will be deployed). The workflow updates the last record in `deployments/8453.json` or `deployments/84532.json`.

## Secrets

- `BASE_MAINNET_RPC_URL`
- `BASE_SEPOLIA_RPC_URL`
- `PRIVATE_KEY`
- `OWNER_ADDRESS`
- `VERIFIER_ADDRESS`
- `BASESCAN_API_KEY`

## Topics

base base-mainnet base-sepolia onchain uups upgrades zk-proof payments solidity foundry github-actions basescan
