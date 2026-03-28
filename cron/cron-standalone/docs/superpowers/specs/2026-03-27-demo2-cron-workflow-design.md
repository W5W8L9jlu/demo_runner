# Demo2 Cron Workflow Design

**Goal:** Extend the standalone cron repository with a minimal three-contract workflow that satisfies the submission format for `demo2`: one origin transaction on Base Sepolia, one reactive transaction on Reactive Lasna, and one destination callback transaction on Base Sepolia.

**Scope:** This design adds a new `demo2` flow without replacing the original `CronDemo.sol`. The new flow uses a user-triggered origin event to arm the workflow, then waits for a `Cron10` event before issuing exactly one callback to the destination contract.

## Architecture

- `Demo2OriginArm` lives on Base Sepolia and emits a `WorkflowArmed` event when a user calls `arm()`.
- `Demo2CronWorkflowReactive` lives on Reactive Lasna and subscribes to two event sources: the origin `WorkflowArmed` event and the Lasna `Cron10` system event.
- `Demo2DestinationCallback` lives on Base Sepolia and accepts a callback only from the Base Sepolia callback proxy and only for the Reactive contract deployer's ReactVM ID.

## Workflow

1. Deploy `Demo2OriginArm` on Base Sepolia.
2. Deploy `Demo2DestinationCallback` on Base Sepolia from the same EOA that will deploy the Reactive contract.
3. Deploy `Demo2CronWorkflowReactive` on Reactive Lasna with the Base Sepolia origin and destination addresses plus the `Cron10` topic.
4. Call `arm()` on the origin contract.
5. Wait for the next `Cron10` event on Lasna.
6. Observe the resulting Reactive transaction and the callback transaction on Base Sepolia.

## Constraints

- The destination contract must be deployed by the same EOA as the Reactive contract so `rvmIdOnly` validation succeeds.
- The Base Sepolia callback proxy address must match the current official address.
- Both destination and reactive contracts must be deployed with enough balance for one callback cycle.

## Evidence

- Final proof appends `demo2` details to `D:/demo_runner/workflow-proof/workflow-proof.md` without removing `demo1`.
- The Markdown embeds one screenshot, and the same screenshot is saved as a standalone file in the same directory.
