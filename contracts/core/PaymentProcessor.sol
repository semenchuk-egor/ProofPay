// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./AttestationVerifier.sol";

contract PaymentProcessor is Initializable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    AttestationVerifier public verifier;
    
    struct Payment {
        address sender;
        address recipient;
        uint256 amount;
        bytes32 attestationUID;
        uint256 timestamp;
        bool completed;
    }
    
    mapping(bytes32 => Payment) public payments;
    mapping(address => bytes32[]) public userPayments;
    
    uint256 public platformFee; // in basis points (100 = 1%)
    address public feeCollector;
    uint256 public collectedFees;
    
    event PaymentCreated(bytes32 indexed paymentId, address indexed sender, address indexed recipient, uint256 amount);
    event PaymentCompleted(bytes32 indexed paymentId);
    
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _verifier, uint256 _platformFee, address _feeCollector) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        verifier = AttestationVerifier(_verifier);
        platformFee = _platformFee;
        feeCollector = _feeCollector;
    }

    function createPayment(address recipient, bytes32 attestationUID) external payable nonReentrant returns (bytes32) {
        require(msg.value > 0, "Amount must be > 0");
        require(recipient != address(0), "Invalid recipient");
        require(verifier.verifyAttestation(attestationUID), "Invalid attestation");
        
        uint256 fee = (msg.value * platformFee) / 10000;
        uint256 netAmount = msg.value - fee;
        
        bytes32 paymentId = keccak256(abi.encodePacked(msg.sender, recipient, msg.value, attestationUID, block.timestamp));
        
        payments[paymentId] = Payment({
            sender: msg.sender,
            recipient: recipient,
            amount: msg.value,
            attestationUID: attestationUID,
            timestamp: block.timestamp,
            completed: false
        });
        
        userPayments[msg.sender].push(paymentId);
        userPayments[recipient].push(paymentId);
        
        collectedFees += fee;
        (bool success, ) = recipient.call{value: netAmount}("");
        require(success, "Transfer failed");
        
        payments[paymentId].completed = true;
        
        emit PaymentCreated(paymentId, msg.sender, recipient, msg.value);
        emit PaymentCompleted(paymentId);
        
        return paymentId;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
    
    receive() external payable {}
}
