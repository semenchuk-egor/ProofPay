// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../interfaces/IEAS.sol";

contract AttestationVerifier is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IEAS public easContract;
    bytes32 public paymentSchemaUID;
    mapping(address => bool) public trustedAttesters;
    
    event AttesterAdded(address indexed attester);
    event AttesterRemoved(address indexed attester);
    
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _easContract, bytes32 _paymentSchemaUID) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        easContract = IEAS(_easContract);
        paymentSchemaUID = _paymentSchemaUID;
    }

    function addTrustedAttester(address attester) external onlyOwner {
        require(attester != address(0), "Invalid attester");
        trustedAttesters[attester] = true;
        emit AttesterAdded(attester);
    }

    function removeTrustedAttester(address attester) external onlyOwner {
        trustedAttesters[attester] = false;
        emit AttesterRemoved(attester);
    }

    function verifyAttestation(bytes32 uid) public view returns (bool) {
        if (uid == bytes32(0)) return false;
        IEAS.Attestation memory attestation = easContract.getAttestation(uid);
        if (attestation.schema != paymentSchemaUID) return false;
        if (attestation.expirationTime > 0 && block.timestamp > attestation.expirationTime) return false;
        if (!trustedAttesters[attestation.attester]) return false;
        return true;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
