# Smart Contracts Documentation

## Overview
ProofPay smart contracts are built with Solidity ^0.8.20 and use the UUPS (Universal Upgradeable Proxy Standard) pattern for upgradeability.

## Architecture

### Core Contracts

#### PaymentValidator
**Purpose:** Validates payments using EAS attestations

**Key Features:**
- Links user wallets to EAS attestations
- Validates attestation status before payments
- Integrates with EAS contract on Base

**Functions:**
- `linkAttestation(bytes32 attestationUID)` - Link user's attestation
- `canPay(address user)` - Check if user can make payments
- `validatePayment(address from, address to, uint256 amount)` - Validate payment between users

**Events:**
- `AttestationLinked(address indexed user, bytes32 indexed attestationUID)`
- `PaymentValidated(address indexed from, address indexed to, uint256 amount)`

---

#### ProofToken (PROOF)
**Purpose:** ERC20 utility token for platform rewards and governance

**Key Features:**
- Fixed max supply: 1 billion tokens
- Burnable
- Minter role management
- Batch transfer functionality
- Upgradeable via UUPS

**Functions:**
- `mint(address to, uint256 amount)` - Mint new tokens (minters only)
- `addMinter(address minter)` - Add minter role (owner only)
- `batchTransfer(address[] recipients, uint256[] amounts)` - Batch transfer

---

### Extension Contracts

#### PaymentBatch
**Purpose:** Execute batch payments to multiple recipients

**Key Features:**
- Native and ERC20 token support
- Attestation validation for all recipients
- Automatic refund of excess funds
- Failed payment tracking

**Functions:**
- `batchPayNative(Payment[] payments)` - Batch payment in ETH
- `batchPayToken(address token, Payment[] payments)` - Batch payment in ERC20

---

#### PaymentEscrow
**Purpose:** Secure escrow for payments with attestation validation

**Key Features:**
- Native and ERC20 token support
- Release by sender
- Refund capability
- Reentrancy protection

**Functions:**
- `createEscrowNative(bytes32 escrowId, address recipient)` - Create escrow with ETH
- `createEscrowToken(bytes32 escrowId, address recipient, address token, uint256 amount)` - Create escrow with tokens
- `releaseEscrow(bytes32 escrowId)` - Release funds to recipient
- `refundEscrow(bytes32 escrowId)` - Refund to sender

---

## Libraries

### AttestationVerifier
Utility library for EAS attestation verification

**Functions:**
- `verifyAttestation(address easAddress, bytes32 uid)` - Verify attestation validity
- `decodeKYCData(bytes data)` - Decode KYC attestation data

---

## Deployment

All contracts use UUPS proxy pattern for upgradeability.

### Deployment Steps

1. **Deploy Implementation Contract**
```solidity
PaymentValidator implementation = new PaymentValidator();
```

2. **Deploy Proxy with Initialization**
```solidity
bytes memory initData = abi.encodeWithSelector(
    PaymentValidator.initialize.selector,
    easAddress,
    kycSchemaUID
);

ERC1967Proxy proxy = new ERC1967Proxy(
    address(implementation),
    initData
);
```

3. **Use Proxy Address**
```solidity
PaymentValidator validator = PaymentValidator(address(proxy));
```

### Upgrade Process

1. Deploy new implementation
2. Call `upgradeTo(address newImplementation)` on proxy (owner only)

---

## Security Features

1. **UUPS Upgradeability**
   - Only owner can upgrade
   - Prevents unauthorized upgrades

2. **Reentrancy Protection**
   - All payment functions use `nonReentrant` modifier
   - Custom reentrancy guard with logging

3. **Access Control**
   - Ownable pattern for admin functions
   - Minter role for token minting

4. **Attestation Validation**
   - All payments require valid attestations
   - Checks for revocation and expiration

---

## Gas Optimization

- Use of `calldata` for array parameters
- Efficient storage patterns
- Minimal external calls

---

## Testing

Run tests with Foundry:
```bash
cd contracts
forge test -vvv
```

Generate coverage:
```bash
forge coverage --report lcov
```

---

## Base Network Details

- **Network:** Base Mainnet
- **Chain ID:** 8453
- **RPC:** https://mainnet.base.org
- **Explorer:** https://basescan.org
- **EAS Contract:** 0x4200000000000000000000000000000000000021

---

## Contract Addresses

### Mainnet (TBD)
- PaymentValidator: TBD
- ProofToken: TBD
- PaymentBatch: TBD
- PaymentEscrow: TBD

### Testnet
- TBD
