// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract EmergencyPause is PausableUpgradeable, OwnableUpgradeable {
    event EmergencyPauseActivated(address indexed by);
    event EmergencyPauseDeactivated(address indexed by);
    
    function pause() external onlyOwner {
        _pause();
        emit EmergencyPauseActivated(msg.sender);
    }
    
    function unpause() external onlyOwner {
        _unpause();
        emit EmergencyPauseDeactivated(msg.sender);
    }
}
