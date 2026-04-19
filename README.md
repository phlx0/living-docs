<div align="center">

# living-docs

### Documentation that keeps up with your code.

[![CI](https://github.com/phlx0/living-docs/actions/workflows/ci.yml/badge.svg)](https://github.com/phlx0/living-docs/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-blueviolet)](https://code.claude.ai)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/phlx0/living-docs/pulls)

</div>

---

You renamed a function. You added a required parameter. You retired an env var.

Somewhere in your docs, the old name is still there. The old signature. The old example that no longer runs. It will stay there until a confused colleague files a bug, or a new hire wastes a morning following instructions that stopped being true six months ago.

**living-docs** finds every doc that references what you just changed, tells you exactly what's wrong, and fixes only that — without touching anything else.

---

## What it looks like

You've been editing `src/auth.ts`. Claude Code's hook fires quietly:

```
⚠ living-docs: code changed in auth.ts — docs may be stale. Run /living-docs to check.
```

You run `/living-docs`:

```
Scanning docs against changes since HEAD~1...

  STALE  docs/api.md            2 issues
  STALE  docs/configuration.md  1 issue
  STALE  src/auth.ts (JSDoc)    1 issue
  OK     README.md
  OK     docs/architecture.md

─────────────────────────────────────────────────────────────────
docs/api.md · line 112
─────────────────────────────────────────────────────────────────
TYPE     outdated signature
CHANGED  authenticate(token) → authenticate(token, options?)

WAS:
  authenticate(token)
  Validates a JWT and returns the decoded payload.

NOW:
  authenticate(token, options?)
  Validates a JWT and returns the decoded payload.
  options.strict — boolean  Reject tokens missing `exp`. Default: false.
  options.audience — string  Validate `aud` claim. Default: not checked.

─────────────────────────────────────────────────────────────────
docs/configuration.md · line 58
─────────────────────────────────────────────────────────────────
TYPE     renamed env var
CHANGED  AUTH_SECRET → AUTH_SIGNING_KEY

WAS:
  AUTH_SECRET — Secret used to sign tokens.

NOW:
  AUTH_SIGNING_KEY — Secret used to sign tokens.

─────────────────────────────────────────────────────────────────
src/auth.ts · JSDoc
─────────────────────────────────────────────────────────────────
TYPE     missing param
CHANGED  new options parameter not documented in JSDoc

WAS:
  * @param {string} token - JWT to validate

NOW:
  * @param {string} token - JWT to validate
  * @param {Object} [options] - Validation options
  * @param {boolean} [options.strict=false] - Reject tokens missing `exp`
  * @param {string} [options.audience] - Validate `aud` claim

─────────────────────────────────────────────────────────────────

Apply all 4 fixes? [Y/n/select]
```

Type `Y`. Done. Every doc is accurate again.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/phlx0/living-docs/main/scripts/install.sh | sh
```

Or manually:

```bash
git clone https://github.com/phlx0/living-docs ~/.claude/plugins/living-docs
chmod +x ~/.claude/plugins/living-docs/hooks/*.sh
```

Add to `~/.claude/settings.json`:

```json
{
  "plugins": ["~/.claude/plugins/living-docs"]
}
```

---

## Usage

```
/living-docs                   scan everything changed since last commit
/living-docs --dry-run         preview fixes, change nothing
/living-docs --all             scan all docs, not just recent changes
/living-docs --since main      diff against a branch instead of HEAD~1
/living-docs docs/api.md       check one file only
/living-docs --format openapi  focus on a specific doc format
```

---

## What it catches

| Code change | What gets flagged |
|---|---|
| Function signature changed | Every doc, example, and JSDoc showing the old signature |
| Parameter added or removed | README usage sections, API references, docstrings |
| Env var renamed | Every mention of the old name across all doc files |
| CLI flag renamed | Help text, quickstart guides, deployment docs |
| API endpoint moved | OpenAPI specs, integration guides, curl examples |
| Config key renamed | Configuration references, environment setup guides |
| New public export | Missing documentation for newly exposed API surface |
| File path changed | Cross-references, import examples |

**Supported doc formats:** Markdown, JSDoc/TSDoc, Python docstrings, Go doc comments, OpenAPI/Swagger, reStructuredText.

---

## How it works

```
┌─────────────────────────────────────────────────────────────┐
│  git diff HEAD~1                                            │
│    → changed code files                                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  extract semantic markers                                   │
│    → function names, param changes, env vars, endpoints,   │
│      config keys, exports, file paths                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  glob doc files                                             │
│    → markdown, rst, jsdoc, docstrings, openapi             │
│    → skip: CHANGELOG, auto-generated, .living-docs-ignore  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                   ┌───────┴───────┐
                   │               │
                   ▼               ▼
            references?        no references
            → analyze          → skip (fast)
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  staleness-detector subagent (per file)                     │
│    → compare doc content vs current code                    │
│    → classify: outdated / missing / broken-link / wrong-eg  │
│    → confidence: high / medium / low                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  surgical fix                                               │
│    → edit only the stale lines                             │
│    → preserve author's style, tone, structure              │
│    → low-confidence: flag only, never auto-fix             │
└─────────────────────────────────────────────────────────────┘
```

---

## Configuration

Drop a `.living-docs.json` in your project root to override defaults:

```bash
cp ~/.claude/plugins/living-docs/.living-docs.example.json .living-docs.json
```

```json
{
  "docs": {
    "include": ["**/*.md", "docs/**/*", "README*"],
    "exclude": ["CHANGELOG.md", "node_modules/**", "dist/**"]
  },
  "code": {
    "include": ["src/**", "lib/**"],
    "exclude": ["**/*.test.*", "**/*.spec.*"]
  },
  "hooks": {
    "enabled": true,
    "debounceSeconds": 30
  },
  "behavior": {
    "autoFix": false,
    "requireConfirmation": true
  }
}
```

To permanently exclude files, create `.living-docs-ignore`:

```
CHANGELOG.md
docs/archive/
src/generated/
vendor/
```

---

## CI integration

Fail the build if docs would be stale after a merge:

```yaml
# .github/workflows/docs-check.yml
- name: Check for stale docs
  run: |
    claude --print "/living-docs --dry-run --since origin/main" \
      | grep -q "All docs up to date" || exit 1
```

Or as a pre-push hook:

```bash
# .git/hooks/pre-push
claude --print "/living-docs --dry-run" | grep -q "All docs up to date" || {
  echo "Stale docs detected. Run /living-docs to fix."
  exit 1
}
```

---

## FAQ

**Will it rewrite my whole README?**
No. It edits exactly the lines that are wrong. The rest is untouched — including your formatting, whitespace, and wording.

**My docs are intentionally different from the code. Will it break them?**
Use `--dry-run` to review before applying. Add the file to `.living-docs-ignore` to exclude it permanently.

**No git history?**
Use `--all` to scan all docs without diffing.

**Monorepo?**
Yes. Point `code.include` and `docs.include` at the subdirectories you want.

**Works without Claude Code?**
No. living-docs is a Claude Code plugin. The analysis is done by an LLM — that's what makes it semantic instead of just a text search.

**Will it touch auto-generated files?**
No. Files with `# DO NOT EDIT`, `@generated`, or `Code generated` headers are skipped automatically.

---

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md).

Issues and PRs at [github.com/phlx0/living-docs](https://github.com/phlx0/living-docs/issues). Bug reports are most useful with a code snippet and doc snippet showing what wasn't caught (or was wrongly flagged).

---

<div align="center">

MIT — [LICENSE](LICENSE)

</div>
