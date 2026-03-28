// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../../lib/reactive-lib/src/abstract-base/AbstractPausableReactive.sol";

contract Demo2CronWorkflowReactive is AbstractPausableReactive {
    uint256 public constant WORKFLOW_ARMED_TOPIC =
        uint256(keccak256("WorkflowArmed(address,uint256,uint256)"));
    uint64 public constant CALLBACK_GAS_LIMIT = 1000000;

    uint256 public immutable originChainId;
    uint256 public immutable destinationChainId;
    uint256 public immutable cronTopic;
    address public immutable originContract;
    address public immutable destinationCallback;

    bool public isArmed;
    address public pendingArmedBy;
    uint256 public pendingArmNonce;
    bytes32 public pendingOriginTxHash;

    address public lastProcessedArmedBy;
    uint256 public lastProcessedArmNonce;
    bytes32 public lastProcessedOriginTxHash;
    uint256 public lastCronBlock;
    uint256 public armCount;
    uint256 public callbackCount;

    constructor(
        uint256 _originChainId,
        uint256 _destinationChainId,
        address _originContract,
        address _destinationCallback,
        uint256 _cronTopic
    ) payable {
        originChainId = _originChainId;
        destinationChainId = _destinationChainId;
        originContract = _originContract;
        destinationCallback = _destinationCallback;
        cronTopic = _cronTopic;

        if (!vm) {
            service.subscribe(
                originChainId,
                originContract,
                WORKFLOW_ARMED_TOPIC,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
            service.subscribe(
                block.chainid,
                address(service),
                cronTopic,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

    function getPausableSubscriptions() internal view override returns (Subscription[] memory result) {
        result = new Subscription[](2);
        result[0] = Subscription(
            originChainId,
            originContract,
            WORKFLOW_ARMED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        result[1] = Subscription(
            block.chainid,
            address(service),
            cronTopic,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }

    function react(LogRecord calldata log) external vmOnly {
        if (
            log.chain_id == originChainId &&
            log._contract == originContract &&
            log.topic_0 == WORKFLOW_ARMED_TOPIC
        ) {
            isArmed = true;
            pendingArmedBy = address(uint160(log.topic_1));
            pendingArmNonce = log.topic_2;
            pendingOriginTxHash = bytes32(log.tx_hash);
            armCount += 1;
            return;
        }

        if (
            log._contract == address(service) &&
            log.topic_0 == cronTopic &&
            isArmed
        ) {
            bytes32 originTxHash = pendingOriginTxHash;
            uint256 armNonce = pendingArmNonce;
            address armedBy = pendingArmedBy;

            isArmed = false;
            pendingArmedBy = address(0);
            pendingArmNonce = 0;
            pendingOriginTxHash = bytes32(0);

            lastProcessedArmedBy = armedBy;
            lastProcessedArmNonce = armNonce;
            lastProcessedOriginTxHash = originTxHash;
            lastCronBlock = log.block_number;
            callbackCount += 1;

            bytes memory payload = abi.encodeWithSignature(
                "executeCron(address,bytes32,uint256,address)",
                address(0),
                originTxHash,
                armNonce,
                armedBy
            );
            emit Callback(
                destinationChainId,
                destinationCallback,
                CALLBACK_GAS_LIMIT,
                payload
            );
        }
    }
}
