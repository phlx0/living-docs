#!/usr/bin/env bash
# living-docs installer
# Usage: curl -fsSL https://raw.githubusercontent.com/phlx0/living-docs/main/scripts/install.sh | sh

set -euo pipefail

REPO="https://github.com/phlx0/living-docs"
RAW="https://raw.githubusercontent.com/phlx0/living-docs/main"
PLUGIN_DIR="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"
INSTALL_DIR="$PLUGIN_DIR/living-docs"
REGISTRY="$PLUGIN_DIR/installed_plugins.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[living-docs]${NC} $*"; }
success() { echo -e "${GREEN}[living-docs]${NC} $*"; }
warn()    { echo -e "${YELLOW}[living-docs]${NC} $*"; }
error()   { echo -e "${RED}[living-docs]${NC} $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || error "git is required"

info "Installing living-docs Claude Code plugin..."
info "Install directory: $INSTALL_DIR"

# Remove existing install
if [[ -d "$INSTALL_DIR" ]]; then
  warn "Existing install found. Updating..."
  rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"

# Clone or download
CLONE_FAILED=0
git clone --depth=1 --quiet "$REPO" "$INSTALL_DIR" 2>/dev/null || CLONE_FAILED=1

if [[ "$CLONE_FAILED" == "1" ]]; then
  warn "git clone failed, falling back to download..."
  mkdir -p "$INSTALL_DIR"/.claude-plugin \
           "$INSTALL_DIR"/skills/living-docs \
           "$INSTALL_DIR"/subagents \
           "$INSTALL_DIR"/hooks \
           "$INSTALL_DIR"/scripts
  for FILE in \
    .claude-plugin/plugin.json \
    skills/living-docs/SKILL.md \
    subagents/staleness-detector.md \
    hooks/post-edit.sh; do
    curl -fsSL "$RAW/$FILE" -o "$INSTALL_DIR/$FILE" || error "Failed to download $FILE"
  done
fi

# Ensure required plugin structure exists (in case repo predates it)
if [[ ! -f "$INSTALL_DIR/.claude-plugin/plugin.json" ]]; then
  mkdir -p "$INSTALL_DIR/.claude-plugin"
  cat > "$INSTALL_DIR/.claude-plugin/plugin.json" <<'EOF'
{
  "name": "living-docs",
  "version": "1.0.0",
  "description": "Keep documentation alive — auto-detects and fixes stale docs after code changes.",
  "author": {
    "name": "phlx0",
    "url": "https://github.com/phlx0/living-docs"
  }
}
EOF
fi

if [[ ! -f "$INSTALL_DIR/skills/living-docs/SKILL.md" && -f "$INSTALL_DIR/skills/living-docs.md" ]]; then
  mkdir -p "$INSTALL_DIR/skills/living-docs"
  cp "$INSTALL_DIR/skills/living-docs.md" "$INSTALL_DIR/skills/living-docs/SKILL.md"
fi

# Make hooks executable
chmod +x "$INSTALL_DIR"/hooks/*.sh 2>/dev/null || true

# Register plugin in installed_plugins.json
_register_plugin() {
  local registry="$1"
  local install_dir="$2"
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  local entry
  entry=$(printf '{"scope":"user","installPath":"%s","version":"1.0.0","installedAt":"%s","lastUpdated":"%s"}' \
    "$install_dir" "$now" "$now")

  if [[ ! -f "$registry" ]]; then
    printf '{"version":2,"plugins":{"living-docs@local":[%s]}}\n' "$entry" > "$registry"
    return 0
  fi

  # Use python3 to update JSON safely
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$registry" "$entry" <<'PYEOF'
import json, sys
registry_path, new_entry_str = sys.argv[1], sys.argv[2]
new_entry = json.loads(new_entry_str)
with open(registry_path) as f:
    data = json.load(f)
data.setdefault("plugins", {})["living-docs@local"] = [new_entry]
with open(registry_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF
    return 0
  fi

  warn "python3 not found — cannot auto-register plugin."
  warn "Manually add to $registry:"
  warn "  \"living-docs@local\": [{\"scope\":\"user\",\"installPath\":\"$install_dir\",\"version\":\"1.0.0\"}]"
  return 1
}

mkdir -p "$PLUGIN_DIR"
if _register_plugin "$REGISTRY" "$INSTALL_DIR"; then
  success "Plugin registered in $REGISTRY"
else
  warn "Registration skipped. Restart Claude Code after manually updating $REGISTRY."
fi

success "living-docs installed! Restart Claude Code to activate."
echo ""
echo "  Usage:"
echo "    /living-docs           scan docs for staleness"
echo "    /living-docs --dry-run preview changes only"
echo "    /living-docs --all     scan everything"
echo ""
echo "  Config (optional):"
echo "    cp $INSTALL_DIR/.living-docs.example.json .living-docs.json"
echo ""
echo "  Docs: $REPO"
