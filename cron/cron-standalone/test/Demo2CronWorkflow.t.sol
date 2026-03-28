// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../src/demo2/Demo2CronWorkflowReactive.sol";

interface Vm {
    struct Log {
        bytes32[] topics;
        bytes data;
        address emitter;
    }

    function recordLogs() external;
    function getRecordedLogs() external returns (Log[] memory);
}

contract Demo2CronWorkflowTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 private constant BASE_SEPOLIA_CHAIN_ID = 84532;
    uint256 private constant LASNA_CHAIN_ID = 5318007;
    uint256 private constant CRON10_TOPIC =
        0x04463f7c1651e6b9774d7f85c85bb94654e3c46ca79b0c16fb16d4183307b687;
    uint256 private constant WORKFLOW_ARMED_TOPIC =
        uint256(keccak256("WorkflowArmed(address,uint256,uint256)"));
    bytes32 private constant CALLBACK_EVENT_SIG =
        keccak256("Callback(uint256,address,uint64,bytes)");
    bytes32 private constant ORIGIN_TX_HASH =
        0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;

    address private constant SYSTEM_CONTRACT =
        0x0000000000000000000000000000000000fffFfF;
    address private constant ORIGIN_CONTRACT =
        0x0000000000000000000000000000000000001001;
    address private constant DESTINATION_CALLBACK =
        0x0000000000000000000000000000000000002002;
    address private constant ARMED_BY =
        0x000000000000000000000000000000000000bEEF;

    function testCronAfterArmEmitsExactlyOneCallback() public {
        Demo2CronWorkflowReactive reactive = new Demo2CronWorkflowReactive(
            BASE_SEPOLIA_CHAIN_ID,
            BASE_SEPOLIA_CHAIN_ID,
            ORIGIN_CONTRACT,
            DESTINATION_CALLBACK,
            CRON10_TOPIC
        );

        reactive.react(_originLog(uint256(ORIGIN_TX_HASH), 7, ARMED_BY));

        require(reactive.isArmed(), "expected workflow to be armed");
        require(reactive.pendingArmNonce() == 7, "expected pending nonce");
        require(reactive.pendingOriginTxHash() == ORIGIN_TX_HASH, "expected pending tx hash");

        vm.recordLogs();
        reactive.react(_cronLog(10));
        Vm.Log[] memory logs = vm.getRecordedLogs();

        require(logs.length == 1, "expected one callback event");
        require(logs[0].emitter == address(reactive), "expected reactive emitter");
        require(logs[0].topics.length == 4, "expected indexed callback topics");
        require(logs[0].topics[0] == CALLBACK_EVENT_SIG, "expected callback event signature");
        require(uint256(logs[0].topics[1]) == BASE_SEPOLIA_CHAIN_ID, "expected destination chain");
        require(
            address(uint160(uint256(logs[0].topics[2]))) == DESTINATION_CALLBACK,
            "expected destination callback address"
        );
        require(uint256(logs[0].topics[3]) == 1000000, "expected callback gas limit");

        require(!reactive.isArmed(), "expected workflow to be cleared");
        require(reactive.callbackCount() == 1, "expected one callback count");
        require(reactive.lastProcessedOriginTxHash() == ORIGIN_TX_HASH, "expected processed tx hash");
        require(reactive.lastProcessedArmNonce() == 7, "expected processed nonce");
        require(reactive.lastProcessedArmedBy() == ARMED_BY, "expected processed user");
        require(reactive.lastCronBlock() == 10, "expected tracked cron block");

        vm.recordLogs();
        reactive.react(_cronLog(20));
        logs = vm.getRecordedLogs();

        require(logs.length == 0, "expected no second callback");
        require(reactive.callbackCount() == 1, "expected callback count to remain one");
    }

    function testCronWithoutArmDoesNothing() public {
        Demo2CronWorkflowReactive reactive = new Demo2CronWorkflowReactive(
            BASE_SEPOLIA_CHAIN_ID,
            BASE_SEPOLIA_CHAIN_ID,
            ORIGIN_CONTRACT,
            DESTINATION_CALLBACK,
            CRON10_TOPIC
        );

        vm.recordLogs();
        reactive.react(_cronLog(10));
        Vm.Log[] memory logs = vm.getRecordedLogs();

        require(logs.length == 0, "expected no callback without arm");
        require(!reactive.isArmed(), "expected workflow to remain idle");
        require(reactive.callbackCount() == 0, "expected no callbacks");
    }

    function _originLog(
        uint256 txHash,
        uint256 nonce,
        address armedBy
    ) private pure returns (IReactive.LogRecord memory log) {
        log.chain_id = BASE_SEPOLIA_CHAIN_ID;
        log._contract = ORIGIN_CONTRACT;
        log.topic_0 = WORKFLOW_ARMED_TOPIC;
        log.topic_1 = uint256(uint160(armedBy));
        log.topic_2 = nonce;
        log.tx_hash = txHash;
    }

    function _cronLog(uint256 blockNumber) private pure returns (IReactive.LogRecord memory log) {
        log.chain_id = LASNA_CHAIN_ID;
        log._contract = SYSTEM_CONTRACT;
        log.topic_0 = CRON10_TOPIC;
        log.block_number = blockNumber;
    }
}
