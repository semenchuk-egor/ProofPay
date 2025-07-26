// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BatchPayments is 
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    struct BatchPayment {
        address[] recipients;
        uint256[] amounts;
        bytes32[] attestations;
        uint256 totalAmount;
        bool processed;
    }
    
    mapping(bytes32 => BatchPayment) public batches;
    
    event BatchCreated(bytes32 indexed batchId, uint256 recipientCount, uint256 totalAmount);
    event BatchProcessed(bytes32 indexed batchId, uint256 successCount);
    
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
    }
    
    function createBatch(
        address[] calldata recipients,
        uint256[] calldata amounts,
        bytes32[] calldata attestations
    ) external payable nonReentrant returns (bytes32) {
        require(recipients.length == amounts.length, "Length mismatch");
        require(recipients.length == attestations.length, "Length mismatch");
        require(recipients.length > 0, "Empty batch");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        require(msg.value >= totalAmount, "Insufficient funds");
        
        bytes32 batchId = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, recipients)
        );
        
        batches[batchId] = BatchPayment({
            recipients: recipients,
            amounts: amounts,
            attestations: attestations,
            totalAmount: totalAmount,
            processed: false
        });
        
        emit BatchCreated(batchId, recipients.length, totalAmount);
        return batchId;
    }
    
    function processBatch(bytes32 batchId) external nonReentrant {
        BatchPayment storage batch = batches[batchId];
        require(!batch.processed, "Already processed");
        
        uint256 successCount = 0;
        
        for (uint256 i = 0; i < batch.recipients.length; i++) {
            (bool success, ) = batch.recipients[i].call{value: batch.amounts[i]}("");
            if (success) {
                successCount++;
            }
        }
        
        batch.processed = true;
        emit BatchProcessed(batchId, successCount);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
