// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract Demo2OriginArm {
    event WorkflowArmed(
        address indexed user,
        uint256 indexed nonce,
        uint256 timestamp
    );

    uint256 public nextNonce;

    function arm() external returns (uint256 nonce) {
        nonce = ++nextNonce;
        emit WorkflowArmed(msg.sender, nonce, block.timestamp);
    }
}
