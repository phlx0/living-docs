# CLI Reference

## export

Convert data to various output formats.

### Flags

| Flag | Description |
|------|-------------|
| `--format` | Output format: `json`, `csv`, `yaml` (default: `json`) |
| `--pretty` | Pretty-print output |

### Examples

```bash
python cli.py --format csv data.json
python cli.py --format yaml --pretty data.json
```

> **Note:** This doc is intentionally stale for the living-docs example.
> `--format` was renamed to `--output-format` and `--max-items` was added.
> Run `/living-docs` to see it get caught and fixed.
