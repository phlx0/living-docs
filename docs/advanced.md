# Advanced Usage

## Monorepo setup

Point `code.include` and `docs.include` at the subdirectory you care about:

```json
{
  "code": {
    "include": ["packages/api/src/**", "packages/auth/src/**"]
  },
  "docs": {
    "include": ["packages/api/docs/**", "packages/auth/docs/**", "docs/shared/**"]
  }
}
```

Run from the repo root. living-docs respects the paths and won't scan packages you didn't include.

---

## Auto-fix on every session end

Set `autoFix: true` in config to skip confirmation prompts:

```json
{
  "behavior": {
    "autoFix": true,
    "requireConfirmation": false
  }
}
```

Combine with `--dry-run` in CI so auto-fix only runs locally, never in the pipeline.

---

## Scoping to a doc format

If you only want to check OpenAPI specs after changing route handlers:

```
/living-docs --format openapi
```

Supported values: `markdown`, `jsdoc`, `openapi`, `docstring`, `rst`.

---

## Custom base ref

Compare against a release branch before cutting a release:

```
/living-docs --since release/2.0
```

Or check everything that diverged from main:

```
/living-docs --since origin/main
```

---

## CI: fail on stale docs

```yaml
# .github/workflows/docs-check.yml
name: Docs

on:
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Install living-docs
        run: curl -fsSL https://raw.githubusercontent.com/phlx0/living-docs/main/scripts/install.sh | sh

      - name: Check for stale docs
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude --print "/living-docs --dry-run --since origin/main" \
            | tee /tmp/living-docs-out.txt
          grep -q "All docs up to date" /tmp/living-docs-out.txt || {
            echo "Stale documentation detected. Run /living-docs locally to fix."
            exit 1
          }
```

---

## Pre-push hook

Block pushes if docs are stale:

```bash
#!/usr/bin/env bash
# .git/hooks/pre-push

OUTPUT=$(claude --print "/living-docs --dry-run" 2>&1)
if ! echo "$OUTPUT" | grep -q "All docs up to date"; then
  echo "$OUTPUT"
  echo ""
  echo "Stale docs detected. Run /living-docs to fix before pushing."
  exit 1
fi
```

```bash
chmod +x .git/hooks/pre-push
```

---

## Excluding generated docs

If you generate docs from code (e.g. TypeDoc, Sphinx, godoc), those generated files should not be managed by living-docs — update your generator config instead.

Exclude them:

```
# .living-docs-ignore
docs/generated/
site/
_site/
```

Or add `@generated` anywhere in the file header — living-docs skips files with that marker automatically.

---

## Adjusting confidence threshold

By default, only `medium` and `high` confidence issues trigger auto-fix candidates. Low-confidence issues are always shown but marked `[review]`.

This threshold is not currently configurable — if you find cases where confidence is miscalibrated, open an issue with the example.
