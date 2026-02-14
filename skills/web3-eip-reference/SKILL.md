---
name: web3-eip-reference
description: Ethereum Improvement Proposal (EIP) lookup and reference. Use when you need to understand an EIP, implement an ERC standard, or reference Ethereum protocol changes. Includes top 50 EIPs inline and lookup instructions for any EIP.
---

# EIP Reference

## How to Look Up Any EIP

### GitHub (most reliable)
```bash
gh api repos/ethereum/EIPs/contents/EIPS/eip-{number}.md --jq '.content' | base64 -d
```

### Context7
```
resolve-library-id("ethereum EIPs") -> query-docs("EIP-{number}")
```

### Web
- https://eips.ethereum.org/EIPS/eip-{number}
- https://ethereum.org/en/eips/

## EIP vs ERC

| Type | Scope | Examples |
|------|-------|---------|
| **EIP** | Protocol-level changes (consensus, networking) | EIP-1559, EIP-4844 |
| **ERC** | Application-level standards (tokens, wallets) | ERC-20, ERC-721 |

ERCs are a subset of EIPs. "ERC-20" and "EIP-20" refer to the same proposal.

## Status Lifecycle

```
Draft -> Review -> Last Call -> Final
                             -> Stagnant (no activity 6+ months)
                             -> Withdrawn
```

Only **Final** status EIPs should be relied on for production code.

## Core EIPs (inline)

See [core-eips.md](./core-eips.md) for detailed summaries of the top 50 EIPs covering:
- Token Standards (ERC-20, ERC-721, ERC-1155, ERC-4626)
- Account Abstraction (EIP-4337, EIP-7702)
- Signatures (EIP-191, EIP-712)
- Proxy Patterns (EIP-1967, EIP-1822, EIP-2535)
- Gas & Protocol (EIP-1559, EIP-2929, EIP-4844)
- DeFi (EIP-3156, EIP-4626)
- Smart Accounts (EIP-7579, EIP-7710)
