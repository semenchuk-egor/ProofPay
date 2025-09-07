// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IPaymentValidator.sol";

/**
 * @title PaymentEscrow
 * @notice Escrow contract for secure payments with attestation validation
 */
contract PaymentEscrow is OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    IPaymentValidator public validator;
    
    struct Escrow {
        address sender;
        address recipient;
        uint256 amount;
        address token; // address(0) for native
        bool released;
        bool refunded;
        uint256 createdAt;
    }
    
    mapping(bytes32 => Escrow) public escrows;
    
    event EscrowCreated(bytes32 indexed escrowId, address indexed sender, address indexed recipient, uint256 amount);
    event EscrowReleased(bytes32 indexed escrowId);
    event EscrowRefunded(bytes32 indexed escrowId);
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(address _validator) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        validator = IPaymentValidator(_validator);
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    /**
     * @notice Create escrow with native token
     */
    function createEscrowNative(
        bytes32 escrowId,
        address recipient
    ) external payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than 0");
        require(escrows[escrowId].sender == address(0), "Escrow already exists");
        require(validator.canPay(msg.sender), "Sender not verified");
        require(validator.canPay(recipient), "Recipient not verified");
        
        escrows[escrowId] = Escrow({
            sender: msg.sender,
            recipient: recipient,
            amount: msg.value,
            token: address(0),
            released: false,
            refunded: false,
            createdAt: block.timestamp
        });
        
        emit EscrowCreated(escrowId, msg.sender, recipient, msg.value);
    }
    
    /**
     * @notice Create escrow with ERC20 token
     */
    function createEscrowToken(
        bytes32 escrowId,
        address recipient,
        address token,
        uint256 amount
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(escrows[escrowId].sender == address(0), "Escrow already exists");
        require(validator.canPay(msg.sender), "Sender not verified");
        require(validator.canPay(recipient), "Recipient not verified");
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        escrows[escrowId] = Escrow({
            sender: msg.sender,
            recipient: recipient,
            amount: amount,
            token: token,
            released: false,
            refunded: false,
            createdAt: block.timestamp
        });
        
        emit EscrowCreated(escrowId, msg.sender, recipient, amount);
    }
    
    /**
     * @notice Release funds to recipient
     */
    function releaseEscrow(bytes32 escrowId) external nonReentrant {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.sender != address(0), "Escrow does not exist");
        require(!escrow.released, "Already released");
        require(!escrow.refunded, "Already refunded");
        require(msg.sender == escrow.sender, "Only sender can release");
        
        escrow.released = true;
        
        if (escrow.token == address(0)) {
            (bool success, ) = escrow.recipient.call{value: escrow.amount}("");
            require(success, "Transfer failed");
        } else {
            IERC20(escrow.token).transfer(escrow.recipient, escrow.amount);
        }
        
        emit EscrowReleased(escrowId);
    }
    
    /**
     * @notice Refund to sender
     */
    function refundEscrow(bytes32 escrowId) external nonReentrant {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.sender != address(0), "Escrow does not exist");
        require(!escrow.released, "Already released");
        require(!escrow.refunded, "Already refunded");
        require(msg.sender == escrow.sender || msg.sender == owner(), "Not authorized");
        
        escrow.refunded = true;
        
        if (escrow.token == address(0)) {
            (bool success, ) = escrow.sender.call{value: escrow.amount}("");
            require(success, "Refund failed");
        } else {
            IERC20(escrow.token).transfer(escrow.sender, escrow.amount);
        }
        
        emit EscrowRefunded(escrowId);
    }
}
