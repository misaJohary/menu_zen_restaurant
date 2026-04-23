# Backend RBAC Changes Summary

This document outlines the major changes made to the backend to support the new Role-Based Access Control (RBAC) system. Use this as a reference to update the mobile/frontend implementation.

---

## 1. Schema Changes (`app/schemas/auth_schemas.py`)

### `UserPublic` (The most critical for display)
The standard user object returned by the API now includes:
- `full_name` (string | null): Human-readable name.
- `role_id` (int): The numeric ID of the assigned role.
- `role_name` (string): **Auto-populated** human-readable name of the role (e.g., `"admin"`, `"cook"`, `"super_admin"`). 
  - *Implementation Detail:* This is dynamically injected from the database relationship via a `model_validator`.
- `must_change_password` (bool): Defaults to `false`. Set to `true` for newly created super-admins to force a password change.

### `UserCreate` (Creation)
You can now create users with either:
- `role_id`: The numeric ID of the role.
- `role_name`: The enum value (e.g., `"cook"`).
If both are omitted, the system defaults to `"admin"`.

### `UserUpdate` (Modification)
You can update a user's role by sending:
- `role_name`: `"cook"`, `"server"`, etc.
- `role_id`: Numeric ID.
- `full_name`: Updated display name.

---

## 2. API Endpoint Updates

### User Management (`app/routers/auth.py`)
- **`POST /users`**: Create a new user. Protected by `users:create` permission.
- **`GET /users/`**: List all users (supports `offset` and `limit`). Protected by `users:read` permission.
- **`GET /user`**: Fetch current authenticated user's profile and restaurant info.
- **`PATCH /user`**: Update current authenticated user's own profile.
- **`PATCH /users/{user_id}`**: (Admin Only) Update any user's role or info. Protected by `users:update` permission.
- **`DELETE /users/{user_id}`**: (Admin Only) Remove a user. Protected by `users:delete` permission.

### RBAC Metadata (`app/routers/admin_permissions.py`)
- **`GET /admin/roles`**: Returns a list of all available roles in the system (`super_admin`, `admin`, `cashier`, `server`, `cook`). Includes their hierarchy `level`.
- **`GET /admin/permissions`**: Returns a list of all raw system permissions (e.g., `users:create`, `menu:delete`).

---

## 3. Core RBAC Logic

### Role Hierarchy
Roles are now stored in a dedicated `roles` table. The hierarchy is:
1. `super_admin` (Level 100)
2. `admin` (Level 80)
3. `cashier` (Level 40)
4. `server` (Level 30)
5. `cook` (Level 20)

### Permissions Engine
Permissions are checked using the `require_permission(resource, action)` dependency.
Example: `require_permission("users", "create")` ensures the user's role (or custom overrides) has that specific permission.

---

## 4. Frontend Implementation Tips

1. **Role Display**: Use the `role_name` field from `UserPublic` to show the user's role as a label/badge.
2. **Access Control**: You can check `user.role_name == "admin"` or `user.role_name == "super_admin"` to conditionally show the Users management tab.
3. **Updating Roles**: When building the user editor, fetch available roles from `GET /admin/roles` and use the resulting list to populate a dropdown. Send the selected `role_name` back to `PATCH /users/{user_id}`.
4. **Error Handling**: Catch `403 Forbidden` errors. This specifically means the current user lacks the permission (RBAC) to perform that action on the backend.
