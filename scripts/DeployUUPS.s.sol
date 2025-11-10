// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

interface IProofPay {
    function initialize(address owner_, address verifier_) external;
}

interface IERC1967Proxy {
    function implementation() external view returns (address);
}

contract ERC1967Proxy {
    constructor(address logic, bytes memory data) payable {
        (bool ok,) = logic.delegatecall(abi.encodeWithSignature("proxiableUUID()"));
        require(ok, "not uups");
        bytes32 slot = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
        assembly { sstore(slot, logic) }
        if (data.length > 0) {
            (bool s,) = address(this).delegatecall(data);
            require(s, "init");
        }
    }
}

contract DeployUUPS is Script {
    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        address verifier = vm.envAddress("VERIFIER_ADDRESS");
        address deployer = vm.envAddress("DEPLOYER");
        address impl;

        vm.startBroadcast(deployer);
        bytes memory bytecode = vm.getCode("out/ProofPay.sol/ProofPay.json");
        assembly {
            impl := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(impl) { revert(0, 0) }
        }
        bytes memory initData = abi.encodeWithSelector(IProofPay.initialize.selector, owner, verifier);
        ERC1967Proxy proxy = new ERC1967Proxy(impl, initData);
        vm.stopBroadcast();

        console2.log("IMPLEMENTATION", impl);
        console2.log("PROXY", address(proxy));
    }
}
