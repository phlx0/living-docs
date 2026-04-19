# Changelog

All notable changes to living-docs are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.0.0] — 2026-04-19

### Added

- `/living-docs` skill with full staleness detection and surgical fix application
- `staleness-detector` subagent for per-file analysis
- `PostToolUse` hook that warns when code changes may have staled docs
- Support for Markdown, JSDoc, TSDoc, Python docstrings, Go doc comments, OpenAPI/Swagger, RST
- Detection of: function signature changes, parameter additions/removals, env var renames, CLI flag changes, API endpoint moves, config key renames, new undocumented exports
- `--dry-run`, `--all`, `--since <ref>`, single-file, and `--format` flags
- `.living-docs.json` project-level configuration
- `.living-docs-ignore` for permanent exclusions
- Debounced hook to avoid spamming warnings on rapid edits
- Install script with git-clone and fallback download paths
- Example project demonstrating staleness detection
