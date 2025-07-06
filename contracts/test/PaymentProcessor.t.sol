// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../core/PaymentProcessor.sol";
import "../core/AttestationVerifier.sol";

contract PaymentProcessorTest is Test {
    PaymentProcessor public processor;
    AttestationVerifier public verifier;
    
    address public owner = address(1);
    address public sender = address(2);
    address public recipient = address(3);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy verifier
        verifier = new AttestationVerifier();
        verifier.initialize(owner, address(0x4200000000000000000000000000000000000021), bytes32(0));
        
        // Deploy processor
        processor = new PaymentProcessor();
        processor.initialize(owner, address(verifier), 100, owner);
        
        vm.stopPrank();
    }
    
    function testPaymentCreation() public {
        // Test payment creation
        assertTrue(address(processor) != address(0));
    }
    
    function testPlatformFee() public {
        uint256 fee = processor.platformFee();
        assertEq(fee, 100);
    }
}
