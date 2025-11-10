// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/ProofPay.sol";

interface IUUPS {
    function upgradeTo(address newImplementation) external;
}

contract UpgradeUUPS is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address proxy = vm.envAddress("PROXY_ADDRESS");

        vm.startBroadcast(pk);
        ProofPay impl = new ProofPay();
        IUUPS(proxy).upgradeTo(address(impl));
        vm.stopBroadcast();

        console2.log("NewImplementation", address(impl));
        console2.log("Proxy", proxy);
    }
}
