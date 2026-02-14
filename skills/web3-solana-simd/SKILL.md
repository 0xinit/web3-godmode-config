---
name: web3-solana-simd
description: Solana Improvement Document (SIMD) lookup and reference. Use when you need to understand Solana protocol changes, improvement proposals, or Solana-specific concepts. Includes key SIMDs inline and lookup instructions.
---

# SIMD Reference

## How to Look Up Any SIMD

### GitHub
```bash
gh api repos/solana-foundation/solana-improvement-documents/contents/proposals/{number}-{slug}.md
```

### Browse
- https://github.com/solana-foundation/solana-improvement-documents/tree/main/proposals

## SIMD Status Lifecycle

```
Draft -> Review -> Accepted -> Implemented -> Activated
                            -> Rejected
```

## Key Solana Concepts

### Accounts Model
- Everything is an account (programs, data, tokens)
- Accounts have: `owner` (program), `lamports`, `data`, `executable` flag
- Programs are stateless — state lives in separate data accounts
- Account size is fixed at creation (rent-exempt if funded)

### Rent
- Accounts must maintain minimum balance for rent exemption
- ~0.00089088 SOL per byte (at current rate)
- Rent-exempt = 2 years of rent pre-paid

### PDAs (Program Derived Addresses)
- Deterministic addresses derived from seeds + program ID
- Not on the ed25519 curve (no private key)
- Used as program-controlled accounts
- `findProgramAddress(seeds, programId)` returns canonical PDA + bump

### CPIs (Cross-Program Invocations)
- Programs calling other programs
- Max depth: 4 levels
- Signer privileges extend through CPI chain
- PDA signing via `invoke_signed`

## Core SIMDs

See [core-simds.md](./core-simds.md) for detailed summaries of key Solana improvement proposals.
