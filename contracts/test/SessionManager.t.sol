// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../core/SessionManager.sol";
import "../core/PolicyManager.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract MockEAS {
    struct Attestation {
        bytes32 uid;
        bytes32 schema;
        uint64 time;
        uint64 expirationTime;
        uint64 revocationTime;
        bytes32 refUID;
        address recipient;
        address attester;
        bool revocable;
        bytes data;
    }

    mapping(bytes32 => Attestation) public attestations;

    function createAttestation(
        bytes32 uid,
        bytes32 schema,
        address recipient,
        address attester
    ) external {
        attestations[uid] = Attestation({
            uid: uid,
            schema: schema,
            time: uint64(block.timestamp),
            expirationTime: 0,
            revocationTime: 0,
            refUID: bytes32(0),
            recipient: recipient,
            attester: attester,
            revocable: true,
            data: ""
        });
    }

    function getAttestation(bytes32 uid) external view returns (Attestation memory) {
        return attestations[uid];
    }
}

contract SessionManagerTest is Test {
    SessionManager public sessionManager;
    PolicyManager public policyManager;
    MockEAS public eas;
    MockERC20 public token;

    address public owner = address(1);
    address public payer = address(2);
    address public payee = address(3);
    address public issuer = address(4);

    uint256 public policyId;
    bytes32 public attestationUID;

    function setUp() public {
        vm.deal(payer, 100 ether);
        vm.deal(payee, 1 ether);

        vm.startPrank(owner);

        // Deploy PolicyManager
        PolicyManager policyImpl = new PolicyManager();
        bytes memory policyInitData = abi.encodeWithSelector(
            PolicyManager.initialize.selector
        );
        ERC1967Proxy policyProxy = new ERC1967Proxy(address(policyImpl), policyInitData);
        policyManager = PolicyManager(address(policyProxy));

        // Deploy MockEAS
        eas = new MockEAS();

        // Deploy SessionManager
        SessionManager sessionImpl = new SessionManager();
        bytes memory sessionInitData = abi.encodeWithSelector(
            SessionManager.initialize.selector,
            address(policyManager),
            address(eas)
        );
        ERC1967Proxy sessionProxy = new ERC1967Proxy(address(sessionImpl), sessionInitData);
        sessionManager = SessionManager(payable(address(sessionProxy)));

        // Deploy mock token
        token = new MockERC20();
        token.transfer(payer, 10000 * 10**18);

        vm.stopPrank();

        // Create a basic policy
        vm.startPrank(owner);
        policyId = policyManager.createPolicy(
            "Basic KYC",
            "Requires KYC attestation",
            block.timestamp,
            0,
            1
        );

        bytes32 schemaUID = keccak256("KYC_SCHEMA");
        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            schemaUID,
            issuer,
            true,
            30 days
        );
        vm.stopPrank();

        // Create attestation
        attestationUID = keccak256("attestation1");
        eas.createAttestation(attestationUID, schemaUID, payer, issuer);
    }

    function testCreateSessionWithNativeToken() public {
        vm.startPrank(payer);

        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),  // Native token
            1 ether,
            policyId,
            0,           // Default expiration
            "Payment for services"
        );

        assertTrue(sessionId != bytes32(0));

        (
            address returnedPayer,
            address returnedPayee,
            address returnedToken,
            uint256 returnedAmount,
            uint256 returnedPolicyId,
            SessionManager.SessionStatus status,
            ,
            ,
        ) = sessionManager.getSession(sessionId);

        assertEq(returnedPayer, payer);
        assertEq(returnedPayee, payee);
        assertEq(returnedToken, address(0));
        assertEq(returnedAmount, 1 ether);
        assertEq(returnedPolicyId, policyId);
        assertEq(uint(status), uint(SessionManager.SessionStatus.Pending));

        vm.stopPrank();
    }

    function testCreateSessionWithERC20Token() public {
        uint256 amount = 100 * 10**18;

        vm.startPrank(payer);
        token.approve(address(sessionManager), amount);

        bytes32 sessionId = sessionManager.createSession(
            payee,
            address(token),
            amount,
            policyId,
            0,
            "Token payment"
        );

        assertTrue(sessionId != bytes32(0));

        (
            ,
            ,
            address returnedToken,
            uint256 returnedAmount,
            ,
            ,
            ,
            ,
        ) = sessionManager.getSession(sessionId);

        assertEq(returnedToken, address(token));
        assertEq(returnedAmount, amount);

        vm.stopPrank();
    }

    function testCannotCreateSessionWithInvalidPolicy() public {
        vm.prank(payer);
        vm.expectRevert("Invalid or expired policy");
        sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            999,  // Non-existent policy
            0,
            ""
        );
    }

    function testCannotCreateSessionWithZeroAmount() public {
        vm.prank(payer);
        vm.expectRevert("Amount must be > 0");
        sessionManager.createSession(
            payee,
            address(0),
            0,
            policyId,
            0,
            ""
        );
    }

    function testCannotCreateSessionWithMismatchedETHAmount() public {
        vm.prank(payer);
        vm.expectRevert("Incorrect ETH amount");
        sessionManager.createSession{value: 0.5 ether}(
            payee,
            address(0),
            1 ether,  // Requested amount doesn't match msg.value
            policyId,
            0,
            ""
        );
    }

    function testAttachProof() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        vm.prank(payer);
        sessionManager.attachProof(
            sessionId,
            PolicyManager.ProofType.EASAttestation,
            attestationUID,
            issuer,
            0
        );

        SessionManager.ProofAttachment[] memory proofs = sessionManager.getSessionProofs(sessionId);
        assertEq(proofs.length, 1);
        assertEq(uint(proofs[0].proofType), uint(PolicyManager.ProofType.EASAttestation));
        assertEq(proofs[0].proofData, attestationUID);
        assertEq(proofs[0].issuer, issuer);
    }

    function testCannotAttachProofToNonexistentSession() public {
        vm.prank(payer);
        vm.expectRevert("Session does not exist");
        sessionManager.attachProof(
            bytes32(uint256(999)),
            PolicyManager.ProofType.EASAttestation,
            attestationUID,
            issuer,
            0
        );
    }

    function testUnauthorizedCannotAttachProof() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        address unauthorized = address(999);
        vm.prank(unauthorized);
        vm.expectRevert("Not authorized");
        sessionManager.attachProof(
            sessionId,
            PolicyManager.ProofType.EASAttestation,
            attestationUID,
            issuer,
            0
        );
    }

    function testVerifySession() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        vm.prank(payer);
        sessionManager.attachProof(
            sessionId,
            PolicyManager.ProofType.EASAttestation,
            attestationUID,
            issuer,
            0
        );

        bool verified = sessionManager.verifySession(sessionId);
        assertTrue(verified);

        (, , , , , SessionManager.SessionStatus status, , , ) = sessionManager.getSession(sessionId);
        assertEq(uint(status), uint(SessionManager.SessionStatus.Verified));
    }

    function testExecuteVerifiedSession() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        vm.prank(payer);
        sessionManager.attachProof(
            sessionId,
            PolicyManager.ProofType.EASAttestation,
            attestationUID,
            issuer,
            0
        );

        sessionManager.verifySession(sessionId);

        uint256 payeeBalanceBefore = payee.balance;

        vm.prank(payer);
        sessionManager.executeSession(sessionId);

        uint256 payeeBalanceAfter = payee.balance;
        assertEq(payeeBalanceAfter - payeeBalanceBefore, 1 ether);

        (, , , , , SessionManager.SessionStatus status, , , ) = sessionManager.getSession(sessionId);
        assertEq(uint(status), uint(SessionManager.SessionStatus.Executed));
    }

    function testCannotExecuteUnverifiedSession() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        vm.prank(payer);
        vm.expectRevert("Session not verified");
        sessionManager.executeSession(sessionId);
    }

    function testCancelSession() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        uint256 payerBalanceBefore = payer.balance;

        vm.prank(payer);
        sessionManager.cancelSession(sessionId);

        uint256 payerBalanceAfter = payer.balance;
        assertEq(payerBalanceAfter - payerBalanceBefore, 1 ether);

        (, , , , , SessionManager.SessionStatus status, , , ) = sessionManager.getSession(sessionId);
        assertEq(uint(status), uint(SessionManager.SessionStatus.Cancelled));
    }

    function testUnauthorizedCannotCancelSession() public {
        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            0,
            ""
        );

        address unauthorized = address(999);
        vm.prank(unauthorized);
        vm.expectRevert("Not authorized");
        sessionManager.cancelSession(sessionId);
    }

    function testExpireSession() public {
        uint256 expiration = block.timestamp + 1 days;

        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            expiration,
            ""
        );

        // Fast forward past expiration
        vm.warp(block.timestamp + 1 days + 1);

        uint256 payerBalanceBefore = payer.balance;

        sessionManager.expireSession(sessionId);

        uint256 payerBalanceAfter = payer.balance;
        assertEq(payerBalanceAfter - payerBalanceBefore, 1 ether);

        (, , , , , SessionManager.SessionStatus status, , , ) = sessionManager.getSession(sessionId);
        assertEq(uint(status), uint(SessionManager.SessionStatus.Expired));
    }

    function testCannotExpireSessionBeforeExpiration() public {
        uint256 expiration = block.timestamp + 1 days;

        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            expiration,
            ""
        );

        vm.expectRevert("Not expired yet");
        sessionManager.expireSession(sessionId);
    }

    function testCannotAttachProofToExpiredSession() public {
        uint256 expiration = block.timestamp + 1 days;

        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            expiration,
            ""
        );

        // Fast forward past expiration
        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(payer);
        vm.expectRevert("Session expired");
        sessionManager.attachProof(
            sessionId,
            PolicyManager.ProofType.EASAttestation,
            attestationUID,
            issuer,
            0
        );
    }

    // Fuzz tests

    function testFuzz_CreateSessionWithValidAmount(uint256 amount) public {
        vm.assume(amount > 0 && amount <= 10 ether);

        vm.deal(payer, amount + 1 ether);

        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: amount}(
            payee,
            address(0),
            amount,
            policyId,
            0,
            "Fuzz test"
        );

        (, , , uint256 returnedAmount, , , , , ) = sessionManager.getSession(sessionId);
        assertEq(returnedAmount, amount);
    }

    function testFuzz_SessionExpiration(uint256 duration) public {
        vm.assume(duration > 1 hours && duration < 365 days);

        uint256 expiration = block.timestamp + duration;

        vm.prank(payer);
        bytes32 sessionId = sessionManager.createSession{value: 1 ether}(
            payee,
            address(0),
            1 ether,
            policyId,
            expiration,
            ""
        );

        // Before expiration
        (, , , , , , , , uint256 expiresAt) = sessionManager.getSession(sessionId);
        assertEq(expiresAt, expiration);

        // After expiration
        vm.warp(block.timestamp + duration + 1);
        sessionManager.expireSession(sessionId);

        (, , , , , SessionManager.SessionStatus status, , , ) = sessionManager.getSession(sessionId);
        assertEq(uint(status), uint(SessionManager.SessionStatus.Expired));
    }
}
