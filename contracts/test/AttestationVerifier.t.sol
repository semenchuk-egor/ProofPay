// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../core/AttestationVerifier.sol";

contract AttestationVerifierTest is Test {
    AttestationVerifier public verifier;
    address public owner = address(1);
    address public attester = address(2);
    
    function setUp() public {
        vm.startPrank(owner);
        verifier = new AttestationVerifier();
        verifier.initialize(owner, address(0x4200000000000000000000000000000000000021), bytes32(0));
        vm.stopPrank();
    }
    
    function testAddTrustedAttester() public {
        vm.prank(owner);
        verifier.addTrustedAttester(attester);
        
        assertTrue(verifier.trustedAttesters(attester));
    }
    
    function testRemoveTrustedAttester() public {
        vm.startPrank(owner);
        verifier.addTrustedAttester(attester);
        verifier.removeTrustedAttester(attester);
        vm.stopPrank();
        
        assertFalse(verifier.trustedAttesters(attester));
    }
    
    function testOnlyOwnerCanAddAttester() public {
        vm.prank(attester);
        vm.expectRevert();
        verifier.addTrustedAttester(attester);
    }
}
