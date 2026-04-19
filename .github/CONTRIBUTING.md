# Contributing to living-docs

Bug reports, fixes, and improvements welcome.

## Quick start

```bash
git clone https://github.com/phlx0/living-docs
cd living-docs
```

No build step. The plugin is plain Markdown and Bash.

## Project structure

```
skills/living-docs.md       main skill — the instructions Claude follows
subagents/staleness-detector.md  per-file analysis subagent
hooks/post-edit.sh          PostToolUse hook for stale warnings
scripts/install.sh          installer
.living-docs.example.json   config template
```

## Reporting bugs

Open an issue with:
- What you ran (`/living-docs --dry-run`, etc.)
- What you expected
- What happened instead
- Language/framework of your project (helps reproduce)
- Relevant snippet from the doc and code that wasn't caught (or was wrongly flagged)

## Submitting changes

1. Fork the repo
2. Create a branch: `git checkout -b fix/what-youre-fixing`
3. Make your change
4. Test against a real project: install locally, run `/living-docs`
5. Open a PR with a clear description of the problem and fix

## Changing the skill

`skills/living-docs.md` is the most important file. Changes here affect how Claude behaves.

When editing it:
- Test with multiple project types (JS, Python, Go)
- Verify `--dry-run` still works
- Verify nothing changes when docs are already accurate
- Verify it doesn't rewrite things that don't need changing

## Changing the subagent

`subagents/staleness-detector.md` must always output valid JSON. If you change the output schema, update the skill to match.

## Adding a new doc format

1. Add detection logic to Step 4 in `skills/living-docs.md`
2. Add analysis guidance to `subagents/staleness-detector.md`
3. Add a `--format <name>` option in the args table
4. Add an example to `examples/`
5. Document in README

## Code style

Bash hooks: `set -euo pipefail`, quote all variables, no bashisms beyond bash 3.2 (macOS default).

Skill/subagent Markdown: headers for sections, tables for options, code blocks for examples, minimal prose.
