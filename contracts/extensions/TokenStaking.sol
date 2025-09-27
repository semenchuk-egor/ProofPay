// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenStaking is OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    IERC20 public stakingToken;
    
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 rewardDebt;
    }
    
    mapping(address => Stake) public stakes;
    uint256 public totalStaked;
    uint256 public rewardRate; // tokens per second
    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    
    function initialize(address _stakingToken, uint256 _rewardRate) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
    }
    
    function _authorizeUpgrade(address) internal override onlyOwner {}
    
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        
        stakingToken.transferFrom(msg.sender, address(this), amount);
        
        Stake storage userStake = stakes[msg.sender];
        userStake.amount += amount;
        userStake.timestamp = block.timestamp;
        totalStaked += amount;
        
        emit Staked(msg.sender, amount);
    }
    
    function withdraw(uint256 amount) external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount >= amount, "Insufficient balance");
        
        userStake.amount -= amount;
        totalStaked -= amount;
        stakingToken.transfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }
    
    function calculateReward(address user) public view returns (uint256) {
        Stake memory userStake = stakes[user];
        uint256 duration = block.timestamp - userStake.timestamp;
        return (userStake.amount * rewardRate * duration) / 1e18;
    }
}
