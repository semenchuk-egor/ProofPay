// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../core/PolicyManager.sol";
import "../core/SessionManager.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title DeployBase
 * @notice Deployment script for Base Sepolia and Base Mainnet
 */
contract DeployBase is Script {
    // Base Sepolia chain ID: 84532
    // Base Mainnet chain ID: 8453

    address constant BASE_SEPOLIA_EAS = 0x4200000000000000000000000000000000000021;
    address constant BASE_MAINNET_EAS = 0x4200000000000000000000000000000000000021;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying from:", deployer);
        console.log("Chain ID:", block.chainid);

        // Determine EAS address based on chain
        address easAddress;
        if (block.chainid == 84532) {
            easAddress = BASE_SEPOLIA_EAS;
            console.log("Deploying to Base Sepolia");
        } else if (block.chainid == 8453) {
            easAddress = BASE_MAINNET_EAS;
            console.log("Deploying to Base Mainnet");
        } else {
            revert("Unsupported chain - use Base Sepolia (84532) or Base Mainnet (8453)");
        }

        console.log("EAS Registry:", easAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy PolicyManager implementation
        console.log("\n=== Deploying PolicyManager ===");
        PolicyManager policyImpl = new PolicyManager();
        console.log("PolicyManager implementation:", address(policyImpl));

        // Deploy PolicyManager proxy
        bytes memory policyInitData = abi.encodeWithSelector(
            PolicyManager.initialize.selector
        );
        ERC1967Proxy policyProxy = new ERC1967Proxy(
            address(policyImpl),
            policyInitData
        );
        PolicyManager policyManager = PolicyManager(address(policyProxy));
        console.log("PolicyManager proxy:", address(policyManager));

        // Deploy SessionManager implementation
        console.log("\n=== Deploying SessionManager ===");
        SessionManager sessionImpl = new SessionManager();
        console.log("SessionManager implementation:", address(sessionImpl));

        // Deploy SessionManager proxy
        bytes memory sessionInitData = abi.encodeWithSelector(
            SessionManager.initialize.selector,
            address(policyManager),
            easAddress
        );
        ERC1967Proxy sessionProxy = new ERC1967Proxy(
            address(sessionImpl),
            sessionInitData
        );
        SessionManager sessionManager = SessionManager(payable(address(sessionProxy)));
        console.log("SessionManager proxy:", address(sessionManager));

        vm.stopBroadcast();

        // Log deployment summary
        console.log("\n=== Deployment Summary ===");
        console.log("Network:", block.chainid == 84532 ? "Base Sepolia" : "Base Mainnet");
        console.log("Deployer:", deployer);
        console.log("");
        console.log("PolicyManager:");
        console.log("  Implementation:", address(policyImpl));
        console.log("  Proxy:", address(policyManager));
        console.log("");
        console.log("SessionManager:");
        console.log("  Implementation:", address(sessionImpl));
        console.log("  Proxy:", address(sessionManager));
        console.log("");
        console.log("EAS Registry:", easAddress);

        // Save deployment addresses to JSON
        _saveDeployment(
            block.chainid == 84532 ? "base-sepolia" : "base-mainnet",
            address(policyImpl),
            address(policyManager),
            address(sessionImpl),
            address(sessionManager),
            easAddress
        );
    }

    function _saveDeployment(
        string memory network,
        address policyImpl,
        address policyProxy,
        address sessionImpl,
        address sessionProxy,
        address easAddress
    ) internal {
        string memory json = string(abi.encodePacked(
            '{\n',
            '  "network": "', network, '",\n',
            '  "chainId": ', vm.toString(block.chainid), ',\n',
            '  "timestamp": ', vm.toString(block.timestamp), ',\n',
            '  "deployer": "', vm.toString(msg.sender), '",\n',
            '  "contracts": {\n',
            '    "PolicyManager": {\n',
            '      "implementation": "', vm.toString(policyImpl), '",\n',
            '      "proxy": "', vm.toString(policyProxy), '"\n',
            '    },\n',
            '    "SessionManager": {\n',
            '      "implementation": "', vm.toString(sessionImpl), '",\n',
            '      "proxy": "', vm.toString(sessionProxy), '"\n',
            '    },\n',
            '    "EASRegistry": "', vm.toString(easAddress), '"\n',
            '  }\n',
            '}'
        ));

        string memory filename = string(abi.encodePacked(
            "./deployments/",
            network,
            "-",
            vm.toString(block.timestamp),
            ".json"
        ));

        vm.writeFile(filename, json);
        console.log("\nDeployment info saved to:", filename);
    }
}
