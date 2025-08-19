// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../core/PaymentValidator.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title DeployPaymentValidator
 * @notice Deployment script for PaymentValidator with UUPS proxy
 */
contract DeployPaymentValidator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address easAddress = vm.envAddress("EAS_CONTRACT_ADDRESS");
        bytes32 kycSchemaUID = vm.envBytes32("KYC_SCHEMA_UID");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy implementation
        PaymentValidator implementation = new PaymentValidator();
        console.log("PaymentValidator implementation deployed to:", address(implementation));
        
        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            PaymentValidator.initialize.selector,
            easAddress,
            kycSchemaUID
        );
        
        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        console.log("PaymentValidator proxy deployed to:", address(proxy));
        
        vm.stopBroadcast();
        
        // Verify the deployment
        PaymentValidator validator = PaymentValidator(address(proxy));
        console.log("EAS Address:", validator.easAddress());
        console.log("KYC Schema UID:", vm.toString(validator.kycSchemaUID()));
    }
}
