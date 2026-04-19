#!/usr/bin/env bash
# living-docs installer
# Usage: curl -fsSL https://raw.githubusercontent.com/phlx0/living-docs/main/scripts/install.sh | sh

set -euo pipefail

REPO="https://github.com/phlx0/living-docs"
RAW="https://raw.githubusercontent.com/phlx0/living-docs/main"
PLUGIN_DIR="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"
INSTALL_DIR="$PLUGIN_DIR/living-docs"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[living-docs]${NC} $*"; }
success() { echo -e "${GREEN}[living-docs]${NC} $*"; }
warn()    { echo -e "${YELLOW}[living-docs]${NC} $*"; }
error()   { echo -e "${RED}[living-docs]${NC} $*" >&2; exit 1; }

# Check dependencies
command -v git >/dev/null 2>&1 || error "git is required"
command -v python3 >/dev/null 2>&1 || error "python3 is required (for hook JSON parsing)"

info "Installing living-docs Claude Code plugin..."
info "Install directory: $INSTALL_DIR"

# Remove existing install
if [[ -d "$INSTALL_DIR" ]]; then
  warn "Existing install found. Updating..."
  rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"

# Clone or download
if command -v git >/dev/null 2>&1; then
  git clone --depth=1 --quiet "$REPO" "$INSTALL_DIR" 2>/dev/null || {
    warn "git clone failed, falling back to download..."
    CLONE_FAILED=1
  }
fi

if [[ "${CLONE_FAILED:-0}" == "1" ]]; then
  # Fallback: download individual files
  mkdir -p "$INSTALL_DIR"/{skills,subagents,hooks,scripts}
  for FILE in manifest.json skills/living-docs.md subagents/staleness-detector.md hooks/post-edit.sh; do
    curl -fsSL "$RAW/$FILE" -o "$INSTALL_DIR/$FILE" || error "Failed to download $FILE"
  done
fi

# Make hooks executable
chmod +x "$INSTALL_DIR"/hooks/*.sh

# Register plugin with Claude Code
if command -v claude >/dev/null 2>&1; then
  if claude plugin install "$INSTALL_DIR" 2>/dev/null; then
    success "Plugin registered via Claude Code CLI."
  else
    warn "Manual registration needed. Add to your Claude Code settings:"
    warn "  \"plugins\": [\"$INSTALL_DIR\"]"
  fi
fi

success "living-docs installed!"
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
