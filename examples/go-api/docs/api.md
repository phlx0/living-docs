# API Reference

## Users

### GetUser

Fetches a user by ID.

```go
func GetUser(id string) (*User, error)
```

Returns `ErrNotFound` if the user does not exist.

---

### CreateUser

Creates a new user account.

```go
func CreateUser(name, email string) (*User, error)
```

---

### DeleteUser

Permanently removes a user.

```go
func DeleteUser(ctx context.Context, id string) error
```

> **Note:** This doc is intentionally stale for the living-docs example.
> `GetUser` and `CreateUser` are missing `context.Context` params.
> `CreateUser` is missing the `role` param.
> `DeleteUser` is missing the `hard bool` param.
> Run `/living-docs` to see all four caught and fixed.
