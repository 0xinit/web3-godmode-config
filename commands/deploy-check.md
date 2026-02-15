---
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
argument-hint: [chain] [contract-name]
description: Pre-deployment verification checklist for smart contracts
---

Run a deployment verification checklist for `$ARGUMENTS`.

## Pre-Deploy Verification

### 1. Target Chain
- Confirm chain: ask user if not specified
- Verify RPC URL is correct for target chain
- Verify chain ID matches expected
- Check deployer has sufficient native token for gas

### 2. Contract Readiness
- `forge build` passes with zero errors/warnings
- `forge test` passes — ALL tests green
- `forge coverage` — critical paths covered
- Solidity version pinned (no `^`)
- Optimizer settings documented

### 3. Constructor Arguments
- List all constructor arguments and their values
- Verify addresses are correct for target chain (not testnet addrs on mainnet)
- Verify numeric values are in correct units (wei, not ether)

### 4. Proxy Setup (if upgradeable)
- Implementation contract deploys first
- Proxy points to correct implementation
- Initialize function called with correct args
- `_disableInitializers()` in implementation constructor
- Storage layout verified with `forge inspect`

### 5. Deployment Script
- Script tested with `--broadcast` omitted (dry run)
- Private key loaded from env var (not hardcoded)
- Verification step included (`--verify`)
- For mainnet: `--slow` flag set

### 6. Post-Deploy Verification
- [ ] Contract verified on block explorer
- [ ] Initial state correct (read key storage values)
- [ ] Admin/owner address is correct
- [ ] For mainnet: ownership transferred to multi-sig
- [ ] Integration test against deployed contract passes

### 7. Documentation
- [ ] Deployed addresses recorded
- [ ] Constructor args recorded
- [ ] Deployment tx hash recorded
- [ ] Block number recorded

## Chain-Specific Notes

| Chain | Special Considerations |
|-------|----------------------|
| Ethereum | High gas — optimize aggressively, use `--slow` |
| Base/Optimism/Arbitrum | L2 gas model, verify L1 data costs |
| Abstract | Requires `--zksync` flag, foundry-zksync |
| Monad | Standard EVM tooling, 1s blocks |
| MegaETH | Check `eth_sendRawTransactionSync` support |

Report: GO / NO-GO decision with reasoning.
