/**
 * User API
 *
 * createUser(name, email, options?) — Create a new user
 * getUser(id) — Get user by ID
 * listUsers(filters?) — List all users with optional filters
 */

function createUser(name, email, options = {}) {
  const { role = 'user', verified = false } = options;
  return { id: crypto.randomUUID(), name, email, role, verified };
}

function getUser(id) {
  return db.users.findById(id);
}

function listUsers(filters = {}) {
  return db.users.findAll(filters);
}

module.exports = { createUser, getUser, listUsers };
