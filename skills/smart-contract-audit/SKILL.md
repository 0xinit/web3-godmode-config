---
name: smart-contract-audit
description: Pre-deployment smart contract audit checklist. Manual invoke only — use before deploying any smart contract to testnet or mainnet. Walks through static analysis, access control, upgrade safety, economic vectors, gas DoS, external dependencies, events, and documentation.
disable-model-invocation: true
---

# Smart Contract Audit Checklist

Run this checklist before ANY deployment. Go section by section. Do not skip.

## 1. Static Analysis

- [ ] Run `forge build` — zero warnings
- [ ] Run `slither .` (if installed) — review all findings
- [ ] Run `forge test -vvv` — all tests pass
- [ ] Run `forge coverage` — check coverage on critical paths
- [ ] No floating pragma (`^`) — pin exact Solidity version
- [ ] No unused imports, variables, or functions

## 2. Access Control

- [ ] All external/public functions have appropriate access modifiers
- [ ] Admin functions use `onlyOwner`, `onlyRole`, or equivalent
- [ ] No `tx.origin` checks (use `msg.sender`)
- [ ] Ownership transfer is 2-step (`Ownable2Step`)
- [ ] Critical operations behind timelock or multi-sig
- [ ] Initialize functions can only be called once (if upgradeable)

## 3. Reentrancy & CEI

- [ ] ALL external calls follow Checks-Effects-Interactions
- [ ] `ReentrancyGuard` on functions with external calls + state changes
- [ ] Cross-function reentrancy considered (shared state)
- [ ] Read-only reentrancy considered (view functions during callbacks)

## 4. Upgrade Safety (if applicable)

- [ ] Storage layout preserved from previous version
- [ ] No constructor logic (use `initializer`)
- [ ] `_disableInitializers()` in implementation constructor
- [ ] EIP-1967 storage slots for proxy state
- [ ] `forge inspect` storage layout compared with previous version
- [ ] Upgrade function access-controlled

## 5. Economic / DeFi Vectors

- [ ] Flash loan resistance (no same-block governance/pricing)
- [ ] Slippage protection on swaps (min amount out, deadline)
- [ ] Oracle freshness checks (Chainlink: `updatedAt`, `answeredInRound`)
- [ ] No reliance on single-source spot prices
- [ ] Token approval patterns safe (no infinite approve without reason)
- [ ] Fee-on-transfer tokens handled (if accepting arbitrary ERC-20s)
- [ ] Rebasing tokens handled (if accepting arbitrary ERC-20s)

## 6. Gas & DoS

- [ ] No unbounded loops over user-controlled arrays
- [ ] Pull-over-push pattern for payments
- [ ] Gas limits on external calls considered
- [ ] No block gas limit attacks on iteration
- [ ] Fallback/receive functions don't have complex logic

## 7. External Dependencies

- [ ] OpenZeppelin version pinned and up to date
- [ ] External contract addresses verified (not hardcoded incorrectly)
- [ ] Interface compatibility verified with actual deployed contracts
- [ ] No dependency on `block.timestamp` for critical logic (15s variance)
- [ ] No dependency on `block.number` for timing (varies by chain)

## 8. Events & NatSpec

- [ ] Events emitted for ALL state changes
- [ ] Events have indexed parameters for key fields (up to 3)
- [ ] NatSpec `@notice` on all public/external functions
- [ ] NatSpec `@param` for all parameters
- [ ] NatSpec `@return` for all return values
- [ ] NatSpec `@dev` for implementation notes

## 9. Deployment Verification

- [ ] Constructor arguments documented and verified
- [ ] Deployment script tested on local fork
- [ ] Contract verified on block explorer
- [ ] Initial state verified after deployment
- [ ] Admin addresses are correct (not deployer EOA for mainnet)

## Severity Classification

| Severity | Impact | Action |
|----------|--------|--------|
| **Critical** | Loss of funds, access control bypass | BLOCK deployment |
| **High** | Significant financial risk, DoS | BLOCK deployment |
| **Medium** | Limited impact, edge cases | Fix before mainnet |
| **Low** | Best practice, gas optimization | Fix when convenient |
| **Info** | Style, documentation | Optional |

## Post-Audit

After completing this checklist:
1. Document all findings with severity
2. Fix all Critical and High issues
3. Re-run checklist after fixes
4. Consider professional audit for high-value contracts
