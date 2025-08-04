// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPaymentEvents {
    event PaymentCreated(
        bytes32 indexed paymentId,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        bytes32 attestationUID
    );
    
    event PaymentCompleted(
        bytes32 indexed paymentId,
        uint256 timestamp
    );
    
    event PaymentFailed(
        bytes32 indexed paymentId,
        string reason
    );
    
    event AttestationVerified(
        bytes32 indexed attestationUID,
        address indexed verifier
    );
    
    event FeeCollected(
        bytes32 indexed paymentId,
        uint256 feeAmount,
        address collector
    );
    
    event ProofMinted(
        uint256 indexed tokenId,
        bytes32 indexed paymentId,
        address indexed recipient
    );
}
