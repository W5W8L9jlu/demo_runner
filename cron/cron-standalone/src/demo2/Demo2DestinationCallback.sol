// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../../lib/reactive-lib/src/abstract-base/AbstractCallback.sol";

contract Demo2DestinationCallback is AbstractCallback {
    event CronWorkflowCompleted(
        bytes32 indexed originTxHash,
        uint256 indexed armNonce,
        address indexed armedBy,
        address reactiveSender,
        uint256 callbackCount
    );

    bytes32 public lastOriginTxHash;
    uint256 public lastArmNonce;
    address public lastArmedBy;
    address public lastReactiveSender;
    uint256 public callbackCount;

    constructor(address _callbackSender) AbstractCallback(_callbackSender) payable {}

    function executeCron(
        address reactiveSender,
        bytes32 originTxHash,
        uint256 armNonce,
        address armedBy
    ) external authorizedSenderOnly rvmIdOnly(reactiveSender) {
        lastOriginTxHash = originTxHash;
        lastArmNonce = armNonce;
        lastArmedBy = armedBy;
        lastReactiveSender = reactiveSender;
        callbackCount += 1;

        emit CronWorkflowCompleted(
            originTxHash,
            armNonce,
            armedBy,
            reactiveSender,
            callbackCount
        );
    }
}
