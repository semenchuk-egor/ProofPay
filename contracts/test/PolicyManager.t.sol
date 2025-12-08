// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../core/PolicyManager.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PolicyManagerTest is Test {
    PolicyManager public policyManager;

    address public owner = address(1);
    address public creator1 = address(2);
    address public creator2 = address(3);
    address public issuer1 = address(4);
    address public issuer2 = address(5);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy with proxy
        PolicyManager implementation = new PolicyManager();
        bytes memory initData = abi.encodeWithSelector(
            PolicyManager.initialize.selector
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        policyManager = PolicyManager(address(proxy));

        vm.stopPrank();
    }

    function testCreateBasicPolicy() public {
        vm.startPrank(creator1);

        uint256 policyId = policyManager.createPolicy(
            "KYC Required",
            "Payment requires valid KYC attestation",
            block.timestamp,
            0, // No expiration
            1  // Minimum 1 proof
        );

        assertEq(policyId, 1);
        assertTrue(policyManager.isPolicyValid(policyId));

        (
            string memory name,
            string memory description,
            address creator,
            uint256 minProofsRequired,
            ,
            bool active,
            ,
        ) = policyManager.getPolicy(policyId);

        assertEq(name, "KYC Required");
        assertEq(description, "Payment requires valid KYC attestation");
        assertEq(creator, creator1);
        assertEq(minProofsRequired, 1);
        assertTrue(active);

        vm.stopPrank();
    }

    function testCannotCreatePolicyWithEmptyName() public {
        vm.prank(creator1);
        vm.expectRevert("Policy name required");
        policyManager.createPolicy("", "Description", block.timestamp, 0, 1);
    }

    function testCannotCreatePolicyWithInvalidValidity() public {
        vm.prank(creator1);
        vm.expectRevert("Invalid validity period");
        policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp + 100,
            block.timestamp,  // validUntil < validFrom
            1
        );
    }

    function testAddProofRequirement() public {
        vm.startPrank(creator1);

        uint256 policyId = policyManager.createPolicy(
            "Multi-Proof Policy",
            "Requires multiple proofs",
            block.timestamp,
            0,
            2
        );

        bytes32 schemaUID = keccak256("KYC_SCHEMA");

        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            schemaUID,
            issuer1,
            true,
            30 days
        );

        PolicyManager.ProofRequirement[] memory requirements = policyManager.getPolicyRequirements(policyId);
        assertEq(requirements.length, 1);
        assertEq(uint(requirements[0].proofType), uint(PolicyManager.ProofType.EASAttestation));
        assertEq(requirements[0].schemaUID, schemaUID);
        assertEq(requirements[0].issuer, issuer1);
        assertTrue(requirements[0].required);
        assertEq(requirements[0].validityPeriod, 30 days);

        vm.stopPrank();
    }

    function testCannotAddProofRequirementToNonexistentPolicy() public {
        vm.prank(creator1);
        vm.expectRevert("Policy does not exist");
        policyManager.addProofRequirement(
            999,
            PolicyManager.ProofType.EASAttestation,
            bytes32(0),
            issuer1,
            true,
            0
        );
    }

    function testCannotAddProofRequirementWithInvalidIssuer() public {
        vm.startPrank(creator1);

        uint256 policyId = policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp,
            0,
            1
        );

        vm.expectRevert("Invalid issuer");
        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            bytes32(0),
            address(0),  // Invalid issuer
            true,
            0
        );

        vm.stopPrank();
    }

    function testUnauthorizedCannotAddProofRequirement() public {
        vm.prank(creator1);
        uint256 policyId = policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp,
            0,
            1
        );

        vm.prank(creator2);
        vm.expectRevert("Not authorized");
        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            bytes32(0),
            issuer1,
            true,
            0
        );
    }

    function testOwnerCanAddProofRequirement() public {
        vm.prank(creator1);
        uint256 policyId = policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp,
            0,
            1
        );

        vm.prank(owner);
        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            bytes32(0),
            issuer1,
            true,
            0
        );

        PolicyManager.ProofRequirement[] memory requirements = policyManager.getPolicyRequirements(policyId);
        assertEq(requirements.length, 1);
    }

    function testTogglePolicyActive() public {
        vm.startPrank(creator1);

        uint256 policyId = policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp,
            0,
            1
        );

        assertTrue(policyManager.isPolicyValid(policyId));

        policyManager.setPolicyActive(policyId, false);
        assertFalse(policyManager.isPolicyValid(policyId));

        policyManager.setPolicyActive(policyId, true);
        assertTrue(policyManager.isPolicyValid(policyId));

        vm.stopPrank();
    }

    function testUnauthorizedCannotTogglePolicyActive() public {
        vm.prank(creator1);
        uint256 policyId = policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp,
            0,
            1
        );

        vm.prank(creator2);
        vm.expectRevert("Not authorized");
        policyManager.setPolicyActive(policyId, false);
    }

    function testPolicyValidityPeriods() public {
        vm.startPrank(creator1);

        uint256 futureStart = block.timestamp + 100;
        uint256 futureEnd = block.timestamp + 200;

        uint256 policyId = policyManager.createPolicy(
            "Future Policy",
            "Becomes valid in the future",
            futureStart,
            futureEnd,
            1
        );

        // Not valid yet
        assertFalse(policyManager.isPolicyValid(policyId));

        // Fast forward to valid period
        vm.warp(block.timestamp + 150);
        assertTrue(policyManager.isPolicyValid(policyId));

        // Fast forward past expiration
        vm.warp(block.timestamp + 100);
        assertFalse(policyManager.isPolicyValid(policyId));

        vm.stopPrank();
    }

    function testGetPoliciesByCreator() public {
        vm.startPrank(creator1);

        policyManager.createPolicy("Policy 1", "Description 1", block.timestamp, 0, 1);
        policyManager.createPolicy("Policy 2", "Description 2", block.timestamp, 0, 1);
        policyManager.createPolicy("Policy 3", "Description 3", block.timestamp, 0, 1);

        uint256[] memory creatorPolicies = policyManager.getPoliciesByCreator(creator1);
        assertEq(creatorPolicies.length, 3);
        assertEq(creatorPolicies[0], 1);
        assertEq(creatorPolicies[1], 2);
        assertEq(creatorPolicies[2], 3);

        vm.stopPrank();
    }

    function testMultipleProofTypes() public {
        vm.startPrank(creator1);

        uint256 policyId = policyManager.createPolicy(
            "Multi-Type Policy",
            "Requires different proof types",
            block.timestamp,
            0,
            3
        );

        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            keccak256("KYC"),
            issuer1,
            true,
            30 days
        );

        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.ZKProof,
            keccak256("PRIVACY"),
            issuer2,
            true,
            0
        );

        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.Signature,
            keccak256("SIGNATURE"),
            issuer1,
            false,
            7 days
        );

        PolicyManager.ProofRequirement[] memory requirements = policyManager.getPolicyRequirements(policyId);
        assertEq(requirements.length, 3);
        assertEq(uint(requirements[0].proofType), uint(PolicyManager.ProofType.EASAttestation));
        assertEq(uint(requirements[1].proofType), uint(PolicyManager.ProofType.ZKProof));
        assertEq(uint(requirements[2].proofType), uint(PolicyManager.ProofType.Signature));

        vm.stopPrank();
    }

    // Fuzz tests

    function testFuzz_CreatePolicyWithValidParams(
        string calldata name,
        string calldata description,
        uint256 validFrom,
        uint256 minProofs
    ) public {
        vm.assume(bytes(name).length > 0 && bytes(name).length < 100);
        vm.assume(validFrom > block.timestamp);
        vm.assume(minProofs > 0 && minProofs < 10);

        vm.prank(creator1);
        uint256 policyId = policyManager.createPolicy(
            name,
            description,
            validFrom,
            0,
            minProofs
        );

        assertTrue(policyId > 0);
        (, , , uint256 returnedMinProofs, , , , ) = policyManager.getPolicy(policyId);
        assertEq(returnedMinProofs, minProofs);
    }

    function testFuzz_AddProofRequirement(
        uint256 validityPeriod,
        bool required
    ) public {
        vm.assume(validityPeriod < 365 days);

        vm.startPrank(creator1);

        uint256 policyId = policyManager.createPolicy(
            "Test",
            "Description",
            block.timestamp,
            0,
            1
        );

        policyManager.addProofRequirement(
            policyId,
            PolicyManager.ProofType.EASAttestation,
            keccak256("TEST"),
            issuer1,
            required,
            validityPeriod
        );

        PolicyManager.ProofRequirement[] memory requirements = policyManager.getPolicyRequirements(policyId);
        assertEq(requirements.length, 1);
        assertEq(requirements[0].validityPeriod, validityPeriod);
        assertEq(requirements[0].required, required);

        vm.stopPrank();
    }
}
