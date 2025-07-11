// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PaymentStorage is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct StoredPayment {
        bytes32 id;
        address sender;
        address recipient;
        uint256 amount;
        uint256 timestamp;
        PaymentStatus status;
    }
    
    enum PaymentStatus {
        Pending,
        Completed,
        Failed,
        Refunded
    }
    
    // Storage mappings
    mapping(bytes32 => StoredPayment) private _payments;
    mapping(address => bytes32[]) private _userPaymentIds;
    mapping(address => uint256) private _userPaymentCount;
    
    // Statistics
    struct UserStats {
        uint256 totalSent;
        uint256 totalReceived;
        uint256 paymentCount;
        uint256 lastActivityTimestamp;
    }
    
    mapping(address => UserStats) private _userStats;
    
    uint256 public totalPayments;
    uint256 public totalVolume;
    
    event PaymentStored(bytes32 indexed paymentId, address indexed sender, address indexed recipient);
    
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function storePayment(
        bytes32 paymentId,
        address sender,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(sender != address(0) && recipient != address(0), "Invalid addresses");
        
        StoredPayment memory payment = StoredPayment({
            id: paymentId,
            sender: sender,
            recipient: recipient,
            amount: amount,
            timestamp: block.timestamp,
            status: PaymentStatus.Pending
        });
        
        _payments[paymentId] = payment;
        _userPaymentIds[sender].push(paymentId);
        _userPaymentIds[recipient].push(paymentId);
        _userPaymentCount[sender]++;
        _userPaymentCount[recipient]++;
        
        _updateUserStats(sender, amount, true);
        _updateUserStats(recipient, amount, false);
        
        totalPayments++;
        totalVolume += amount;
        
        emit PaymentStored(paymentId, sender, recipient);
    }

    function getPayment(bytes32 paymentId) external view returns (StoredPayment memory) {
        return _payments[paymentId];
    }

    function getUserPaymentIds(address user) external view returns (bytes32[] memory) {
        return _userPaymentIds[user];
    }

    function getUserStats(address user) external view returns (UserStats memory) {
        return _userStats[user];
    }

    function _updateUserStats(address user, uint256 amount, bool isSender) private {
        UserStats storage stats = _userStats[user];
        
        if (isSender) {
            stats.totalSent += amount;
        } else {
            stats.totalReceived += amount;
        }
        
        stats.paymentCount++;
        stats.lastActivityTimestamp = block.timestamp;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
