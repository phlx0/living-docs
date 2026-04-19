#!/usr/bin/env bash
# Runs after every Edit/Write tool use.
# If a code file was changed, marks project as having potentially stale docs.
# Does NOT run the full analysis (too slow per-edit). Just sets a flag.

set -euo pipefail

DIRTY_FLAG=".claude/.living-docs-dirty"
DEBOUNCE_SECONDS="${LIVING_DOCS_DEBOUNCE:-30}"

# Only care about Edit and Write tools
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "MultiEdit" ]]; then
  exit 0
fi

# Extract file_path from tool input JSON — try jq, python3, then pure bash
_extract_file_path() {
  local input="$1"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r '.file_path // empty' 2>/dev/null
    return
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c \
      "import json,sys; print(json.load(sys.stdin).get('file_path',''))" 2>/dev/null
    return
  fi
  # Pure bash fallback: extract "file_path":"<value>"
  printf '%s' "$input" \
    | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | grep -o '"[^"]*"$' \
    | tr -d '"' \
    || true
}

FILE_PATH=$(_extract_file_path "${CLAUDE_TOOL_INPUT:-{}}")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only trigger on code files, not doc files or configs
CODE_EXTENSIONS="js|jsx|ts|tsx|py|go|rs|java|rb|php|cs|cpp|c|h|swift|kt|scala|r|lua"
if ! printf '%s' "$FILE_PATH" | grep -qE "\.(${CODE_EXTENSIONS})$"; then
  exit 0
fi

# Skip test files
if printf '%s' "$FILE_PATH" | grep -qE "(\.test\.|\.spec\.|_test\.|__tests__|__mocks__)"; then
  exit 0
fi

# Debounce — skip if flagged within the last N seconds
if [[ -f "$DIRTY_FLAG" ]]; then
  LAST_MODIFIED=$(date -r "$DIRTY_FLAG" +%s 2>/dev/null \
    || stat -c "%Y" "$DIRTY_FLAG" 2>/dev/null \
    || echo 0)
  NOW=$(date +%s)
  ELAPSED=$(( NOW - LAST_MODIFIED ))
  if (( ELAPSED < DEBOUNCE_SECONDS )); then
    exit 0
  fi
fi

# Set the dirty flag
mkdir -p "$(dirname "$DIRTY_FLAG")"
printf '%s\n' "$FILE_PATH" > "$DIRTY_FLAG"

printf '\n⚠ living-docs: code changed in %s — docs may be stale. Run /living-docs to check.\n' \
  "$(basename "$FILE_PATH")"
