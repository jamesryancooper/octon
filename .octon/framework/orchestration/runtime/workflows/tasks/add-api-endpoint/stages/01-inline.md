
# Task: Add an API Endpoint

This guide walks you through adding a new API endpoint using Octon's AI-assisted workflow.

---

## Quick Version

```bash
octon spec "GET /api/users/:id returns user profile"
# AI generates spec, you review summary
octon build
# AI writes code, tests, OpenAPI spec
# You review PR, approve
```

**Your time: 15-20 minutes**

Before broad verification, preview deployment, or any repo-consequential test
sweep, run `/repo-consequential-preflight` and stop if branch freshness or
repo-shell policy posture routes to warn, block, or escalate.

---

## Step-by-Step

### 1. Describe What You Want

```bash
octon spec "GET /api/users/:id returns user profile with name, avatar, and bio"
```

Be specific about:
- HTTP method (GET, POST, PUT, DELETE)
- Path (with parameters)
- What it returns (key fields)

### 2. AI Generates the Spec

AI creates a structured spec and shows you a summary:

```
Generating spec...

Spec Summary:
┌─────────────────────────────────────────────────────────────────┐
│ Endpoint: GET /api/users/:id                                    │
│ Purpose: Return user profile information                        │
│                                                                 │
│ Request:                                                        │
│   - Path param: id (string, required)                           │
│   - Auth: Required (Bearer token)                               │
│                                                                 │
│ Response (200):                                                 │
│   {                                                             │
│     "id": "string",                                             │
│     "name": "string",                                           │
│     "avatar": "string | null",                                  │
│     "bio": "string | null"                                      │
│   }                                                             │
│                                                                 │
│ Errors:                                                         │
│   - 401: Unauthorized                                           │
│   - 404: User not found                                         │
│                                                                 │
│ Tier: T2 (new endpoint)                                         │
│ Flag: feature.user-profile-endpoint                             │
│                                                                 │
│ Threat check: ✓ IDOR mitigated (auth required)                  │
│               ✓ No PII in response (email/phone excluded)       │
└─────────────────────────────────────────────────────────────────┘

Does this look right? [Y/n/edit]
```

**Your review:**
- Are the fields correct?
- Is auth requirement right?
- Any missing error cases?

Press Enter to continue, or `edit` to modify.

### 3. AI Builds the Endpoint

```bash
octon build
```

AI generates:
- Route handler code
- TypeScript types
- OpenAPI spec update
- Database queries (if needed)
- Unit tests
- Contract tests
- Documentation

```
Building user-profile-endpoint...

Files created/modified:
- src/app/api/users/[id]/route.ts (new)
- src/types/user.ts (+15 lines)
- packages/contracts/openapi.yaml (+45 lines)
- src/services/UserService.ts (+20 lines)
- __tests__/api/users.test.ts (new)

Tests:
- 4 unit tests (all passing)
- 1 contract test (passing)
- OpenAPI validation (passing)

Creating PR #142...
Deploying to preview...

Ready for review: https://github.com/your-repo/pull/142
Preview: https://preview-142.vercel.app
```

### 4. Review the PR

Open the PR. You'll see:

```markdown
## T2 Summary: Add GET /api/users/:id endpoint

**What**: New endpoint returning user profile
**Contract**: See OpenAPI diff below
**Auth**: Bearer token required
**Response**: { id, name, avatar, bio }

**Threat check**:
- ✓ IDOR: Auth required, users can only access their own profile
- ✓ Data exposure: No PII (email/phone excluded)

**Tests**: 4 unit, 1 contract, preview smoke passing
**Flag**: `feature.user-profile-endpoint` (OFF by default)

**Action needed**: Review spec summary and PR
```

**Your review checklist:**
- [ ] Does the spec summary match your intent?
- [ ] OpenAPI diff looks correct?
- [ ] Tests cover happy path and errors?
- [ ] Threat check addresses concerns?

### 5. Test in Preview (Optional)

```bash
# Get preview URL
octon preview "#142"

# Test the endpoint
curl -H "Authorization: Bearer $TOKEN" \
  https://preview-142.vercel.app/api/users/123
```

### 6. Approve and Ship

Approve the PR. After merge:

