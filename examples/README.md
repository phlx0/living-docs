# Examples

Minimal examples showing what living-docs detects and fixes.

## demo — Node.js API

`examples/demo/` contains a simple Express-style API (`src/api.js`) and its documentation (`docs/api.md`).

The doc is intentionally stale:
- `createUser` signature changed (added `options` param) but doc shows old signature
- `deleteUser` was removed but doc still describes it
- New `listUsers` function exists but is not documented

**Run the demo:**

```bash
cd examples/demo
git init && git add . && git commit -m "initial"

# Simulate a code change
cat >> src/api.js << 'EOF'

// New function added
function listUsers(filters = {}) { /* ... */ }
module.exports.listUsers = listUsers;
EOF

# createUser signature change
sed -i 's/function createUser(name, email)/function createUser(name, email, options = {})/' src/api.js

git add src/api.js

# Now run living-docs
claude "/living-docs"
```

Expected output: flags `docs/api.md` for outdated `createUser` signature and missing `listUsers` documentation.
