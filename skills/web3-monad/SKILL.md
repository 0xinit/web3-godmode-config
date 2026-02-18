---
name: web3-monad
description: Monad L1 development. 400ms blocks, parallel execution, gas-limit charging, opcode repricing, staking, deploy.
---

# Monad L1 Development Skill

## What this Skill is for
Use this Skill when the user asks for:
- Monad chain configuration (mainnet/testnet RPC, chain IDs, explorers)
- MonadBFT consensus details (rounds, finality, tail-fork resistance)
- Parallel and deferred execution architecture
- Deploying contracts on Monad (Foundry, Hardhat, Remix)
- Verifying contracts (MonadVision/Sourcify, Monadscan/Etherscan, Socialscan)
- Gas pricing and opcode cost differences from Ethereum
- EIP-7702 account delegation on Monad
- Staking precompile integration (delegate, undelegate, compound, claim)
- Execution events (low-latency shared-memory consumer)
- Monad ecosystem (bridges, oracles, indexers, wallets, tokens)
- Performance patterns for parallel-friendly contracts
- Differences between Monad and Ethereum

## Chain Configuration

### Mainnet

| Property | Value |
|----------|-------|
| Chain ID | **143** |
| Currency | MON (18 decimals) |
| EVM Version | Pectra fork |
| Block Time | 400ms |
| Finality | 800ms (2 slots) |
| Block Gas Limit | 200M |
| Tx Gas Limit | 30M |
| Gas Throughput | 500M gas/sec |
| Min Base Fee | 100 MON-gwei |
| Node Version | v0.12.7 / MONAD_EIGHT |

#### RPC Endpoints (Mainnet)

| URL | Provider | Rate Limit | Batch | Notes |
|-----|----------|------------|-------|-------|
| `https://rpc.monad.xyz` / `wss://rpc.monad.xyz` | QuickNode | 25 rps | 100 | Default |
| `https://rpc1.monad.xyz` / `wss://rpc1.monad.xyz` | Alchemy | 15 rps | 100 | No debug/trace |
| `https://rpc2.monad.xyz` / `wss://rpc2.monad.xyz` | Goldsky Edge | 300/10s | 10 | Historical state |
| `https://rpc3.monad.xyz` / `wss://rpc3.monad.xyz` | Ankr | 300/10s | 10 | No debug |
| `https://rpc-mainnet.monadinfra.com` / `wss://rpc-mainnet.monadinfra.com` | MF | 20 rps | 1 | Historical state |

#### Block Explorers

| Explorer | URL |
|----------|-----|
| MonadVision | https://monadvision.com |
| Monadscan | https://monadscan.com |
| Socialscan | https://monad.socialscan.io |
| Visualization | https://gmonads.com |
| Traces | Phalcon Explorer, Tenderly |
| UserOps | Jiffyscan |

### Testnet

| Property | Value |
|----------|-------|
| Chain ID | **10143** |
| RPC | `https://testnet-rpc.monad.xyz` |
| WebSocket | `wss://testnet-rpc.monad.xyz` |
| Explorer | https://testnet.monadexplorer.com |
| Faucet | https://testnet.monad.xyz |

## Key Differences from Ethereum

| Feature | Ethereum | Monad |
|---------|----------|-------|
| Block time | 12s | 400ms |
| Finality | ~12-18 min | 800ms (2 slots) |
| Throughput | ~10 TPS | 10,000+ TPS |
| Gas charging | Gas **used** | Gas **limit** |
| Max contract size | 24.5 KB | **128 KB** |
| Blob txns (EIP-4844) | Supported | **Not supported** |
| Global mempool | Yes | **No** (leader-based forwarding) |
| Account cold access | 2,600 gas | **10,100 gas** |
| Storage cold access | 2,100 gas | **8,100 gas** |
| Reserve balance | None | **~10 MON** per account |
| `TIMESTAMP` granularity | 1 per block | 2-3 blocks share same second |
| Precompile 0x0100 | N/A | **EIP-7951 secp256r1 (P256)** |
| EIP-7702 min balance | None | **10 MON** for delegated EOAs |
| EIP-7702 CREATE/CREATE2 | Allowed | **Banned** for delegated EOAs |
| Tx types supported | 0,1,2,3,4 | 0,1,2,4 (**no type 3**) |

### Gas Limit Charging Model

Monad charges `gas_limit * price_per_gas`, NOT `gas_used * price_per_gas`. This enables asynchronous execution — execution happens after consensus, so gas used isn't known at inclusion time.

```
gas_paid = gas_limit * price_per_gas
price_per_gas = min(base_price_per_gas + priority_price_per_gas, max_price_per_gas)
```

**Developer impact**: Set gas limits explicitly for fixed-cost operations (e.g., 21000 for transfers) to avoid overpaying.

### Reserve Balance

