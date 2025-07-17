// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../core/PaymentProcessor.sol";
import "../core/AttestationVerifier.sol";
import "../tokens/ProofToken.sol";
import "../tokens/PaymentProofNFT.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScript is Script {
    address constant EAS_CONTRACT = 0x4200000000000000000000000000000000000021;
    bytes32 constant PAYMENT_SCHEMA = keccak256("PaymentSchema");
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying with:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ProofToken
        ProofToken proofTokenImpl = new ProofToken();
        bytes memory proofTokenInit = abi.encodeWithSelector(
            ProofToken.initialize.selector,
            deployer
        );
        ERC1967Proxy proofTokenProxy = new ERC1967Proxy(
            address(proofTokenImpl),
            proofTokenInit
        );
        console.log("ProofToken:", address(proofTokenProxy));
        
        // Deploy PaymentProofNFT
        PaymentProofNFT nftImpl = new PaymentProofNFT();
        bytes memory nftInit = abi.encodeWithSelector(
            PaymentProofNFT.initialize.selector,
            deployer
        );
        ERC1967Proxy nftProxy = new ERC1967Proxy(
            address(nftImpl),
            nftInit
        );
        console.log("PaymentProofNFT:", address(nftProxy));
        
        // Deploy AttestationVerifier
        AttestationVerifier verifierImpl = new AttestationVerifier();
        bytes memory verifierInit = abi.encodeWithSelector(
            AttestationVerifier.initialize.selector,
            deployer,
            EAS_CONTRACT,
            PAYMENT_SCHEMA
        );
        ERC1967Proxy verifierProxy = new ERC1967Proxy(
            address(verifierImpl),
            verifierInit
        );
        console.log("AttestationVerifier:", address(verifierProxy));
        
        // Deploy PaymentProcessor
        PaymentProcessor processorImpl = new PaymentProcessor();
        bytes memory processorInit = abi.encodeWithSelector(
            PaymentProcessor.initialize.selector,
            deployer,
            address(verifierProxy),
            100,
            deployer
        );
        ERC1967Proxy processorProxy = new ERC1967Proxy(
            address(processorImpl),
            processorInit
        );
        console.log("PaymentProcessor:", address(processorProxy));
        
        vm.stopBroadcast();
    }
}
