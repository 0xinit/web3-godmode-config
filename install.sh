#!/usr/bin/env bash
# ============================================================================
# Web3 Godmode Config — Installer
# Installs Claude Code configuration for web3 polyglot development.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SKILLS_CONF="$SCRIPT_DIR/godmode-skills.conf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ---- Prerequisites ----

check_prereqs() {
  info "Checking prerequisites..."

  if ! command -v claude &>/dev/null; then
    err "Claude Code CLI not found. Install: npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
  ok "Claude Code CLI found"

  if ! command -v python3 &>/dev/null; then
    err "python3 not found (required for hooks)"
    exit 1
  fi
  ok "python3 found"

  if ! command -v jq &>/dev/null; then
    warn "jq not found (required for todo-enforcer hook). Install: brew install jq"
  else
    ok "jq found"
  fi
}

# ---- Plugin Detection ----

detect_plugins() {
  info "Detecting plugins..."

  # Compound Engineering
  if [ -d "$CLAUDE_DIR/plugins/compound-engineering" ] || \
     grep -q "compound-engineering" "$SETTINGS_FILE" 2>/dev/null; then
    ok "compound-engineering plugin detected"
  else
    warn "compound-engineering plugin NOT detected"
    echo "    Install: https://github.com/compound-engineering/claude-code-plugin"
    echo "    This config works without it, but you'll miss 27 agents + 19 commands."
    echo ""
    read -p "    Continue without compound-engineering? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      info "Install compound-engineering first, then re-run this script."
      exit 0
    fi
  fi

  # Optional: gitbahn
  if command -v gitbahn &>/dev/null 2>&1 || \
     grep -q "gitbahn" "$SETTINGS_FILE" 2>/dev/null; then
    ok "gitbahn detected"
  else
    info "gitbahn not detected (optional — adds granular/atomic/realistic commit styles)"
  fi
}

# ---- Backup ----

backup_existing() {
  local needs_backup=false

  for dir in agents skills rules commands hooks godmode-store; do
    if [ -d "$CLAUDE_DIR/$dir" ]; then
      needs_backup=true
      break
    fi
  done

  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    needs_backup=true
  fi

  if $needs_backup; then
    info "Backing up existing config to $BACKUP_DIR/"
    mkdir -p "$BACKUP_DIR"

    for dir in agents skills rules commands hooks godmode-store; do
      if [ -d "$CLAUDE_DIR/$dir" ]; then
        cp -r "$CLAUDE_DIR/$dir" "$BACKUP_DIR/"
      fi
    done

    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
      cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/"
    fi

    ok "Backup created at $BACKUP_DIR/"
  else
    info "No existing config to backup"
  fi
}

# ---- Install ----

