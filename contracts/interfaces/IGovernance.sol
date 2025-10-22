// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernance {
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);
    
    function castVote(uint256 proposalId, uint8 support) external returns (uint256);
    
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) external payable returns (uint256);
}
