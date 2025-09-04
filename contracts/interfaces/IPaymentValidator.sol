// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPaymentValidator
 * @notice Interface for PaymentValidator contract
 */
interface IPaymentValidator {
    /**
     * @notice Link user attestation
     */
    function linkAttestation(bytes32 attestationUID) external;
    
    /**
     * @notice Check if user can make payments
     */
    function canPay(address user) external view returns (bool);
    
    /**
     * @notice Validate payment between users
     */
    function validatePayment(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    
    /**
     * @notice Get user's attestation UID
     */
    function userAttestations(address user) external view returns (bytes32);
    
    /**
     * @notice Get EAS contract address
     */
    function easAddress() external view returns (address);
    
    /**
     * @notice Get KYC schema UID
     */
    function kycSchemaUID() external view returns (bytes32);
}
