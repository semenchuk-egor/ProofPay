// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../core/PaymentValidator.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

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
        bytes memory data
    ) external {
        attestations[uid] = Attestation({
            uid: uid,
            schema: schema,
            time: uint64(block.timestamp),
            expirationTime: 0,
            revocationTime: 0,
            refUID: bytes32(0),
            recipient: recipient,
            attester: msg.sender,
            revocable: true,
            data: data
        });
    }
    
    function getAttestation(bytes32 uid) external view returns (Attestation memory) {
        return attestations[uid];
    }
}

contract PaymentValidatorTest is Test {
    PaymentValidator public validator;
    MockEAS public eas;
    
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    bytes32 public kycSchemaUID = keccak256("KYC_SCHEMA");
    bytes32 public attestation1;
    bytes32 public attestation2;
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock EAS
        eas = new MockEAS();
        
        // Deploy PaymentValidator
        PaymentValidator implementation = new PaymentValidator();
        bytes memory initData = abi.encodeWithSelector(
            PaymentValidator.initialize.selector,
            address(eas),
            kycSchemaUID
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        validator = PaymentValidator(address(proxy));
        
        // Create attestations
        attestation1 = keccak256("attestation1");
        attestation2 = keccak256("attestation2");
        
        bytes memory kycData = abi.encode(uint8(3), block.timestamp, keccak256("doc1"));
        eas.createAttestation(attestation1, kycSchemaUID, user1, kycData);
        eas.createAttestation(attestation2, kycSchemaUID, user2, kycData);
        
        vm.stopPrank();
    }
    
    function testLinkAttestation() public {
        vm.prank(user1);
        validator.linkAttestation(attestation1);
        
        assertTrue(validator.canPay(user1));
    }
    
    function testCannotLinkWrongRecipient() public {
        vm.prank(user2);
        vm.expectRevert("Not attestation recipient");
        validator.linkAttestation(attestation1);
    }
    
    function testValidatePayment() public {
        // Link attestations
        vm.prank(user1);
        validator.linkAttestation(attestation1);
        
        vm.prank(user2);
        validator.linkAttestation(attestation2);
        
        // Validate payment
        assertTrue(validator.validatePayment(user1, user2, 100));
    }
    
    function testCannotPayWithoutAttestation() public {
        vm.prank(user1);
        validator.linkAttestation(attestation1);
        
        // user2 has no attestation
        vm.expectRevert("Recipient not verified");
        validator.validatePayment(user1, user2, 100);
    }
}
