// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../core/PaymentValidator.sol";

/**
 * @title PaymentBatch
 * @notice Enables batch payments with attestation validation
 */
contract PaymentBatch is OwnableUpgradeable, UUPSUpgradeable {
    PaymentValidator public validator;
    
    event BatchPaymentExecuted(address indexed sender, uint256 recipientCount, uint256 totalAmount);
    event PaymentFailed(address indexed recipient, string reason);
    
    struct Payment {
        address recipient;
        uint256 amount;
    }
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(address _validator) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        validator = PaymentValidator(_validator);
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    /**
     * @notice Execute batch payment in native token
     */
    function batchPayNative(Payment[] calldata payments) external payable {
        uint256 totalAmount = 0;
        uint256 successCount = 0;
        
        for (uint256 i = 0; i < payments.length; i++) {
            totalAmount += payments[i].amount;
            
            // Validate payment
            if (!validator.canPay(msg.sender) || !validator.canPay(payments[i].recipient)) {
                emit PaymentFailed(payments[i].recipient, "Attestation validation failed");
                continue;
            }
            
            // Execute payment
            (bool success, ) = payments[i].recipient.call{value: payments[i].amount}("");
            if (success) {
                successCount++;
            } else {
                emit PaymentFailed(payments[i].recipient, "Transfer failed");
            }
        }
        
        require(msg.value >= totalAmount, "Insufficient funds");
        
        // Refund excess
        if (msg.value > totalAmount) {
            (bool refundSuccess, ) = msg.sender.call{value: msg.value - totalAmount}("");
            require(refundSuccess, "Refund failed");
        }
        
        emit BatchPaymentExecuted(msg.sender, successCount, totalAmount);
    }
    
    /**
     * @notice Execute batch payment in ERC20 token
     */
    function batchPayToken(
        address token,
        Payment[] calldata payments
    ) external {
        IERC20 tokenContract = IERC20(token);
        uint256 totalAmount = 0;
        uint256 successCount = 0;
        
        for (uint256 i = 0; i < payments.length; i++) {
            totalAmount += payments[i].amount;
            
            // Validate payment
            if (!validator.canPay(msg.sender) || !validator.canPay(payments[i].recipient)) {
                emit PaymentFailed(payments[i].recipient, "Attestation validation failed");
                continue;
            }
            
            // Execute payment
            bool success = tokenContract.transferFrom(
                msg.sender,
                payments[i].recipient,
                payments[i].amount
            );
            
            if (success) {
                successCount++;
            } else {
                emit PaymentFailed(payments[i].recipient, "Token transfer failed");
            }
        }
        
        emit BatchPaymentExecuted(msg.sender, successCount, totalAmount);
    }
}
