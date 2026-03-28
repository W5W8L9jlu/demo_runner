# Demo2 Cron Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and run a minimal three-stage `demo2` cron workflow across Base Sepolia and Reactive Lasna, then append proof to the existing workflow Markdown.

**Architecture:** Add three small contracts under `src/demo2`: an origin arming contract, a reactive cron workflow contract, and a destination callback contract. Use one Foundry test to lock the core behavior before deployment, then deploy manually with Foundry/cast and capture explorer evidence.

**Tech Stack:** Solidity, Foundry (`forge`, `cast`), Reactive Lasna, Base Sepolia, Reactscan, Etherscan, Playwright screenshot capture

---

### Task 1: Add the local test harness

**Files:**
- Create: `D:/demo_runner/cron/cron-standalone/test/Demo2CronWorkflow.t.sol`

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run `forge test --match-path test/Demo2CronWorkflow.t.sol` and verify it fails for missing contracts**
- [ ] **Step 3: Implement the minimal demo2 contracts**
- [ ] **Step 4: Run the same test command and verify it passes**

### Task 2: Add the demo2 contracts

**Files:**
- Create: `D:/demo_runner/cron/cron-standalone/src/demo2/Demo2OriginArm.sol`
- Create: `D:/demo_runner/cron/cron-standalone/src/demo2/Demo2DestinationCallback.sol`
- Create: `D:/demo_runner/cron/cron-standalone/src/demo2/Demo2CronWorkflowReactive.sol`
- Create: `D:/demo_runner/cron/cron-standalone/lib/reactive-lib/src/abstract-base/AbstractCallback.sol`

- [ ] **Step 1: Keep the origin contract to one job: emit an arming event**
- [ ] **Step 2: Keep the destination contract to one job: validate and record the callback**
- [ ] **Step 3: Keep the reactive contract to two jobs: remember the arm event, then fire exactly one callback on the next cron**
- [ ] **Step 4: Re-run the targeted test and then `forge build`**

### Task 3: Deploy and execute demo2

**Files:**
- Modify later: `D:/demo_runner/workflow-proof/workflow-proof.md`

- [ ] **Step 1: Fund the Base Sepolia deployer for the destination contract if needed**
- [ ] **Step 2: Deploy origin and destination on Base Sepolia**
- [ ] **Step 3: Deploy reactive on Reactive Lasna**
- [ ] **Step 4: Call `arm()` on the origin contract**
- [ ] **Step 5: Wait for the next `Cron10` and collect the reactive and destination transactions**

### Task 4: Append proof

**Files:**
- Modify: `D:/demo_runner/workflow-proof/workflow-proof.md`
- Create: `D:/demo_runner/workflow-proof/demo2-workflow-proof.png`

- [ ] **Step 1: Capture a screenshot that shows the linked workflow proof**
- [ ] **Step 2: Append `demo2` submission data without deleting `demo1`**
- [ ] **Step 3: Embed the screenshot in the Markdown and keep a standalone copy in the same directory**
