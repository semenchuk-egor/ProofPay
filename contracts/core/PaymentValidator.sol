// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../interfaces/IEAS.sol";
import "../libraries/AttestationVerifier.sol";

/**
 * @title PaymentValidator
 * @notice Validates payments using on-chain EAS attestations
 */
contract PaymentValidator is OwnableUpgradeable, UUPSUpgradeable {
    using AttestationVerifier for *;

    address public easAddress;
    bytes32 public kycSchemaUID;
    
    mapping(address => bytes32) public userAttestations;
    
    event AttestationLinked(address indexed user, bytes32 indexed attestationUID);
    event PaymentValidated(address indexed from, address indexed to, uint256 amount);
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(
        address _easAddress,
        bytes32 _kycSchemaUID
    ) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        
        easAddress = _easAddress;
        kycSchemaUID = _kycSchemaUID;
    }
    
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
    
    /**
     * @notice Link user to their KYC attestation
     */
    function linkAttestation(bytes32 attestationUID) external {
        require(
            AttestationVerifier.verifyAttestation(easAddress, attestationUID),
            "Invalid attestation"
        );
        
        IEAS eas = IEAS(easAddress);
        IEAS.Attestation memory attestation = eas.getAttestation(attestationUID);
        
        require(attestation.recipient == msg.sender, "Not attestation recipient");
        require(attestation.schema == kycSchemaUID, "Wrong schema");
        
        userAttestations[msg.sender] = attestationUID;
        
        emit AttestationLinked(msg.sender, attestationUID);
    }
    
    /**
     * @notice Validate if user can make payment
     */
    function canPay(address user) public view returns (bool) {
        bytes32 attestationUID = userAttestations[user];
        if (attestationUID == bytes32(0)) {
            return false;
        }
        
        return AttestationVerifier.verifyAttestation(easAddress, attestationUID);
    }
    
    /**
     * @notice Validate payment between two users
     */
    function validatePayment(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(canPay(from), "Sender not verified");
        require(canPay(to), "Recipient not verified");
        
        emit PaymentValidated(from, to, amount);
        return true;
    }
}
