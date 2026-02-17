# Web3 Godmode Config

Claude Code configuration for web3 polyglot engineers. Solidity + Rust + TypeScript/React, multi-chain.

Designed to work standalone or alongside the [compound-engineering](https://github.com/anthropics/claude-code-plugins) plugin for maximum capability.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Python 3 (for hooks)
- jq (for todo-enforcer hook): `brew install jq`
- Optional: [compound-engineering plugin](https://github.com/anthropics/claude-code-plugins) for 27 additional review/analysis agents

## Installation

### Quick Install

```bash
git clone https://github.com/0xinit/web3-godmode-config.git
cd web3-godmode-config
./install.sh
```

The installer will:
1. Check prerequisites
2. Detect compound-engineering plugin
3. Backup existing `~/.claude/` config
4. Copy all files to `~/.claude/`
5. Register hooks in `settings.json`
6. Verify installation

### Manual Install

```bash
# Copy everything to ~/.claude/
cp CLAUDE.md ~/.claude/
cp -r agents/ ~/.claude/agents/
cp -r skills/ ~/.claude/skills/
cp -r rules/ ~/.claude/rules/
cp -r commands/ ~/.claude/commands/
cp -r hooks/ ~/.claude/hooks/

# Make hooks executable
chmod +x ~/.claude/hooks/*.py ~/.claude/hooks/*.sh
```

Then manually add hooks to `~/.claude/settings.json` (see install.sh for hook config).

### Selective Install

Only want specific skills? Copy individual directories:

```bash
# Just the Solidity skills
cp -r skills/solidity-security/ ~/.claude/skills/
cp -r skills/web3-foundry/ ~/.claude/skills/
cp rules/solidity.md ~/.claude/rules/

# Just the React skills
cp -r skills/react-useeffect/ ~/.claude/skills/
cp -r skills/vercel-react-best-practices/ ~/.claude/skills/

# Just a single chain
cp -r skills/web3-megaeth/ ~/.claude/skills/
cp -r skills/arbitrum-dapp-skill/ ~/.claude/skills/
```

## Customization

### Adding a New Chain

```bash
mkdir -p ~/.claude/skills/web3-YOUR-CHAIN/
```

Create a `SKILL.md` inside:
```markdown
---
name: web3-your-chain
description: Your Chain development reference. Use when deploying to or building on Your Chain.
---

# Your Chain Reference

## Chain Configuration
| Property | Value |
|----------|-------|
| Chain ID | ... |
| RPC URL | ... |
| Explorer | ... |
| Faucet | ... |

## Deployment Patterns
...
```

Then add it to two places:
1. `CLAUDE.md` — add a row to the skill trigger table
2. `rules/forge.md` — add a row to the chain configuration table

### Modifying Rules

Rules in `rules/` are auto-loaded based on the file path you're editing. The `paths:` frontmatter controls when they activate:

```yaml
---
paths: "**/*.sol"  # Activates when editing any .sol file
---
```

**Examples:**

```yaml
# Only activate in a specific directory
paths: "contracts/**/*.sol"

# Activate for multiple extensions
paths: "**/*.{ts,tsx}"

# Activate for test files only
paths: "**/*.{test,spec}.ts, **/__tests__/**"

# Activate for config files
paths: "foundry.toml, hardhat.config.ts"
```

To create a new rule, add a `.md` file to `rules/` with the frontmatter and your rules below it.

### Adding a New Keyword Mode

Edit `hooks/keyword-detector.py` and add an entry to the `MODES` dict:

```python
"your-mode": {
    "pattern": r"\b(your-keyword|alias)\b",
    "context": """[YOUR MODE ACTIVATED]

Instructions that get injected into Claude's context when triggered...
"""
},
```

### Adjusting the Comment Checker

Edit `hooks/check-comments.py`:
- `MAX_COMMENT_RATIO` — change the threshold (default 25%)
- `VALID_PATTERNS` — add patterns that should NOT be flagged (e.g., your custom annotations)
- `CODE_EXTENSIONS` — add/remove file extensions to check

### Adding a New Command

Create a `.md` file in `commands/`:

```markdown
---
allowed-tools: Read, Glob, Grep, Bash
argument-hint: [your-args]
description: What this command does
---

Instructions for Claude when the user runs /your-command...
```

Usage: `/your-command [args]` in any Claude Code session.

### Adding a New Skill

Create a directory in `skills/` with a `SKILL.md`:

```markdown
---
name: your-skill
description: When to use this skill. Be specific — Claude uses this to decide when to auto-invoke.
---

# Your Skill

Reference content, patterns, code examples...
```

Set `disable-model-invocation: true` in the frontmatter if the skill should only run when manually invoked (not auto-triggered).

## Usage Examples

### Keyword Modes

Type these words anywhere in your prompt to activate specialized behavior:

```
ultrawork implement the staking contract
```
Activates maximum parallel execution, comprehensive planning, todo tracking.

```
analyze why the approve function reverts on Base
```
Activates deep investigation protocol with multi-phase analysis.

```
security review the vault contract
```
Routes to security scanning with Solidity-specific checks (reentrancy, CEI, access control).

```
deploy the NFT contract to Base mainnet
```
Activates deployment protocol — confirms chain, runs pre-deploy checks, verifies after.

All keyword modes:

| Keyword | What Happens |
|---------|-------------|
| `ultrawork` / `ulw` | Maximum parallel execution, comprehensive planning |
| `search` / `find` | Exhaustive multi-angle search |
| `analyze` / `debug` | Deep investigation with evidence gathering |
| `think deeply` | Extended reasoning with trade-off analysis |
| `refactor` | Incremental changes, behavior preservation, tests first |
| `review` | Routes to appropriate reviewer agent |
| `test` | BDD structure, edge cases, fuzz testing |
| `optimize` | Gas optimization (Solidity) or bundle/perf (React) |
| `security` / `audit` | Security scan (Solidity-specific or general) |
| `deploy` | Deployment protocol with chain awareness |

### Commands

```
/audit contracts/Vault.sol
```
Runs a structured security audit: static analysis, access control, reentrancy, economic vectors, gas DoS, events, NatSpec.

```
/deploy-check base MyToken
```
Pre-deployment verification: chain config, constructor args, proxy setup, post-deploy checks. Returns GO/NO-GO.

```
/interview docs/feature-spec.md
```
Interactive interview to flesh out a plan or spec. Asks deep questions about implementation, UX, tradeoffs.

### Skills Auto-Invoke

Skills trigger automatically based on what you're doing:

- Edit a `.sol` file → Solidity rules load + security skill available
- Write React hooks → useEffect patterns and Vercel best practices activate
- Ask about an EIP → EIP reference skill provides inline summaries
- Work on Anchor program → Rust patterns skill with account validation checks

### Compound-Engineering Integration

If you have the compound-engineering plugin installed, this config routes to its agents automatically:

| Need | Godmode Provides | Compound Provides |
|------|-----------------|-------------------|
| Solidity security | `/solidity-security` skill | `security-sentinel` agent |
| Code review | Rules + patterns | `kieran-*-reviewer` agents |
| Performance | Gas optimization skill | `performance-oracle` agent |
| Architecture | — | `architecture-strategist` agent |
| PR workflow | — | `/workflows:review` command |
| Frontend | Web3 frontend patterns | `frontend-design` skill |
| Git commits | — | `gitbahn` commands |

Both are triggered automatically via the CLAUDE.md delegation table — no manual routing needed.

## What's Included

### Skills (18)

| Skill | What It Does |
|-------|-------------|
| `rigorous-coding` | Pre/post implementation checks, error handling, naming |
| `planning-with-files` | Manus-style persistent planning with markdown files |
| `react-useeffect` | When NOT to use useEffect + better alternatives |
| `vercel-react-best-practices` | 45 React/Next.js performance optimization rules |
| `solidity-security` | Reentrancy, access control, flash loans, oracle manipulation, gas optimization |
| `rust-patterns` | Anchor/Solana account validation, PDA derivation, CPI security |
| `web3-frontend` | Wallet connection, tx state, BigNumber display, error translation |
| `smart-contract-audit` | Pre-deployment security checklist (manual invoke) |
| `web3-foundry` | forge/cast/anvil commands, testing, deployment |
| `web3-hardhat` | Config, testing, deployment, plugins |
| `web3-privy` | Auth SDK, embedded wallets, wagmi integration |
| `web3-eip-reference` | Top 50 EIPs inline + lookup instructions |
| `web3-solana-simd` | Key Solana improvement proposals + concepts |
| `web3-monad` | MonadBFT, parallel execution, deployment |
| `web3-megaeth` | Full MegaETH dev reference (14 files) |
| `arbitrum-dapp-skill` | Arbitrum dApp development with Stylus (Rust) and Solidity (7 files) |
| `web3-polymarket` | Polymarket CLOB integration: auth, orders, market data, WebSocket, CTF ops, bridge |
| `web3-solidity-patterns` | Factory, Proxy, Diamond, Governor patterns |

### Agents (3)

| Agent | Purpose |
|-------|---------|
| `codebase-search` | Web3-aware codebase search (ABIs, selectors, storage, Anchor) |
| `open-source-librarian` | Find implementation details in OSS repos with GitHub permalinks |
| `tech-docs-writer` | Create accurate technical documentation |

### Rules (6)

| Rule | Triggers On | Key Points |
|------|------------|------------|
| `typescript.md` | `**/*.{ts,tsx}` | bigint for tokens, Address type, receipt checks |
| `solidity.md` | `**/*.sol` | NatSpec, CEI, custom errors, events |
| `rust.md` | `**/*.rs` | No unwrap, thiserror/anyhow, iterators |
| `forge.md` | `**/*.sol, foundry.toml` | Multi-chain config (8 chains), deployment rules |
| `testing.md` | `**/*.{test,spec}.ts` | BDD comments, one assertion per test |
| `comments.md` | All code files | When comments are forbidden vs required |

### Commands (3)

| Command | Usage |
|---------|-------|
| `/audit [contract]` | Structured smart contract security audit |
| `/deploy-check [chain] [contract]` | Pre-deployment verification checklist |
| `/interview [plan-file]` | Interactive spec/plan interview |

### Hooks (3)

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `keyword-detector.py` | Every prompt | Detects 10 keyword modes, injects context |
| `check-comments.py` | After Write/Edit | Warns if comment ratio exceeds 25% |
| `todo-enforcer.sh` | On session stop | Blocks exit with incomplete todos |

## Credits

- Arbitrum dApp skill: [hummusonrails/arbitrum-dapp-skill](https://github.com/hummusonrails/arbitrum-dapp-skill)
- MegaETH skills: [0xBreadguy/megaeth-ai-developer-skills](https://github.com/0xBreadguy/megaeth-ai-developer-skills)
- Vercel React best practices: [vercel/react-best-practices](https://github.com/vercel/react-best-practices)
- Planning with files: Based on [Manus context engineering](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- React useEffect patterns: [React official docs](https://react.dev/learn/you-might-not-need-an-effect)

## License

MIT
