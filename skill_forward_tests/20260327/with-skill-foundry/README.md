# Basic Reactive Demo

这个分支是从 `src/demos/basic` 保留历史后抽出来的最小 Foundry 项目。

## Layout

- `src/BasicDemoL1Contract.sol`
- `src/BasicDemoL1Callback.sol`
- `src/BasicDemoReactiveContract.sol`
- `src/reactive-lib/src/...` 仅包含编译所需的最小 `reactive-lib` 依赖子集

## Build

```bash
forge build
```

## Deploy Examples

部署源链合约：

```bash
forge create --broadcast --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY src/BasicDemoL1Contract.sol:BasicDemoL1Contract
```

部署目标链回调合约：

```bash
forge create --broadcast --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY src/BasicDemoL1Callback.sol:BasicDemoL1Callback --value 0.02ether --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR
```

部署 Reactive 合约：

```bash
forge create --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/BasicDemoReactiveContract.sol:BasicDemoReactiveContract --value 0.1ether --constructor-args $ORIGIN_CHAIN_ID $DESTINATION_CHAIN_ID $ORIGIN_ADDR 0x8cabf31d2b1b11ba52dbb302817a3c9c83e4b2a5194d35121ab1354d69f6a4cb $CALLBACK_ADDR
```

触发回调：

```bash
cast send $ORIGIN_ADDR --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY --value 0.001ether
```

`BasicDemoReactiveContract` 使用 `0.001 ether` 作为触发阈值，这里与合约实现保持一致。
