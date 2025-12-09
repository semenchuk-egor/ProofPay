// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title PolicyManager
 * @notice Manages payment policies with required proofs and attestations
 */
contract PolicyManager is OwnableUpgradeable, UUPSUpgradeable {
    enum ProofType {
        EASAttestation,
        ZKProof,
        Signature,
        Custom
    }

    struct ProofRequirement {
        ProofType proofType;
        bytes32 schemaUID;      // For EAS attestations
        address issuer;         // Trusted proof issuer
        bool required;          // Whether this proof is mandatory
        uint256 validityPeriod; // How long proof remains valid (0 = forever)
    }

    struct Policy {
        uint256 id;
        string name;
        string description;
        address creator;
        ProofRequirement[] requirements;
        uint256 minProofsRequired;  // Minimum number of proofs needed
        uint256 validFrom;
        uint256 validUntil;         // 0 = no expiration
        bool active;
        uint256 createdAt;
        uint256 updatedAt;
    }

    // Storage
    mapping(uint256 => Policy) private policies;
    mapping(uint256 => mapping(bytes32 => ProofRequirement)) public policyProofs;
    mapping(address => uint256[]) public creatorPolicies;

    uint256 public nextPolicyId;
    uint256 public totalPolicies;

    // Events
    event PolicyCreated(uint256 indexed policyId, address indexed creator, string name);
    event PolicyUpdated(uint256 indexed policyId, address indexed updater);
    event PolicyActivated(uint256 indexed policyId);
    event PolicyDeactivated(uint256 indexed policyId);
    event ProofRequirementAdded(uint256 indexed policyId, ProofType proofType, address issuer);
    event ProofRequirementRemoved(uint256 indexed policyId, bytes32 requirementId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        nextPolicyId = 1;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @notice Create a new payment policy
     */
    function createPolicy(
        string calldata name,
        string calldata description,
        uint256 validFrom,
        uint256 validUntil,
        uint256 minProofsRequired
    ) external returns (uint256) {
        require(bytes(name).length > 0, "Policy name required");
        require(validUntil == 0 || validUntil > validFrom, "Invalid validity period");

        uint256 policyId = nextPolicyId++;

        Policy storage policy = policies[policyId];
        policy.id = policyId;
        policy.name = name;
        policy.description = description;
        policy.creator = msg.sender;
        policy.minProofsRequired = minProofsRequired;
        policy.validFrom = validFrom;
        policy.validUntil = validUntil;
        policy.active = true;
        policy.createdAt = block.timestamp;
        policy.updatedAt = block.timestamp;

        creatorPolicies[msg.sender].push(policyId);
        totalPolicies++;

        emit PolicyCreated(policyId, msg.sender, name);

        return policyId;
    }

    /**
     * @notice Add proof requirement to policy
     */
    function addProofRequirement(
        uint256 policyId,
        ProofType proofType,
        bytes32 schemaUID,
        address issuer,
        bool required,
        uint256 validityPeriod
    ) external {
        Policy storage policy = policies[policyId];
        require(policy.id != 0, "Policy does not exist");
        require(msg.sender == policy.creator || msg.sender == owner(), "Not authorized");
        require(issuer != address(0), "Invalid issuer");

        bytes32 requirementId = keccak256(abi.encodePacked(policyId, proofType, schemaUID, issuer));

        ProofRequirement memory requirement = ProofRequirement({
            proofType: proofType,
            schemaUID: schemaUID,
            issuer: issuer,
            required: required,
            validityPeriod: validityPeriod
        });

        policy.requirements.push(requirement);
        policyProofs[policyId][requirementId] = requirement;
        policy.updatedAt = block.timestamp;

        emit ProofRequirementAdded(policyId, proofType, issuer);
    }

    /**
     * @notice Toggle policy active status
     */
    function setPolicyActive(uint256 policyId, bool active) external {
        Policy storage policy = policies[policyId];
        require(policy.id != 0, "Policy does not exist");
        require(msg.sender == policy.creator || msg.sender == owner(), "Not authorized");

        policy.active = active;
        policy.updatedAt = block.timestamp;

        if (active) {
            emit PolicyActivated(policyId);
        } else {
            emit PolicyDeactivated(policyId);
        }
    }

    /**
     * @notice Check if policy is currently valid
     */
    function isPolicyValid(uint256 policyId) public view returns (bool) {
        Policy storage policy = policies[policyId];

        if (policy.id == 0 || !policy.active) {
            return false;
        }

        if (block.timestamp < policy.validFrom) {
            return false;
        }

        if (policy.validUntil > 0 && block.timestamp > policy.validUntil) {
            return false;
        }

        return true;
    }

    /**
     * @notice Get policy details
     */
    function getPolicy(uint256 policyId) external view returns (
        string memory name,
        string memory description,
        address creator,
        uint256 minProofsRequired,
        uint256 requirementsCount,
        bool active,
        uint256 validFrom,
        uint256 validUntil
    ) {
        Policy storage policy = policies[policyId];
        require(policy.id != 0, "Policy does not exist");

        return (
            policy.name,
            policy.description,
            policy.creator,
            policy.minProofsRequired,
            policy.requirements.length,
            policy.active,
            policy.validFrom,
            policy.validUntil
        );
    }

    /**
     * @notice Get policy requirements
     */
    function getPolicyRequirements(uint256 policyId) external view returns (ProofRequirement[] memory) {
        Policy storage policy = policies[policyId];
        require(policy.id != 0, "Policy does not exist");

        return policy.requirements;
    }

    /**
     * @notice Get policies created by address
     */
    function getPoliciesByCreator(address creator) external view returns (uint256[] memory) {
        return creatorPolicies[creator];
    }
}
