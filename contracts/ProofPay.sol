// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ProofPay
 * @notice Minimal KYC-less payment contract that emits a proof hash alongside payments.
 *         UUPS upgradeable to allow iterative development.
 */
contract ProofPay is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    event Paid(address indexed payer, address indexed payee, uint256 amount, bytes32 proofHash);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @notice Send ETH to `payee` and attach a `proofHash` (e.g., zk proof commitment or claim ID).
     */
    function payWithProof(address payable payee, bytes32 proofHash) external payable {
        require(payee != address(0), "invalid payee");
        require(msg.value > 0, "zero value");
        (bool ok, ) = payee.call{value: msg.value}("");
        require(ok, "transfer failed");
        emit Paid(msg.sender, payee, msg.value, proofHash);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    receive() external payable {}
}
