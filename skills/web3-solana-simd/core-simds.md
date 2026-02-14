# Core Solana SIMDs

## SIMD-0033 — Timely Vote Credits
**Status**: Activated
Validators earn more vote credits for voting quickly (within 2 slots vs 32 slots).
Incentivizes faster consensus and reduces confirmation times.

## SIMD-0046 — Versioned Transactions
**Status**: Activated
V0 transactions with Address Lookup Tables (ALTs) increase the number of accounts per transaction from 35 to 256+.
Essential for complex DeFi operations.
```typescript
// Using versioned transactions
import { VersionedTransaction, TransactionMessage } from "@solana/web3.js"

const messageV0 = new TransactionMessage({
  payerKey: payer.publicKey,
  recentBlockhash,
  instructions,
}).compileToV0Message([lookupTableAccount])

const tx = new VersionedTransaction(messageV0)
```

## SIMD-0047 — Syscall Probing
**Status**: Accepted
Allows programs to query whether a syscall is available before calling it.
Enables forward-compatible programs.

## SIMD-0072 — Priority Fee Market
**Status**: Activated
Local fee markets per account. Priority fees are per compute unit.
```typescript
// Set priority fee
const modifyComputeUnits = ComputeBudgetProgram.setComputeUnitLimit({ units: 200_000 })
const addPriorityFee = ComputeBudgetProgram.setComputeUnitPrice({ microLamports: 1000 })
```

## SIMD-0083 — Token Extensions (Token-2022)
**Status**: Activated
Extended SPL Token program with built-in features:
- Transfer fees
- Confidential transfers
- Interest-bearing tokens
- Non-transferable tokens (soulbound)
- Permanent delegate
- Transfer hooks
- Metadata and metadata pointer
- Group and member tokens

## SIMD-0096 — Rewards in Full Blocks
**Status**: Accepted
Distribute block rewards within the block rather than at epoch boundary.
Reduces stake-weighted leader inequality.

## SIMD-0148 — Token Metadata
**Status**: Activated
On-chain metadata directly in Token-2022 mint accounts.
Eliminates need for Metaplex for basic metadata.

## Key Constants

| Parameter | Value |
|-----------|-------|
| Slot time | ~400ms |
| Epoch length | ~2 days (~432,000 slots) |
| Max tx size | 1232 bytes |
| Max accounts per tx (legacy) | 35 |
| Max accounts per tx (v0 + ALT) | 256+ |
| Max CPI depth | 4 |
| Compute unit limit (default) | 200,000 |
| Compute unit limit (max) | 1,400,000 |
| Minimum rent (per byte) | ~0.00089 SOL |
| Account data max | 10 MB |

## Network Endpoints

| Network | RPC | WebSocket |
|---------|-----|-----------|
| Mainnet | https://api.mainnet-beta.solana.com | wss://api.mainnet-beta.solana.com |
| Devnet | https://api.devnet.solana.com | wss://api.devnet.solana.com |
| Testnet | https://api.testnet.solana.com | wss://api.testnet.solana.com |

Note: Public endpoints are rate-limited. Use Helius, QuickNode, or Alchemy for production.
