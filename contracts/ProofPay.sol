// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface IVerifier {
    function verify(address payer, address recipient, uint256 amount, bytes32 proofHash, bytes calldata proof) external view returns (bool);
}

error InvalidRecipient();
error InvalidAmount();
error AlreadyExists();
error InvalidPayment();
error NotRecipient();
error InvalidProof();
error InsufficientBalance();

struct Payment {
    address payer;
    address recipient;
    uint256 amount;
    bytes32 proofHash;
    uint64 timestamp;
    bool settled;
}

contract ProofPay is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(bytes32 => Payment) private payments;
    mapping(address => uint256) public balances;
    address public verifier;

    event PaymentCreated(bytes32 id, address payer, address recipient, uint256 amount, bytes32 proofHash);
    event PaymentSettled(bytes32 id, address payer, address recipient, uint256 amount);
    event VerifierUpdated(address verifier);

    function initialize(address owner_, address verifier_) public initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();
        verifier = verifier_;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function setVerifier(address v) external onlyOwner {
        verifier = v;
        emit VerifierUpdated(v);
    }

    function createPayment(bytes32 id, address recipient, bytes32 proofHash) external payable {
        if (recipient == address(0)) revert InvalidRecipient();
        if (msg.value == 0) revert InvalidAmount();
        if (payments[id].timestamp != 0) revert AlreadyExists();
        payments[id] = Payment(msg.sender, recipient, msg.value, proofHash, uint64(block.timestamp), false);
        balances[recipient] += msg.value;
        emit PaymentCreated(id, msg.sender, recipient, msg.value, proofHash);
    }

    function settle(bytes32 id, bytes calldata proof) external {
        Payment storage p = payments[id];
        if (p.timestamp == 0 || p.settled) revert InvalidPayment();
        if (msg.sender != p.recipient) revert NotRecipient();
        if (!IVerifier(verifier).verify(p.payer, p.recipient, p.amount, p.proofHash, proof)) revert InvalidProof();
        p.settled = true;
        emit PaymentSettled(id, p.payer, p.recipient, p.amount);
    }

    function withdraw(uint256 amount) external {
        if (balances[msg.sender] < amount) revert InsufficientBalance();
        balances[msg.sender] -= amount;
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer");
    }

    receive() external payable {}
}
