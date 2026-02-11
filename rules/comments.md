## Comment Policy

### Comments are FORBIDDEN For
- Comments that repeat what code does
- Commented-out code (delete it)
- Obvious comments ("increment counter", "set variable")
- Comments instead of good naming
- Summarizing a function that has a clear name
- Explaining standard library/framework usage

### Comments ARE Required For
- **Business logic**: Why this specific threshold, formula, or branching
- **Security rationale**: Why this check exists, what attack it prevents
- **Workarounds**: What bug/limitation this works around, with link/ticket
- **Regex patterns**: What the pattern matches (always)
- **Protocol references**: Which EIP, SIMD, or spec section this implements
- **Non-obvious performance**: Why this approach over the obvious one
- **Invariants**: Assumptions that must hold for correctness
- **Magic numbers**: What the number represents and where it comes from

### The Test
Would a competent engineer joining tomorrow understand WHY this code exists and WHY it's written this way — without the comment?

- If yes -> no comment needed
- If no -> comment is required

### Principle
Code should be self-documenting for WHAT. Comments explain WHY.
