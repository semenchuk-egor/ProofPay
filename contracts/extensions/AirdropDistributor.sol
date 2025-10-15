// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../libraries/MerkleProof.sol";

contract AirdropDistributor is OwnableUpgradeable, UUPSUpgradeable {
    IERC20 public token;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;
    
    event Claimed(address indexed account, uint256 amount);
    
    function initialize(address _token, bytes32 _merkleRoot) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
    }
    
    function _authorizeUpgrade(address) internal override onlyOwner {}
    
    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");
        
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
        
        claimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
        
        emit Claimed(msg.sender, amount);
    }
}
