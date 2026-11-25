<!-- Changed from https://github.com/BehiSecc/VibeSec-Skill. Apache License 2.0; see LICENSE. -->

# Access Control
## Access Control Issues

Access control vulnerabilities occur when users can access resources or perform actions beyond their intended permissions.

### Core Requirements

For **every data point and action** that requires authentication:

1. **User-Level Authorization**
   - Each user must only access/modify their own data
   - No user should access data from other users or organizations
   - Always verify ownership at the data layer, not just the route level

2. **Use UUIDs Instead of Sequential IDs**
   - Use UUIDv4 or similar non-guessable identifiers
   - Exception: Only use sequential IDs if explicitly requested by user

3. **Account Lifecycle Handling**
   - When a user is removed from an organization: immediately revoke all access tokens and sessions
   - When an account is deleted/deactivated: invalidate all active sessions and API keys
   - Implement token revocation lists or short-lived tokens with refresh mechanisms

### Authorization Checks Checklist

- [ ] Verify user owns the resource on every request (don't trust client-side data)
- [ ] Check organization membership for multi-tenant apps
- [ ] Validate role permissions for role-based actions
- [ ] Re-validate permissions after any privilege change
- [ ] Check parent resource ownership (e.g., if accessing a comment, verify user owns the parent post)

### Common Pitfalls to Avoid

- **IDOR (Insecure Direct Object Reference)**: Always verify the requesting user has permission to access the requested resource ID
- **Privilege Escalation**: Validate role changes server-side; never trust role info from client
- **Horizontal Access**: User A accessing User B's resources with the same privilege level
- **Vertical Access**: Regular user accessing admin functionality
- **Mass Assignment**: Filter which fields users can update; don't blindly accept all request body fields

### Implementation Pattern

```
# Pseudocode for secure resource access
function getResource(resourceId, currentUser):
    resource = database.find(resourceId)

    if resource is null:
        return 404  # Don't reveal if resource exists

    if resource.ownerId != currentUser.id:
        if not currentUser.hasOrgAccess(resource.orgId):
            return 404  # Return 404, not 403, to prevent enumeration

    return resource
```

---

