---
name: solidity-security
description: Solidity security patterns and vulnerability prevention. Use before writing any Solidity code, during code review, or before deployment. Covers reentrancy, access control, integer safety, oracle manipulation, flash loans, and gas optimization.
---

# Solidity Security

## Reentrancy

### CEI Pattern (Checks-Effects-Interactions) — NON-NEGOTIABLE
```solidity
function withdraw(uint256 amount) external {
    // CHECKS
    require(balances[msg.sender] >= amount, InsufficientBalance());

    // EFFECTS (update state BEFORE external call)
    balances[msg.sender] -= amount;

    // INTERACTIONS (external call LAST)
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, TransferFailed());
}
```

### Additional Protection
- Use `ReentrancyGuard` from OpenZeppelin for complex functions
- Cross-function reentrancy: guard shared state across multiple functions
- Read-only reentrancy: be aware of view functions reading stale state during callbacks

## Access Control

| Pattern | Use When |
|---------|----------|
| `Ownable` | Single admin, simple contracts |
| `AccessControl` (roles) | Multiple roles, granular permissions |
| Multi-sig (Safe) | High-value operations, mainnet |
| Timelock | Governance, delayed execution |

- Never use `tx.origin` for authorization — use `msg.sender`
- Check `msg.sender` in modifiers, not function bodies (unless complex logic)
- Consider 2-step ownership transfer (`Ownable2Step`)

## Integer Safety

- Solidity 0.8+ has built-in overflow/underflow protection
- Use `unchecked` blocks ONLY when overflow is mathematically impossible
- Document WHY each `unchecked` block is safe
- Use `type(uint256).max` instead of magic numbers
- Watch for division-before-multiplication precision loss

## Front-Running / MEV

| Attack | Mitigation |
|--------|------------|
| Sandwich attacks | Slippage protection, deadline params |
| Front-running | Commit-reveal schemes |
| MEV extraction | Use Flashbots, private mempools |
| Oracle manipulation | TWAP, multiple sources |

## Oracle Security

- Never use spot price from a single DEX — use TWAP
- Chainlink: check `updatedAt` freshness, `answeredInRound >= roundId`
- Handle oracle downtime gracefully (circuit breaker)
- Use multiple oracle sources with fallback logic

## Delegate Call Risks

- Storage layout MUST match between proxy and implementation
- Never `delegatecall` to untrusted addresses
- Implementation contracts must call `_disableInitializers()` in constructor
- Watch for storage collision in proxy patterns

## Flash Loan Vectors

- Assume any amount of tokens can be borrowed in a single transaction
- Don't rely on token balances for governance weight in the same block
- Use snapshot mechanisms for voting power
- Add time-weighted checks for critical operations

## Storage Collision (Proxies)

- Use EIP-1967 storage slots for proxy state
- Never modify storage layout order in upgrades — only append
- Use `/// @custom:storage-location` for namespaced storage (EIP-7201)
- Run `forge inspect` to verify storage layout before upgrade

## Detailed References

- [Vulnerability Checklist](./vulnerability-checklist.md) — SWC registry mapping
- [Gas Optimization](./gas-optimization.md) — Storage packing, calldata, custom errors
