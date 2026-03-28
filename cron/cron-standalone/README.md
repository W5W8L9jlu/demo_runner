# Reactive Cron Demo

This repository is the history-preserved standalone extraction of `src/demos/cron`
from `Reactive-Network/reactive-smart-contract-demos`.

## Layout

- `src/CronDemo.sol`
- `lib/reactive-lib/src/...` vendored into this repository from commit `edbdabec7bc222edbe23fce4980ed6d72c38b828`

## Setup

No submodule initialization is required. The minimal `reactive-lib` files needed by
this demo are already included in the repository.

## Build

```bash
forge build
```

## Deploy

Set these environment variables first:

- `CRON_TOPIC`
- `REACTIVE_RPC`
- `REACTIVE_PRIVATE_KEY`

Deploy with:

```bash
forge create --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/CronDemo.sol:BasicCronContract --value 0.1ether --constructor-args $CRON_TOPIC
```

If your Foundry build does not support `--broadcast` for `forge create`, remove that flag and rerun the command.

## Pause And Resume

Pause the cron subscription:

```bash
cast send $REACTIVE_ADDR "pause()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

Resume the cron subscription:

```bash
cast send $REACTIVE_ADDR "resume()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```
