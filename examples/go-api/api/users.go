// Package api is an intentionally stale example for living-docs.
// db is a stub — this file exists to show what living-docs detects, not to compile.
package api

import "context"

type database struct{}

func (d *database) FindUser(_ context.Context, _ string) (*User, error)           { return nil, nil }
func (d *database) InsertUser(_ context.Context, _, _, _ string) (*User, error)   { return nil, nil }
func (d *database) SoftDeleteUser(_ context.Context, _ string) error              { return nil }
func (d *database) HardDeleteUser(_ context.Context, _ string) error              { return nil }

var db = &database{}

// User represents an account in the system.
type User struct {
	ID    string
	Name  string
	Email string
	Role  string
}

// GetUser fetches a user by ID.
// Returns ErrNotFound if the user does not exist.
func GetUser(ctx context.Context, id string) (*User, error) {
	return db.FindUser(ctx, id)
}

// CreateUser creates a new user account with the given name and email.
// role defaults to "member" if empty.
func CreateUser(ctx context.Context, name, email, role string) (*User, error) {
	if role == "" {
		role = "member"
	}
	return db.InsertUser(ctx, name, email, role)
}

// DeleteUser permanently removes a user and all associated data.
// This operation is irreversible.
func DeleteUser(ctx context.Context, id string, hard bool) error {
	if hard {
		return db.HardDeleteUser(ctx, id)
	}
	return db.SoftDeleteUser(ctx, id)
}
