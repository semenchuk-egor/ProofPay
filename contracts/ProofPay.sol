/* SPDX-License-Identifier: MIT */
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

struct Payment {
    address payer;
    address recipient;
    uint256 amount;
    bytes32 proofHash;
    uint64 timestamp;
    bool settled;
}

interface IVerifier {
    function verify(address payer, address recipient, uint256 amount, bytes32 proofHash, bytes calldata proof) external view returns (bool);
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

    function createPayment(bytes32 id, address recipient, bytes32 proofHash) external payable {
        require(recipient != address(0), "recipient");
        require(msg.value > 0, "amount");
        require(payments[id].timestamp == 0, "exists");
        payments[id] = Payment(msg.sender, recipient, msg.value, proofHash, uint64(block.timestamp), false);
        balances[recipient] += msg.value;
        emit PaymentCreated(id, msg.sender, recipient, msg.value, proofHash);
    }

    function settle(bytes32 id, bytes calldata proof) external {
        Payment storage p = payments[id];
        require(p.timestamp != 0 && !p.settled, "invalid");
        require(msg.sender == p.recipient, "recipient");
        require(IVerifier(verifier).verify(p.payer, p.recipient, p.amount, p.proofHash, proof), "proof");
        p.settled = true;
        emit PaymentSettled(id, p.payer, p.recipient, p.amount);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "balance");
        balances[msg.sender] -= amount;
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer");
    }

    function setVerifier(address v) external onlyOwner {
        verifier = v;
        emit VerifierUpdated(v);
    }

    receive() external payable {}
}
