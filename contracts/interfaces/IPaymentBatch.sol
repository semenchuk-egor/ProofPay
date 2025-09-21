// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPaymentBatch
 * @notice Interface for batch payment operations
 */
interface IPaymentBatch {
    struct Payment {
        address recipient;
        uint256 amount;
    }
    
    function batchPayNative(Payment[] calldata payments) external payable;
    
    function batchPayToken(
        address token,
        Payment[] calldata payments
    ) external;
}
