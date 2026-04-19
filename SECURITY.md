# Security Policy

## Scope

living-docs is a Claude Code plugin. It reads files in your project and passes content to Claude for analysis. It does not make network requests, store data externally, or execute arbitrary code beyond what is described in `hooks/post-edit.sh` and `scripts/install.sh`.

## Reporting a Vulnerability

If you find a security issue — for example, a hook that could be exploited via crafted file paths or tool input — please **do not open a public issue**.

Report privately by emailing the maintainer or opening a [GitHub Security Advisory](https://github.com/phlx0/living-docs/security/advisories/new).

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix if you have one

You will receive a response within 72 hours. Confirmed vulnerabilities will be patched and disclosed publicly after a fix is available.

## What to check

The surface area is small:

- `hooks/post-edit.sh` — reads `CLAUDE_TOOL_INPUT` env var and extracts a file path. Crafted tool input could attempt path injection.
- `scripts/install.sh` — clones from GitHub over HTTPS. Verify the URL before piping to `sh`.
- `skills/living-docs.md` / `subagents/staleness-detector.md` — prompt files read by Claude. No code execution.
