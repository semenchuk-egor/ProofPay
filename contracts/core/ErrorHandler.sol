// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ErrorHandler {
    // Custom errors (gas efficient)
    error InvalidAddress();
    error InvalidAmount();
    error InsufficientBalance(uint256 required, uint256 available);
    error PaymentNotFound(bytes32 paymentId);
    error AttestationInvalid(bytes32 attestationUID);
    error UnauthorizedAccess(address caller);
    error PaymentFailed(string reason);
    
    event ErrorOccurred(string errorType, address indexed caller, uint256 timestamp);
    
    function _validateAddress(address addr) internal pure {
        if (addr == address(0)) {
            revert InvalidAddress();
        }
    }
    
    function _validateAmount(uint256 amount) internal pure {
        if (amount == 0) {
            revert InvalidAmount();
        }
    }
    
    function _validateBalance(uint256 required, uint256 available) internal pure {
        if (available < required) {
            revert InsufficientBalance(required, available);
        }
    }
    
    function _logError(string memory errorType) internal {
        emit ErrorOccurred(errorType, msg.sender, block.timestamp);
    }
}
