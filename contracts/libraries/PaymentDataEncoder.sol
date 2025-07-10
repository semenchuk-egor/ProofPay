// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PaymentDataEncoder {
    struct PaymentData {
        address sender;
        address recipient;
        uint256 amount;
        string description;
        uint256 timestamp;
    }
    
    function encode(PaymentData memory data) internal pure returns (bytes memory) {
        return abi.encode(
            data.sender,
            data.recipient,
            data.amount,
            data.description,
            data.timestamp
        );
    }
    
    function decode(bytes memory encodedData) internal pure returns (PaymentData memory) {
        (
            address sender,
            address recipient,
            uint256 amount,
            string memory description,
            uint256 timestamp
        ) = abi.decode(encodedData, (address, address, uint256, string, uint256));
        
        return PaymentData({
            sender: sender,
            recipient: recipient,
            amount: amount,
            description: description,
            timestamp: timestamp
        });
    }
    
    function hash(PaymentData memory data) internal pure returns (bytes32) {
        return keccak256(encode(data));
    }
}
