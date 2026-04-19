# API Reference

## Users

### createUser(name, email)

Creates a new user account.

**Parameters:**
- `name` (string) — display name
- `email` (string) — email address

**Returns:** user object with `id`, `name`, `email`

**Example:**
```js
const user = createUser('Alice', 'alice@example.com');
```

---

### getUser(id)

Fetches a user by their ID.

**Parameters:**
- `id` (string) — user UUID

**Returns:** user object or `null`

---

### deleteUser(id)

Permanently deletes a user. This action cannot be undone.

**Parameters:**
- `id` (string) — user UUID

**Returns:** `{ success: true }`
