#!/usr/bin/env bash
# living-docs uninstaller

set -euo pipefail

PLUGIN_DIR="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"
INSTALL_DIR="$PLUGIN_DIR/living-docs"
SETTINGS="$HOME/.claude/settings.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${YELLOW}[living-docs]${NC} $*"; }
success() { echo -e "${GREEN}[living-docs]${NC} $*"; }
error()   { echo -e "${RED}[living-docs]${NC} $*" >&2; exit 1; }

if [[ ! -d "$INSTALL_DIR" ]]; then
  info "living-docs is not installed at $INSTALL_DIR"
  exit 0
fi

info "Removing $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"

# Remove from settings.json if present
if [[ -f "$SETTINGS" ]] && command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS" "$INSTALL_DIR" <<'EOF'
import json, sys

path, plugin_dir = sys.argv[1], sys.argv[2]
with open(path) as f:
    settings = json.load(f)

plugins = settings.get("plugins", [])
cleaned = [p for p in plugins if plugin_dir not in p and "living-docs" not in p]

if len(cleaned) != len(plugins):
    settings["plugins"] = cleaned
    with open(path, "w") as f:
        json.dump(settings, f, indent=2)
    print(f"Removed living-docs from {path}")
EOF
fi

success "living-docs uninstalled."
