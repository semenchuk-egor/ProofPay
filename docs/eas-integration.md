# EAS Integration Guide

## Overview
ProofPay integrates with Ethereum Attestation Service (EAS) on Base network to enable KYC-free payments using on-chain attestations.

## Architecture

### Smart Contracts
- **PaymentValidator**: Core contract that validates payments using EAS attestations
- **AttestationVerifier**: Library for verifying attestation validity
- Uses UUPS upgradeable proxy pattern

### Backend
- **EASService**: Python service for interacting with EAS contract
- **Attestation API**: REST endpoints for attestation verification

### Frontend
- **AttestationVerifier**: React component for verifying attestations

## EAS on Base

### Contract Addresses
- **EAS Contract**: `0x4200000000000000000000000000000000000021`
- **Schema Registry**: `0x4200000000000000000000000000000000000020`

### Network Details
- **Chain ID**: 8453 (Base Mainnet)
- **RPC**: `https://mainnet.base.org`

## KYC Schema

The ProofPay KYC schema encodes:
```solidity
(uint8 level, uint256 timestamp, bytes32 documentHash)
```

- **level**: KYC verification level (1-5)
- **timestamp**: Verification timestamp
- **documentHash**: Hash of verification documents

## Usage Flow

1. **User Registration**
   - User obtains EAS attestation from trusted attester
   - Attestation includes KYC level and verification data

2. **Linking Attestation**
   - User links their attestation UID to ProofPay account
   - `PaymentValidator.linkAttestation(attestationUID)`

3. **Payment Validation**
   - Before payment, system validates both parties have valid attestations
   - `PaymentValidator.validatePayment(from, to, amount)`

4. **On-chain Verification**
   - Contract checks attestation exists, not revoked, not expired
   - Validates schema matches KYC schema

## API Endpoints

### Verify Attestation
```
GET /api/attestation/verify/{uid}
```
Returns: `{ uid, valid }`

### Get Attestation Details
```
GET /api/attestation/{uid}
```
Returns: Full attestation data including decoded KYC info

### Link Attestation
```
POST /api/attestation/link
Body: { uid: "0x..." }
```
Links attestation to user account

## Security Considerations

- Attestations must be from trusted attesters
- Regular monitoring of attestation revocations
- Expiration time enforcement
- Schema validation to prevent wrong attestation types

## Future Enhancements

- Multi-signature attestation requirements
- Reputation scoring based on attestation history
- Integration with additional identity providers
- zkProof integration for enhanced privacy
