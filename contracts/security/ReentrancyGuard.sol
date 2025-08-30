// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @title ReentrancyGuard
 * @notice Custom reentrancy guard with additional features
 */
abstract contract ReentrancyGuard is ReentrancyGuardUpgradeable {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    event ReentrancyAttemptDetected(address indexed caller);

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Custom modifier with event emission
     */
    modifier nonReentrantWithLog() {
        if (_status == ENTERED) {
            emit ReentrancyAttemptDetected(msg.sender);
            revert("ReentrancyGuard: reentrant call");
        }

        _status = ENTERED;
        _;
        _status = NOT_ENTERED;
    }
}
