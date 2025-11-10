// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

interface IUUPSLike {
    function upgradeTo(address newImplementation) external;
}

contract UpgradeUUPS is Script {
    function run() external {
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address newImpl = vm.envAddress("NEW_IMPLEMENTATION");
        address upgrader = vm.envAddress("UPGRADER");
        vm.startBroadcast(upgrader);
        IUUPSLike(proxy).upgradeTo(newImpl);
        vm.stopBroadcast();
    }
}
