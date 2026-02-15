# Web3 Godmode Config

Claude Code configuration for web3 polyglot engineers. Solidity + Rust + TypeScript/React, multi-chain.

Designed to work standalone or alongside the [compound-engineering](https://github.com/anthropics/claude-code-plugins) plugin for maximum capability.

## What's Included

| Category | Count | Highlights |
|----------|-------|------------|
| Agents | 3 | Codebase search (web3-aware), OSS librarian, tech docs writer |
| Skills | 20 | Solidity security, Rust/Anchor, web3 frontend, 8 chain-specific skills |
| Rules | 6 | TypeScript, Solidity, Rust, Forge, testing, comments |
| Commands | 3 | `/audit`, `/deploy-check`, `/interview` |
| Hooks | 3 | Keyword detector (10 modes), comment checker, todo enforcer |

### Web3 Skills

| Skill | What It Does |
|-------|-------------|
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
| `web3-megaeth` | Full MegaETH dev reference (14 files, from [0xBreadguy](https://github.com/0xBreadguy/megaeth-ai-developer-skills)) |
| `web3-solidity-patterns` | Factory, Proxy, Diamond, Governor patterns |

### Keyword Modes

Type these words in your prompt to activate specialized behavior:

| Keyword | Mode |
|---------|------|
| `ultrawork` / `ulw` | Maximum parallel execution, comprehensive planning |
| `search` / `find` | Exhaustive multi-angle search |
| `analyze` / `debug` | Deep investigation protocol |
| `think deeply` | Extended reasoning with trade-off analysis |
| `refactor` | Incremental changes, behavior preservation |
| `review` | Routes to appropriate reviewer agent |
| `test` | BDD structure, edge cases, fuzz testing |
| `optimize` | Performance analysis (gas for Solidity, bundle for React) |
| `security` / `audit` | Security scan (Solidity-specific or general) |
| `deploy` | Deployment protocol with chain awareness |

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Python 3 (for hooks)
- jq (for todo-enforcer hook)
- Optional: [compound-engineering plugin](https://github.com/anthropics/claude-code-plugins) for 27 additional review/analysis agents

## Installation

### Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/web3-godmode-config.git
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
```

## Compound-Engineering Integration

This config is designed to complement compound-engineering, not replace it.

| Need | Godmode | Compound |
|------|---------|----------|
| Solidity security | `/solidity-security` skill | `security-sentinel` agent |
| Code review | Rules + patterns | `kieran-*-reviewer` agents |
| Performance | Gas optimization skill | `performance-oracle` agent |
| Architecture | — | `architecture-strategist` agent |
| PR workflow | — | `/workflows:review` command |
| Frontend | Web3 frontend patterns | `frontend-design` skill |
| Git commits | — | `gitbahn` commands |

Both are triggered automatically via the CLAUDE.md delegation table.

## Customization

### Adding a New Chain

```bash
mkdir -p ~/.claude/skills/web3-YOUR-CHAIN/
```

Create `SKILL.md`:
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

Add to CLAUDE.md skill trigger table and forge.md chain table.

### Modifying Rules

Rules in `rules/` are auto-loaded by file path matching. Edit the `paths:` frontmatter to change when they apply:

```yaml
---
paths: "**/*.sol"  # Matches all .sol files
---
```

### Adjusting Keyword Modes

Edit `hooks/keyword-detector.py` to add/modify keyword triggers and their injected context.

## Credits

- MegaETH skills: [0xBreadguy/megaeth-ai-developer-skills](https://github.com/0xBreadguy/megaeth-ai-developer-skills)
- Vercel React best practices: [vercel/react-best-practices](https://github.com/vercel/react-best-practices)
- Planning with files: Based on [Manus context engineering](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- React useEffect patterns: [React official docs](https://react.dev/learn/you-might-not-need-an-effect)

## License

MIT
