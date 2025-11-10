/* SPDX-License-Identifier: MIT */
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../contracts/ProofPay.sol";

contract DeployUUPS is Script {
    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        address verifier = vm.envAddress("VERIFIER_ADDRESS");
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        ProofPay impl = new ProofPay();
        bytes memory data = abi.encodeWithSelector(ProofPay.initialize.selector, owner, verifier);
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), data);
        vm.stopBroadcast();

        console2.log("Implementation", address(impl));
        console2.log("Proxy", address(proxy));
    }
}
