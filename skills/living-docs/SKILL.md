---
name: living-docs
description: >
  Detect and fix stale documentation after code changes. Scans all doc files for references
  to changed code and updates them to match current reality. Auto-triggers a warning after
  code edits; run /living-docs to apply fixes.
  Use when user says "docs are stale", "docs are wrong", "docs are out of date",
  "update the docs", "fix stale docs", "documentation needs updating", or invokes /living-docs.
---

# Living Docs

You are a documentation maintenance agent. Your mission: keep every doc file in sync with the actual code.

## Arguments

Parse these from the user's invocation:

| Arg | Meaning |
|-----|---------|
| (none) | Scan docs for everything changed since last commit |
| `--dry-run` | Show proposed changes without applying them |
| `--all` | Scan all docs regardless of recent git changes |
| `--since <ref>` | Use a specific git ref as base (e.g. `--since main`, `--since HEAD~5`) |
| `<filepath>` | Check only one specific doc file |
| `--format <type>` | Focus on a doc format: `markdown`, `jsdoc`, `openapi`, `docstring` |

## Step 1 — Load config

Check for `.living-docs.json` in project root. If found, use its `docs`, `code`, and `behavior` settings. Otherwise use defaults:
- Doc patterns: `**/*.md`, `**/*.rst`, `docs/**/*`, `README*`
- Code patterns: `src/**`, `lib/**`, common source extensions
- Ignore: `CHANGELOG.md`, `node_modules/`, `dist/`, `build/`

## Step 2 — Find what changed

Run git diff to find changed code files:

```bash
git diff --name-only HEAD~1
```

If `--since <ref>` was given, use that ref instead of `HEAD~1`.
If `--all` was given, skip this step and treat all code files as "changed".
If no git repo exists, treat all code files as changed.

Filter results to code files only (exclude doc files, config files, lock files).

If nothing changed, report: "No code changes detected since last commit. Use --all to scan everything."

## Step 3 — Read changed diffs

For each changed code file, get the full diff:

```bash
git diff HEAD~1 -- <filepath>
```

Extract these semantic markers from the diff:
- **Functions/methods**: names that were added, removed, or renamed
- **Parameters**: function signatures that changed
- **Return types**: type changes (especially in typed languages)
- **Constants/enums**: values that changed or were removed
- **Environment variables**: any `process.env.*`, `os.environ`, `getenv()` etc.
- **CLI flags/arguments**: argparse, commander, cobra, etc. argument definitions
- **API endpoints**: route definitions (`app.get(`, `@app.route(`, `router.`)
- **Config keys**: object/dict keys in config structures
- **Export names**: what the module publicly exposes
- **Error messages**: strings thrown as errors (other code may catch by message)
- **File paths**: hardcoded paths that moved

## Step 4 — Find documentation files

Glob for doc files matching the configured include patterns, excluding the exclude patterns.

Also check for inline documentation:
- JSDoc/TSDoc: any `/** ... */` blocks in JS/TS files
- Python docstrings: `"""..."""` in `.py` files
- Go doc comments: `// FuncName ...` above exported identifiers
- OpenAPI/Swagger: `openapi.yaml`, `swagger.json`, `api.yaml`, etc.
- ADR files: `docs/adr/`, `docs/decisions/`

## Step 5 — Detect staleness

Use the `staleness-detector` subagent for each candidate doc file.

For each doc file:
1. Check if the doc references any of the semantic markers extracted in Step 3
2. If no references found, skip (not relevant to these changes)
3. If references found, compare what the doc says vs what the code now does
4. Classify each issue:
   - **OUTDATED**: Doc describes old behavior/signature/name
   - **MISSING**: Code has new thing not mentioned in doc
   - **BROKEN_LINK**: Doc links to file/section that no longer exists
   - **WRONG_EXAMPLE**: Code example in doc no longer works

Staleness to ignore:
- CHANGELOG.md (intentionally historical)
- Auto-generated files (detected by `# DO NOT EDIT` or `@generated` headers)
- Files listed in `.living-docs-ignore`

## Step 6 — Present findings

If no staleness found:
```
✓ All docs up to date with recent changes.
```

If staleness found, show a summary table:

```
Found X stale doc(s):

FILE                      ISSUES
docs/api.md               2 outdated, 1 missing
README.md                 1 outdated
src/auth.ts (JSDoc)       1 wrong signature
```

Then for each issue, show:
```
── docs/api.md:L45 ─────────────────────────────────
TYPE: OUTDATED
WHAT CHANGED: `createUser(name, email)` → `createUser(name, email, options?)`
DOC SAYS:
  createUser(name, email) - Creates a new user
SHOULD SAY:
  createUser(name, email, options?) - Creates a new user
  - options.role: string (default: "user")
  - options.verified: boolean (default: false)
```

## Step 7 — Apply fixes

If `--dry-run`: stop here. Print "Dry run complete. No files modified."

Otherwise ask: "Apply all fixes? [Y/n/select]"
- Y: apply all
- n: skip all, exit
- select: show each fix individually and ask y/n

For each fix to apply:
1. Read the current file
2. Make the minimal targeted edit (do not rewrite unrelated sections)
3. Preserve the doc's existing style, tone, and formatting
4. Write the updated file

After all fixes:
```
✓ Updated 3 doc(s):
  - docs/api.md (2 fixes)
  - README.md (1 fix)
  - src/auth.ts JSDoc (1 fix)
```

## Rules

- Never rewrite docs wholesale — make surgical edits
- Preserve the author's writing style and voice
- If unsure whether something is stale, flag it but do not auto-fix
- Never modify CHANGELOG.md
- Never modify auto-generated files
- If a fix would delete documented behavior (not just update it), warn explicitly
- If `autoFix: true` in config, skip confirmation and apply all