```bash
# Promote to production
octon ship user-profile-endpoint

# Enable for yourself first
octon flag enable feature.user-profile-endpoint --scope internal

# Test in production, then enable for all
octon flag enable feature.user-profile-endpoint
```

---

## Variations

### POST Endpoint (Create)

```bash
octon spec "POST /api/orders creates a new order with items array"
```

AI will:
- Define request body schema
- Add validation
- Handle idempotency (if applicable)
- Add appropriate tests

### PUT/PATCH Endpoint (Update)

```bash
octon spec "PATCH /api/users/:id/profile updates user bio and avatar"
```

AI will:
- Define partial update schema
- Add authorization check (own profile only)
- Handle validation

### DELETE Endpoint

```bash
octon spec "DELETE /api/users/:id/data removes all user data (GDPR)"
```

This is likely T3 (data deletion). AI will:
- Flag as elevated risk
- Add comprehensive logging
- Require confirmation flow
- Generate detailed threat analysis

### Authenticated vs Public

```bash
# Public endpoint (no auth)
octon spec "GET /api/products returns product list (public)"

# Requires auth (default assumption for user data)
octon spec "GET /api/me returns current user"
```

### Pagination

```bash
octon spec "GET /api/orders returns paginated order list with cursor-based pagination"
```

AI will add:
- Query params: `cursor`, `limit`
- Response: `{ data: [...], nextCursor: "..." }`
- Tests for pagination edge cases

---

## Modifying the Spec

### Before Build

```bash
# Edit interactively
octon spec edit

# Add a constraint
octon spec refine --context "also include created_at timestamp"
```

### After Build

```bash
# Request changes
octon refine user-profile-endpoint --context "add email field for admin users only"

# AI updates code and PR
```

---

## What AI Does (Behind the Scenes)

1. **Spec Generation**: Creates OpenAPI-compliant spec from your description
2. **Threat Analysis**: Runs STRIDE-lite check for IDOR, data exposure, etc.
3. **Code Generation**: Creates route handler following project patterns
4. **Type Generation**: Creates/updates TypeScript interfaces
5. **Contract Update**: Updates OpenAPI specification
6. **Test Generation**: Creates unit and contract tests
7. **Documentation**: Updates API docs
8. **CI Validation**: Runs OpenAPI lint, type check, tests

---

## Common Patterns

### Resource CRUD

```bash
# Create full CRUD for a resource
octon spec "CRUD for /api/widgets with name, description, price"
```

AI generates all four endpoints:
- `GET /api/widgets` (list)
- `GET /api/widgets/:id` (read)
- `POST /api/widgets` (create)
- `PUT /api/widgets/:id` (update)
- `DELETE /api/widgets/:id` (delete)

### Nested Resources

```bash
octon spec "GET /api/users/:userId/orders returns orders for a user"
```

### Webhooks

```bash
octon spec "POST /api/webhooks/stripe handles Stripe webhook events"
```

AI will:
- Add signature verification
- Handle idempotency
- Log events appropriately
- Likely flag as T3 (billing)

---

## Troubleshooting

### OpenAPI Validation Fails

```bash
# See what's wrong
octon diagnose "#142"

# AI fixes the issue
```

### Tests Failing

```bash
# See failures
octon test --pr "#142"

# AI diagnoses and fixes
```

### Wrong Tier Assigned

```bash
# Bump up if more complex
octon tier-up "#142" --reason "touches user authentication"

# Bump down if simpler
octon tier-down "#142" --reason "public endpoint, no auth"
```

---

## Tips

### Be Explicit About Auth

```bash
# Public
octon spec "GET /api/products (public, no auth required)"

# User's own data
octon spec "GET /api/me/settings (returns current user's settings)"

# Admin only
octon spec "GET /api/admin/users (admin role required)"
```

### Specify Response Shape

```bash
# Minimal - AI infers
octon spec "GET /api/users/:id returns user"

# Explicit - more control
octon spec "GET /api/users/:id returns { id, name, avatar, bio, createdAt }"
```

### Include Error Cases

```bash
octon spec "GET /api/orders/:id returns order, 404 if not found, 403 if not owner"
```

---

## Next Steps

- [Add a UI feature](./add-ui-feature.md)
- [Handle a security issue](./handle-security-issue.md)
- Back to [DAILY-FLOW.md](/.octon/framework/execution-roles/practices/daily-flow.md)
