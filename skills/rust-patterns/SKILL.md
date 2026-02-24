---
name: rust-patterns
description: Rust and Anchor/Solana patterns. Account validation, PDA derivation, CPI security, error handling.
---

# Rust & Anchor Patterns

## Anchor Account Validation

### Account Constraints
```rust
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = authority,
        space = 8 + MyAccount::INIT_SPACE,
        seeds = [b"my-seed", authority.key().as_ref()],
        bump,
    )]
    pub my_account: Account<'info, MyAccount>,

    #[account(mut)]
    pub authority: Signer<'info>,

    pub system_program: Program<'info, System>,
}
```

### Essential Constraints

| Constraint | Purpose |
|-----------|---------|
| `mut` | Account is mutable |
| `signer` | Must sign transaction |
| `has_one = field` | Account field matches another account |
| `seeds = [...]` | PDA derivation seeds |
| `bump` | PDA bump seed (canonical) |
| `constraint = expr` | Custom boolean check |
| `close = target` | Close account, send rent to target |
| `token::mint = mint` | Validate token account's mint |
| `token::authority = auth` | Validate token authority |

### PDA Derivation
```rust
// Finding PDA (off-chain)
let (pda, bump) = Pubkey::find_program_address(
    &[b"seed", user.as_ref()],
    &program_id,
);

// Always use canonical bump (from find_program_address)
// Never accept user-supplied bumps
#[account(
    seeds = [b"seed", authority.key().as_ref()],
    bump,  // Anchor stores and uses canonical bump
)]
```

### CPI (Cross-Program Invocation) Security
```rust
// CPI with PDA signer
let seeds = &[b"vault", authority.key().as_ref(), &[bump]];
let signer_seeds = &[&seeds[..]];

let cpi_ctx = CpiContext::new_with_signer(
    token_program.to_account_info(),
    Transfer {
        from: vault.to_account_info(),
        to: destination.to_account_info(),
        authority: vault_authority.to_account_info(),
    },
    signer_seeds,
);
token::transfer(cpi_ctx, amount)?;
```

### Signer Verification
- ALWAYS use `Signer<'info>` type for accounts that must sign
- NEVER use `AccountInfo` and manually check `is_signer` unless necessary
- Validate account ownership: `Account<'info, T>` auto-checks program ownership

### Token Account Validation
```rust
#[account(
    mut,
    token::mint = mint,
    token::authority = user,
)]
pub user_token_account: Account<'info, TokenAccount>,
```

## General Rust Patterns

### Error Handling
```rust
// Use thiserror for library errors
#[derive(Debug, thiserror::Error)]
pub enum MyError {
    #[error("insufficient funds: have {available}, need {required}")]
    InsufficientFunds { available: u64, required: u64 },

    #[error("account not found: {0}")]
    NotFound(String),
}

// Use anyhow for application errors
fn process() -> anyhow::Result<()> {
    let data = fetch_data().context("failed to fetch data")?;
    Ok(())
}

// NEVER in production:
value.unwrap()     // panics
value.expect("x")  // panics with message
```

### Prefer References
```rust
// BAD: Takes ownership unnecessarily
fn process(data: String) -> bool { data.contains("x") }

// GOOD: Borrows
fn process(data: &str) -> bool { data.contains("x") }
```

### Iterator Patterns
```rust
// BAD: Manual loop with push
let mut results = Vec::new();
for item in items {
    if item.active {
        results.push(item.value);
    }
}

// GOOD: Iterator chain
let results: Vec<_> = items.iter()
    .filter(|item| item.active)
    .map(|item| item.value)
    .collect();
```

### Derive Traits
```rust
// Derive common traits for data types
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(pub u64);

// Use #[must_use] for results that shouldn't be ignored
#[must_use]
pub fn validate(input: &str) -> bool { ... }
```

## Common Pitfalls

See [common-pitfalls.md](./common-pitfalls.md) for:
- Missing signer/owner checks
- PDA bump canonicalization
- Arithmetic overflow in token math
- Reinitialization attacks
