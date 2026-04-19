#!/usr/bin/env bash
# living-docs updater — pulls latest changes in-place

set -euo pipefail

PLUGIN_DIR="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"
INSTALL_DIR="$PLUGIN_DIR/living-docs"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${YELLOW}[living-docs]${NC} $*"; }
success() { echo -e "${GREEN}[living-docs]${NC} $*"; }
error()   { echo -e "${RED}[living-docs]${NC} $*" >&2; exit 1; }

[[ -d "$INSTALL_DIR" ]] || error "living-docs not found at $INSTALL_DIR. Run install.sh first."
[[ -d "$INSTALL_DIR/.git" ]] || error "Install directory is not a git repo. Re-install with install.sh."

info "Updating living-docs..."

BEFORE=$(git -C "$INSTALL_DIR" rev-parse HEAD)
git -C "$INSTALL_DIR" pull --ff-only --quiet
AFTER=$(git -C "$INSTALL_DIR" rev-parse HEAD)

chmod +x "$INSTALL_DIR"/hooks/*.sh "$INSTALL_DIR"/scripts/*.sh

if [[ "$BEFORE" == "$AFTER" ]]; then
  success "Already up to date."
else
  success "Updated $(git -C "$INSTALL_DIR" log --oneline "$BEFORE..$AFTER" | wc -l | tr -d ' ') commit(s)."
  git -C "$INSTALL_DIR" log --oneline "$BEFORE..$AFTER"
fi
