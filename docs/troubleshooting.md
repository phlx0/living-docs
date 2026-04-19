# Troubleshooting

## living-docs didn't catch a stale doc

**Check 1 — Is the file in scope?**

living-docs only scans files matching `docs.include` patterns. Run with `--all` to force a full scan regardless of config:

```
/living-docs --all
```

If it catches the issue with `--all` but not normally, add the file's path pattern to `docs.include` in `.living-docs.json`.

**Check 2 — Is the file excluded?**

Check `.living-docs-ignore` and `docs.exclude` in `.living-docs.json`. The file may be listed there.

**Check 3 — Is the change in git?**

By default, living-docs diffs against `HEAD~1`. If you haven't committed your code change yet, use `--since` with a ref that predates the change:

```
/living-docs --since HEAD
```

**Check 4 — Is the reference indirect?**

living-docs detects explicit identifier references (function names, env var names, etc.). It won't catch docs that describe behavior in prose without naming the identifier. For example, "the second argument controls the timeout" won't be matched to a renamed parameter.

**Check 5 — Confidence threshold**

Issues flagged as `low` confidence are shown but not auto-fixed. Check the full output for any low-confidence warnings about the missed doc.

---

## living-docs flagged something that isn't stale

Use `--dry-run` to preview without applying. If the flag is wrong, you have two options:

1. **Ignore once** — say `n` at the confirmation prompt
2. **Ignore permanently** — add the file to `.living-docs-ignore`

If you think it's a false positive that others would also hit, [open an issue](https://github.com/phlx0/living-docs/issues) with the code snippet and doc snippet.

---

## Hook warning isn't appearing

**Check 1 — Is the hook enabled?**

```json
{ "hooks": { "enabled": true } }
```

**Check 2 — Debounce**

The hook fires at most once every `debounceSeconds` (default 30). If you edited multiple files quickly, subsequent warnings are suppressed.

**Check 3 — Is the plugin registered?**

Check `~/.claude/settings.json`:

```json
{
  "plugins": ["~/.claude/plugins/living-docs"]
}
```

**Check 4 — Hook permissions**

```bash
ls -la ~/.claude/plugins/living-docs/hooks/
# post-edit.sh should show -rwxr-xr-x
```

If not executable:
```bash
chmod +x ~/.claude/plugins/living-docs/hooks/*.sh
```

---

## "jq not found" or JSON parse errors

The hook extracts file paths from Claude's tool input. It tries `jq`, then `python3`, then pure bash. If all three fail, the hook exits silently (it won't crash your session).

Install `jq` for the most reliable parsing:

```bash
brew install jq          # macOS
apt-get install jq       # Debian/Ubuntu
```

---

## CI check always fails

Make sure you're diffing against the right base ref. In GitHub Actions, `HEAD~1` refers to the last commit on the PR branch, not the merge base with `main`. Use `--since origin/main` instead:

```bash
claude --print "/living-docs --dry-run --since origin/main"
```
