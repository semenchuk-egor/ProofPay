// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PolicyManager.sol";
import "../interfaces/IEAS.sol";

/**
 * @title SessionManager
 * @notice Manages payment sessions with policy-based proof verification
 */
contract SessionManager is OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    enum SessionStatus {
        Pending,
        ProofsAttached,
        Verified,
        Executed,
        Expired,
        Cancelled
    }

    struct ProofAttachment {
        PolicyManager.ProofType proofType;
        bytes32 proofData;        // Attestation UID or proof hash
        address issuer;
        uint256 timestamp;
        uint256 expiresAt;        // 0 = no expiration
        bool verified;
    }

    struct Session {
        bytes32 id;
        address payer;
        address payee;
        address token;            // address(0) for native token
        uint256 amount;
        uint256 policyId;
        SessionStatus status;
        ProofAttachment[] proofs;
        uint256 createdAt;
        uint256 expiresAt;        // Session expiration (not proof expiration)
        uint256 executedAt;
        uint256 cancelledAt;
        string metadata;          // Optional metadata (IPFS hash, etc.)
    }

    // Storage
    PolicyManager public policyManager;
    IEAS public easRegistry;

    mapping(bytes32 => Session) private sessions;
    mapping(address => bytes32[]) public userSessions;
    mapping(uint256 => bytes32[]) public policySessions;

    uint256 public totalSessions;
    uint256 public defaultSessionDuration;  // Default 7 days

    // Events
    event SessionCreated(bytes32 indexed sessionId, address indexed payer, address indexed payee, uint256 policyId);
    event ProofAttached(bytes32 indexed sessionId, PolicyManager.ProofType proofType, bytes32 proofData);
    event SessionVerified(bytes32 indexed sessionId, uint256 proofsVerified);
    event SessionExecuted(bytes32 indexed sessionId, address token, uint256 amount);
    event SessionExpired(bytes32 indexed sessionId);
    event SessionCancelled(bytes32 indexed sessionId, address cancelledBy);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _policyManager, address _easRegistry) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        policyManager = PolicyManager(_policyManager);
        easRegistry = IEAS(_easRegistry);
        defaultSessionDuration = 7 days;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @notice Create new payment session
     */
    function createSession(
        address payee,
        address token,
        uint256 amount,
        uint256 policyId,
        uint256 expiresAt,
        string calldata metadata
    ) external payable returns (bytes32) {
        require(payee != address(0), "Invalid payee");
        require(amount > 0, "Amount must be > 0");
        require(policyManager.isPolicyValid(policyId), "Invalid or expired policy");

        // For native token payments, validate msg.value
        if (token == address(0)) {
            require(msg.value == amount, "Incorrect ETH amount");
        } else {
            require(msg.value == 0, "ETH not accepted for token payments");
            // Transfer tokens to contract
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }

        // Calculate expiration
        uint256 sessionExpiry = expiresAt;
        if (sessionExpiry == 0) {
            sessionExpiry = block.timestamp + defaultSessionDuration;
        }
        require(sessionExpiry > block.timestamp, "Invalid expiration");

        bytes32 sessionId = keccak256(
            abi.encodePacked(
                msg.sender,
                payee,
                token,
                amount,
                policyId,
                block.timestamp,
                totalSessions
            )
        );

        Session storage session = sessions[sessionId];
        session.id = sessionId;
        session.payer = msg.sender;
        session.payee = payee;
        session.token = token;
        session.amount = amount;
        session.policyId = policyId;
        session.status = SessionStatus.Pending;
        session.createdAt = block.timestamp;
        session.expiresAt = sessionExpiry;
        session.metadata = metadata;

        userSessions[msg.sender].push(sessionId);
        userSessions[payee].push(sessionId);
        policySessions[policyId].push(sessionId);

        totalSessions++;

        emit SessionCreated(sessionId, msg.sender, payee, policyId);

        return sessionId;
    }

    /**
     * @notice Attach proof to session
     */
    function attachProof(
        bytes32 sessionId,
        PolicyManager.ProofType proofType,
        bytes32 proofData,
        address issuer,
        uint256 expiresAt
    ) external {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");
        require(session.status == SessionStatus.Pending || session.status == SessionStatus.ProofsAttached, "Invalid session state");
        require(block.timestamp < session.expiresAt, "Session expired");
        require(msg.sender == session.payer || msg.sender == session.payee, "Not authorized");

        ProofAttachment memory proof = ProofAttachment({
            proofType: proofType,
            proofData: proofData,
            issuer: issuer,
            timestamp: block.timestamp,
            expiresAt: expiresAt,
            verified: false
        });

        session.proofs.push(proof);

        if (session.status == SessionStatus.Pending) {
            session.status = SessionStatus.ProofsAttached;
        }

        emit ProofAttached(sessionId, proofType, proofData);
    }

    /**
     * @notice Verify session against policy requirements
     */
    function verifySession(bytes32 sessionId) external returns (bool) {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");
        require(session.status == SessionStatus.ProofsAttached, "No proofs attached");
        require(block.timestamp < session.expiresAt, "Session expired");

        PolicyManager.ProofRequirement[] memory requirements = policyManager.getPolicyRequirements(session.policyId);
        require(requirements.length > 0, "No policy requirements");

        uint256 verifiedCount = 0;

        // Verify each attached proof
        for (uint256 i = 0; i < session.proofs.length; i++) {
            ProofAttachment storage proof = session.proofs[i];

            // Check proof expiration
            if (proof.expiresAt > 0 && block.timestamp > proof.expiresAt) {
                continue;
            }

            // Verify based on proof type
            bool isValid = false;

            if (proof.proofType == PolicyManager.ProofType.EASAttestation) {
                isValid = _verifyEASAttestation(proof.proofData, proof.issuer);
            } else if (proof.proofType == PolicyManager.ProofType.ZKProof) {
                isValid = _verifyZKProof(proof.proofData);
            } else if (proof.proofType == PolicyManager.ProofType.Signature) {
                isValid = _verifySignature(proof.proofData, proof.issuer);
            }

            if (isValid) {
                proof.verified = true;
                verifiedCount++;
            }
        }

        // Check minimum requirements met
        (, , , uint256 minProofsRequired, , , , ) = policyManager.getPolicy(session.policyId);

        if (verifiedCount >= minProofsRequired) {
            session.status = SessionStatus.Verified;
            emit SessionVerified(sessionId, verifiedCount);
            return true;
        }

        return false;
    }

    /**
     * @notice Execute payment after verification
     */
    function executeSession(bytes32 sessionId) external nonReentrant {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");
        require(session.status == SessionStatus.Verified, "Session not verified");
        require(block.timestamp < session.expiresAt, "Session expired");
        require(msg.sender == session.payer || msg.sender == session.payee, "Not authorized");

        session.status = SessionStatus.Executed;
        session.executedAt = block.timestamp;

        // Transfer funds
        if (session.token == address(0)) {
            (bool success, ) = session.payee.call{value: session.amount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(session.token).transfer(session.payee, session.amount);
        }

        emit SessionExecuted(sessionId, session.token, session.amount);
    }

    /**
     * @notice Cancel session and refund
     */
    function cancelSession(bytes32 sessionId) external nonReentrant {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");
        require(session.status != SessionStatus.Executed, "Already executed");
        require(session.status != SessionStatus.Cancelled, "Already cancelled");
        require(msg.sender == session.payer || msg.sender == owner(), "Not authorized");

        session.status = SessionStatus.Cancelled;
        session.cancelledAt = block.timestamp;

        // Refund to payer
        if (session.token == address(0)) {
            (bool success, ) = session.payer.call{value: session.amount}("");
            require(success, "ETH refund failed");
        } else {
            IERC20(session.token).transfer(session.payer, session.amount);
        }

        emit SessionCancelled(sessionId, msg.sender);
    }

    /**
     * @notice Mark expired session
     */
    function expireSession(bytes32 sessionId) external {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");
        require(block.timestamp >= session.expiresAt, "Not expired yet");
        require(session.status != SessionStatus.Executed, "Already executed");
        require(session.status != SessionStatus.Cancelled, "Already cancelled");
        require(session.status != SessionStatus.Expired, "Already expired");

        session.status = SessionStatus.Expired;

        // Refund to payer
        if (session.token == address(0)) {
            (bool success, ) = session.payer.call{value: session.amount}("");
            require(success, "ETH refund failed");
        } else {
            IERC20(session.token).transfer(session.payer, session.amount);
        }

        emit SessionExpired(sessionId);
    }

    /**
     * @notice Get session details
     */
    function getSession(bytes32 sessionId) external view returns (
        address payer,
        address payee,
        address token,
        uint256 amount,
        uint256 policyId,
        SessionStatus status,
        uint256 proofsCount,
        uint256 createdAt,
        uint256 expiresAt
    ) {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");

        return (
            session.payer,
            session.payee,
            session.token,
            session.amount,
            session.policyId,
            session.status,
            session.proofs.length,
            session.createdAt,
            session.expiresAt
        );
    }

    /**
     * @notice Get session proofs
     */
    function getSessionProofs(bytes32 sessionId) external view returns (ProofAttachment[] memory) {
        Session storage session = sessions[sessionId];
        require(session.id != bytes32(0), "Session does not exist");

        return session.proofs;
    }

    // Internal verification functions

    function _verifyEASAttestation(bytes32 attestationUID, address expectedIssuer) internal view returns (bool) {
        if (address(easRegistry) == address(0)) {
            return false;
        }

        IEAS.Attestation memory attestation = easRegistry.getAttestation(attestationUID);

        return attestation.uid != bytes32(0) &&
               attestation.revocationTime == 0 &&
               (expectedIssuer == address(0) || attestation.attester == expectedIssuer) &&
               (attestation.expirationTime == 0 || attestation.expirationTime > block.timestamp);
    }

    function _verifyZKProof(bytes32 proofHash) internal pure returns (bool) {
        // Placeholder for ZK proof verification
        // In production, this would verify zero-knowledge proofs
        return proofHash != bytes32(0);
    }

    function _verifySignature(bytes32 signatureHash, address signer) internal pure returns (bool) {
        // Placeholder for signature verification
        // In production, this would verify ECDSA signatures
        return signatureHash != bytes32(0) && signer != address(0);
    }

    /**
     * @notice Set default session duration
     */
    function setDefaultSessionDuration(uint256 duration) external onlyOwner {
        require(duration > 0, "Invalid duration");
        defaultSessionDuration = duration;
    }
}
