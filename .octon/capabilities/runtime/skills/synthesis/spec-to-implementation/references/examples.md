---
title: Examples Reference
description: Implementation plan examples for the spec-to-implementation skill.
---

# Examples Reference

Use command: `/spec-to-implementation`.

## Example 1: Authentication Feature

**Spec:** "Add email/password authentication with password reset"

**Decomposition:**

| ID | Title | Domain | Complexity | Dependencies |
|----|-------|--------|-----------|-------------|
| T01 | Create users table with auth fields | database | S | none |
| T02 | Implement password hashing utility | api | S | none |
| T03 | Build registration endpoint | api | M | T01, T02 |
| T04 | Build login endpoint with JWT | api | M | T01, T02 |
| T05 | Build password reset flow | api | M | T01, T02 |
| T06 | Create registration form | frontend | M | T03 |
| T07 | Create login form | frontend | M | T04 |
| T08 | Create password reset UI | frontend | S | T05 |

**Milestones:**
1. Foundation (T01-T02): Schema and utilities
2. API (T03-T05): All endpoints working
3. UI (T06-T08): Full user-facing flow

## Example 2: Ambiguity Handling

**Spec:** "Make the dashboard faster"

**Parse output:**
```
## Ambiguities
- [ASSUMPTION] "Faster" means reducing initial load time below 2 seconds
- [QUESTION] Does this include mobile dashboard or web only?
- [QUESTION] Is server-side rendering an option?
```

The skill flags these as open questions in the review phase rather than making assumptions silently.