install_files() {
  info "Installing web3-godmode-config..."

  # Create directories
  mkdir -p "$CLAUDE_DIR"/{agents,skills,rules,commands,hooks}

  # Copy CLAUDE.md
  cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  ok "CLAUDE.md installed"

  # Copy agents
  cp "$SCRIPT_DIR"/agents/*.md "$CLAUDE_DIR/agents/"
  ok "Agents installed ($(ls "$SCRIPT_DIR"/agents/*.md | wc -l | tr -d ' ') files)"

  # Copy ALL skills to godmode-store, symlink enabled ones to skills/
  local store_dir="$CLAUDE_DIR/godmode-store"
  mkdir -p "$store_dir" "$CLAUDE_DIR/skills"

  # Clear old store and rebuild
  rm -rf "$store_dir"/*

  local total=0
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$store_dir/$skill_name"
    total=$((total + 1))
  done
  ok "Skill store: $total skills copied to godmode-store/"

  # Symlink enabled skills
  local installed=0
  local skipped=0

  # Read enabled skills from conf (non-empty, non-comment, non-section lines)
  local enabled_skills=()
  if [ -f "$SKILLS_CONF" ]; then
    while IFS= read -r line; do
      line="${line%%#*}"       # strip inline comments
      line="$(echo "$line" | xargs)" # trim whitespace
      [[ -z "$line" ]] && continue
      [[ "$line" == "["* ]] && break  # stop at profile sections
      enabled_skills+=("$line")
    done < "$SKILLS_CONF"
  fi

  # Remove existing godmode symlinks (leave non-symlink dirs alone)
  for skill in $(ls -1 "$store_dir" 2>/dev/null); do
    [ -L "$CLAUDE_DIR/skills/$skill" ] && rm "$CLAUDE_DIR/skills/$skill"
  done

  if [ ${#enabled_skills[@]} -eq 0 ]; then
    warn "No skills enabled in godmode-skills.conf — use 'godmode enable <name>' to activate"
    skipped=$total
  else
    for skill_dir in "$SCRIPT_DIR"/skills/*/; do
      skill_name=$(basename "$skill_dir")
      local is_enabled=false
      for enabled in "${enabled_skills[@]}"; do
        if [[ "$enabled" == "$skill_name" ]]; then
          is_enabled=true
          break
        fi
      done

      if $is_enabled; then
        ln -s "$store_dir/$skill_name" "$CLAUDE_DIR/skills/$skill_name"
        installed=$((installed + 1))
      else
        skipped=$((skipped + 1))
      fi
    done
  fi
  ok "Skills active: $installed enabled, $skipped available (use 'godmode' CLI to toggle)"

  # Install godmode CLI
  mkdir -p "$CLAUDE_DIR/bin"
  cp "$SCRIPT_DIR/godmode" "$CLAUDE_DIR/bin/godmode"
  chmod +x "$CLAUDE_DIR/bin/godmode"
  cp "$SKILLS_CONF" "$CLAUDE_DIR/godmode-skills.conf"
  ok "godmode CLI installed to ~/.claude/bin/godmode"

  # Copy rules
  cp "$SCRIPT_DIR"/rules/*.md "$CLAUDE_DIR/rules/"
  ok "Rules installed ($(ls "$SCRIPT_DIR"/rules/*.md | wc -l | tr -d ' ') files)"

  # Copy commands
  cp "$SCRIPT_DIR"/commands/*.md "$CLAUDE_DIR/commands/"
  ok "Commands installed ($(ls "$SCRIPT_DIR"/commands/*.md | wc -l | tr -d ' ') files)"

  # Copy hooks
  cp "$SCRIPT_DIR"/hooks/* "$CLAUDE_DIR/hooks/"
  chmod +x "$CLAUDE_DIR"/hooks/*.py "$CLAUDE_DIR"/hooks/*.sh
  ok "Hooks installed ($(ls "$SCRIPT_DIR"/hooks/* | wc -l | tr -d ' ') files)"
}

# ---- Register Hooks ----

register_hooks() {
  info "Registering hooks in settings.json..."

  # Ensure settings file exists
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  # Define hooks to register
  local hooks_json
  hooks_json=$(cat <<'HOOKSJSON'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/keyword-detector.py",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/check-comments.py",
            "timeout": 5000
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/todo-enforcer.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
HOOKSJSON
)

  if command -v jq &>/dev/null; then
    # Merge hooks into existing settings (preserves other settings)
    local tmp_file="${SETTINGS_FILE}.tmp.$$"
    jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$hooks_json") > "$tmp_file"
    mv "$tmp_file" "$SETTINGS_FILE"
    ok "Hooks registered in settings.json"
  else
    warn "jq not available — hooks not auto-registered"
    echo "    Manually add hooks to $SETTINGS_FILE"
    echo "    See README.md for hook configuration"
  fi
}

# ---- Verify ----

verify_install() {
  info "Verifying installation..."

  local errors=0

  [ -f "$CLAUDE_DIR/CLAUDE.md" ] && ok "CLAUDE.md exists" || { err "CLAUDE.md missing"; errors=$((errors + 1)); }
  [ -d "$CLAUDE_DIR/agents" ] && ok "agents/ exists" || { err "agents/ missing"; errors=$((errors + 1)); }
  [ -d "$CLAUDE_DIR/skills" ] && ok "skills/ exists" || { err "skills/ missing"; errors=$((errors + 1)); }
  [ -d "$CLAUDE_DIR/godmode-store" ] && ok "godmode-store/ exists" || { err "godmode-store/ missing"; errors=$((errors + 1)); }
  [ -d "$CLAUDE_DIR/rules" ] && ok "rules/ exists" || { err "rules/ missing"; errors=$((errors + 1)); }
  [ -d "$CLAUDE_DIR/commands" ] && ok "commands/ exists" || { err "commands/ missing"; errors=$((errors + 1)); }
  [ -d "$CLAUDE_DIR/hooks" ] && ok "hooks/ exists" || { err "hooks/ missing"; errors=$((errors + 1)); }
  [ -x "$CLAUDE_DIR/bin/godmode" ] && ok "godmode CLI installed" || { err "godmode CLI missing"; errors=$((errors + 1)); }

  # Count components
  local active_skills=$(ls -l "$CLAUDE_DIR"/skills/ 2>/dev/null | grep '^l' | wc -l | tr -d ' ')
  local store_skills=$(ls -d "$CLAUDE_DIR"/godmode-store/*/ 2>/dev/null | wc -l | tr -d ' ')
  local rule_count=$(ls "$CLAUDE_DIR"/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
  local agent_count=$(ls "$CLAUDE_DIR"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')

  echo ""
  if [ "$errors" -eq 0 ]; then
    ok "Installation complete!"
    echo ""
    echo "  Components installed:"
    echo "    Agents:   $agent_count"
    echo "    Skills:   $active_skills active / $store_skills available"
    echo "    Rules:    $rule_count"
    echo "    Commands: $(ls "$CLAUDE_DIR"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')"
    echo "    Hooks:    $(ls "$CLAUDE_DIR"/hooks/* 2>/dev/null | wc -l | tr -d ' ')"
    echo ""
    echo "  Add to your shell profile:"
    echo "    export PATH=\"\$HOME/.claude/bin:\$PATH\""
    echo ""
    echo "  Then use:"
    echo "    godmode list              # see all skills"
    echo "    godmode enable megaeth    # activate a skill"
    echo "    godmode profile solidity  # activate a profile"
    echo "    godmode status            # check budget usage"
    echo ""
    echo "  Start a new Claude Code session to use the config."
  else
    err "$errors errors found. Check the output above."
  fi
}

# ---- Main ----

main() {
  echo ""
  echo "================================================"
  echo "  Web3 Godmode Config — Installer"
  echo "================================================"
  echo ""

  check_prereqs
  detect_plugins
  backup_existing
  install_files
  register_hooks
  verify_install
}

main "$@"