Every account maintains a ~10 MON reserve for gas across the next 3 blocks. Transactions that would reduce balance below this threshold are rejected. This prevents DoS during asynchronous execution.

## Block Lifecycle & Finality

```
Proposed → Voted (speculative finality, T+1) → Finalized (T+2) → Verified/state root (T+5)
```

| Phase | Latency | When to Use |
|-------|---------|-------------|
| Voted | 400ms | UI updates, most dApps |
| Finalized | 800ms | Conservative apps |
| Verified | ~2s | Exchanges, bridges, stablecoins |

## viem Chain Definition

```typescript
import { defineChain } from "viem";

export const monad = defineChain({
  id: 143,
  name: "Monad",
  nativeCurrency: { name: "MON", symbol: "MON", decimals: 18 },
  rpcUrls: {
    default: { http: ["https://rpc.monad.xyz"], webSocket: ["wss://rpc.monad.xyz"] },
  },
  blockExplorers: {
    default: { name: "MonadVision", url: "https://monadvision.com" },
    monadscan: { name: "Monadscan", url: "https://monadscan.com" },
  },
});

export const monadTestnet = defineChain({
  id: 10143,
  name: "Monad Testnet",
  nativeCurrency: { name: "MON", symbol: "MON", decimals: 18 },
  rpcUrls: {
    default: { http: ["https://testnet-rpc.monad.xyz"], webSocket: ["wss://testnet-rpc.monad.xyz"] },
  },
  blockExplorers: {
    default: { name: "Monad Explorer", url: "https://testnet.monadexplorer.com" },
  },
  testnet: true,
});
```

## Foundry Configuration

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
evm_version = "prague"

[rpc_endpoints]
monad = "https://rpc.monad.xyz"
monad_testnet = "https://testnet-rpc.monad.xyz"

[etherscan]
monad = { key = "${ETHERSCAN_API_KEY}", chain = 143, url = "https://api.etherscan.io/v2/api?chainid=143" }
```

## Hardhat Configuration (v2)

```typescript
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "prague",
      metadata: { bytecodeHash: "ipfs" }, // Required for Sourcify
    },
  },
  networks: {
    monadTestnet: {
      url: "https://testnet-rpc.monad.xyz",
      chainId: 10143,
      accounts: [process.env.PRIVATE_KEY!],
    },
    monadMainnet: {
      url: "https://rpc.monad.xyz",
      chainId: 143,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
  etherscan: {
    customChains: [{
      network: "monadMainnet",
      chainId: 143,
      urls: {
        apiURL: "https://api.etherscan.io/v2/api?chainid=143",
        browserURL: "https://monadscan.com",
      },
    }],
  },
  sourcify: {
    enabled: true,
    apiUrl: "https://sourcify-api-monad.blockvision.org",
    browserUrl: "https://monadvision.com",
  },
};
```

## Smart Contract Tips

- **Gas optimization still matters** — even with cheap gas, optimize for users
- **Same security model** — all Solidity best practices (CEI, reentrancy guards) apply
- **Parallel-friendly design** — contracts with per-user mappings parallelize better than global counters
- **128 KB contract limit** — larger contracts are possible but still optimize for gas
- **No code changes needed** for parallelism — it's at the runtime level
- **`block.timestamp`** — 2-3 blocks may share the same second; don't rely on sub-second granularity
- **No blob transactions** — EIP-4844 type 3 txns are not supported

## WebSocket Subscriptions

Standard `eth_subscribe` plus Monad-specific extensions:

```
newHeads        — standard new block headers
logs            — standard log filtering
monadNewHeads   — Monad-specific block headers with extra fields
monadLogs       — Monad-specific log events
```

## Execution Events (Advanced)

For ultra-low-latency data consumption, Monad exposes execution events via shared-memory ring buffers. Consumer runs on same host as node. ~1 microsecond latency. Supported in C, C++, and Rust only.

Use execution events when JSON-RPC can't keep up with 10,000 TPS throughput. For most dApps, standard WebSocket subscriptions are sufficient.

## Required Tooling Versions

| Tool | Minimum Version |
|------|----------------|
| Foundry | Monad fork (`foundryup --network monad`) |
| viem | 2.40.0+ |
| alloy-chains | 0.2.20+ |
| Hardhat Solidity | evmVersion: "prague" |

## Additional Reference Files

| File | Contents |
|------|----------|
| `architecture.md` | MonadBFT consensus, parallel execution, deferred execution, MonadDb, JIT, RaptorCast |
| `deployment.md` | Foundry + Hardhat deploy/verify step-by-step guides |
| `gas-and-opcodes.md` | Gas pricing model, opcode repricing tables, precompile costs |
| `staking.md` | Staking precompile ABI, functions, events, epoch mechanics |
| `ecosystem.md` | Token addresses, bridges, oracles, indexers, canonical contracts |
