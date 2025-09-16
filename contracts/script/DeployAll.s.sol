// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../core/PaymentValidator.sol";
import "../core/ProofToken.sol";
import "../extensions/PaymentBatch.sol";
import "../extensions/PaymentEscrow.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title DeployAll
 * @notice Deploy all ProofPay contracts with proxies
 */
contract DeployAll is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address easAddress = vm.envAddress("EAS_CONTRACT_ADDRESS");
        bytes32 kycSchemaUID = vm.envBytes32("KYC_SCHEMA_UID");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== Deploying ProofPay Contracts ===");
        console.log("");
        
        // 1. Deploy ProofToken
        console.log("1. Deploying ProofToken...");
        ProofToken tokenImpl = new ProofToken();
        bytes memory tokenInitData = abi.encodeWithSelector(
            ProofToken.initialize.selector
        );
        ERC1967Proxy tokenProxy = new ERC1967Proxy(
            address(tokenImpl),
            tokenInitData
        );
        ProofToken token = ProofToken(address(tokenProxy));
        console.log("ProofToken deployed at:", address(token));
        console.log("");
        
        // 2. Deploy PaymentValidator
        console.log("2. Deploying PaymentValidator...");
        PaymentValidator validatorImpl = new PaymentValidator();
        bytes memory validatorInitData = abi.encodeWithSelector(
            PaymentValidator.initialize.selector,
            easAddress,
            kycSchemaUID
        );
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(validatorImpl),
            validatorInitData
        );
        PaymentValidator validator = PaymentValidator(address(validatorProxy));
        console.log("PaymentValidator deployed at:", address(validator));
        console.log("");
        
        // 3. Deploy PaymentBatch
        console.log("3. Deploying PaymentBatch...");
        PaymentBatch batchImpl = new PaymentBatch();
        bytes memory batchInitData = abi.encodeWithSelector(
            PaymentBatch.initialize.selector,
            address(validator)
        );
        ERC1967Proxy batchProxy = new ERC1967Proxy(
            address(batchImpl),
            batchInitData
        );
        PaymentBatch batch = PaymentBatch(address(batchProxy));
        console.log("PaymentBatch deployed at:", address(batch));
        console.log("");
        
        // 4. Deploy PaymentEscrow
        console.log("4. Deploying PaymentEscrow...");
        PaymentEscrow escrowImpl = new PaymentEscrow();
        bytes memory escrowInitData = abi.encodeWithSelector(
            PaymentEscrow.initialize.selector,
            address(validator)
        );
        ERC1967Proxy escrowProxy = new ERC1967Proxy(
            address(escrowImpl),
            escrowInitData
        );
        PaymentEscrow escrow = PaymentEscrow(address(escrowProxy));
        console.log("PaymentEscrow deployed at:", address(escrow));
        console.log("");
        
        vm.stopBroadcast();
        
        // Print summary
        console.log("=== Deployment Summary ===");
        console.log("ProofToken:", address(token));
        console.log("PaymentValidator:", address(validator));
        console.log("PaymentBatch:", address(batch));
        console.log("PaymentEscrow:", address(escrow));
        console.log("");
        console.log("Update your .env file with these addresses!");
    }
}
