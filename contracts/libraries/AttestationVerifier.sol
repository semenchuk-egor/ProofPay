// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IEAS.sol";

/**
 * @title AttestationVerifier
 * @notice Library for verifying EAS attestations on Base
 */
library AttestationVerifier {
    struct AttestationData {
        bytes32 uid;
        bytes32 schema;
        address recipient;
        address attester;
        uint64 time;
        uint64 expirationTime;
        bool revocable;
        bytes32 refUID;
        bytes data;
    }

    /**
     * @notice Verify attestation exists and is valid
     */
    function verifyAttestation(
        address easAddress,
        bytes32 uid
    ) internal view returns (bool) {
        IEAS eas = IEAS(easAddress);
        IEAS.Attestation memory attestation = eas.getAttestation(uid);
        
        // Check attestation exists
        if (attestation.uid == bytes32(0)) {
            return false;
        }
        
        // Check not revoked
        if (attestation.revocationTime > 0) {
            return false;
        }
        
        // Check not expired
        if (attestation.expirationTime > 0 && 
            attestation.expirationTime < block.timestamp) {
            return false;
        }
        
        return true;
    }

    /**
     * @notice Decode KYC attestation data
     */
    function decodeKYCData(
        bytes memory data
    ) internal pure returns (
        uint8 level,
        uint256 timestamp,
        bytes32 documentHash
    ) {
        (level, timestamp, documentHash) = abi.decode(
            data,
            (uint8, uint256, bytes32)
        );
    }
}
