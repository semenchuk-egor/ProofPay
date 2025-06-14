// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IEAS
 * @notice Interface for Ethereum Attestation Service on Base
 */
interface IEAS {
    struct AttestationRequest {
        bytes32 schema;
        address recipient;
        uint64 expirationTime;
        bool revocable;
        bytes32 refUID;
        bytes data;
        uint256 value;
    }

    struct Attestation {
        bytes32 uid;
        bytes32 schema;
        uint64 time;
        uint64 expirationTime;
        address recipient;
        address attester;
        bytes data;
    }

    function attest(AttestationRequest calldata request) external payable returns (bytes32);
    function getAttestation(bytes32 uid) external view returns (Attestation memory);
}
