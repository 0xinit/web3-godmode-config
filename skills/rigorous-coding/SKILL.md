---
name: rigorous-coding
description: Rigorous coding standards. Pre-implementation checklist, error handling, state management, naming, verification.
---

# Rigorous Coding Standards

## Pre-Implementation Checklist (MANDATORY)

Before writing ANY code, state:

1. **Assumptions**: What must be true for this to work?
2. **Edge cases**: What inputs/states could break this?
3. **Correctness criteria**: How do we know it's right?
4. **Failure modes**: What happens when things go wrong?

Do not write code before stating assumptions.
Do not claim correctness you haven't verified.
Do not handle only the happy path.

## Error Handling

### Rules
- No empty catch blocks — ever
- Handle async rejection explicitly (try/catch or .catch)
- Handle network failures (timeout, disconnect, DNS)
- Errors should propagate with context, not be swallowed
- Distinguish recoverable from fatal errors

### Patterns
```
// BAD: Swallowed error
try { riskyOp() } catch (e) {}

// BAD: Lost context
try { riskyOp() } catch (e) { throw new Error("failed") }

// GOOD: Preserved context
try { riskyOp() } catch (e) { throw new Error(`riskyOp failed: ${e.message}`, { cause: e }) }
```

## State Management

- Minimize mutable state — prefer derived values
- Make ownership explicit: who creates, who mutates, who reads?
- Document state transitions (valid transitions, invalid ones)
- Use transaction semantics for multi-step mutations (all-or-nothing)
- Never leave state partially updated on error

## Input Validation

- Validate at system boundaries (user input, API responses, external data)
- Trust internal code — don't over-validate between your own modules
- Prefer type narrowing over runtime assertion where possible
- Fail fast with clear error messages at boundaries

## Naming

- **Intent-revealing**: Name describes what, not how
- **Boolean prefixes**: `is`, `has`, `can`, `should`, `did`
- **Plural collections**: `users` not `userList`, `items` not `itemArray`
- **Action verbs for functions**: `fetchUser`, `validateInput`, `calculateTotal`
- **No abbreviations** unless universally understood (id, url, api)

## Code Shape

- **Single responsibility**: One function does one thing
- **Max 3 nesting levels**: Extract helpers if deeper
- **Guard clauses**: Return early for invalid states
- **Max function length**: ~30 lines (guideline, not dogma)
- **Parameter count**: 3 or fewer; use options object beyond that

## Post-Implementation Verification

After writing code, verify:

1. Can you explain every line and why it's needed?
2. What happens with empty input? null? undefined?
3. What happens under concurrent access?
4. What happens when the network is down?
5. What happens at boundary values (0, MAX_INT, empty string)?
6. Are all error paths tested or at minimum considered?
7. Does this match the assumptions stated pre-implementation?

Under what conditions does this work? State them explicitly.
