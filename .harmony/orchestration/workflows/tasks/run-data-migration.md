---
title: "Task: Run a Data Migration"
description: Step-by-step guide to running database migrations safely with AI assistance.
access: human
---

# Task: Run a Data Migration

This guide walks you through planning and executing database migrations safely. Migrations are typically **T3 (elevated risk)** and require careful review.

---

## Quick Version

```bash
harmony spec "add bio column to users table"
# AI generates migration plan, you review
harmony approve-spec migration-add-bio
# AI generates migration files
harmony build
# Review PR, test in preview
# Approve, ship with monitoring
```

**Your time: 30-45 minutes** (due to T3 review requirements)

---

## Step-by-Step

### 1. Describe the Change

```bash
harmony spec "add bio column to users table, nullable text field"
```

For more complex migrations:
```bash
harmony spec "split users table into users and user_profiles tables"
```

### 2. AI Generates Migration Plan

AI analyzes the change and creates a detailed plan:

```
Analyzing migration...

Migration Plan:
┌─────────────────────────────────────────────────────────────────┐
│ Migration: Add bio column to users table                        │
│ Tier: T3 (database schema change)                               │
│                                                                 │
│ Type: Additive (low risk)                                       │
│                                                                 │
│ Changes:                                                        │
│   ALTER TABLE users ADD COLUMN bio TEXT DEFAULT NULL;           │
│                                                                 │
│ Impact Analysis:                                                │
│   - No existing data affected                                   │
│   - No downtime required                                        │
│   - No application code changes required immediately            │
│   - Backward compatible                                         │
│                                                                 │
│ Estimated execution time:                                       │
│   - Preview: < 1 second                                         │
│   - Production: < 5 seconds (depends on table size)             │
│                                                                 │
│ Locks: None (nullable column add in PostgreSQL)                 │
│                                                                 │
│ Rollback:                                                       │
│   ALTER TABLE users DROP COLUMN bio;                            │
│   Safe: Yes (no data loss)                                      │
│                                                                 │
│ Dependencies:                                                   │
│   - None                                                        │
│                                                                 │
│ Testing:                                                        │
│   - Migration runs successfully                                 │
│   - Column exists after migration                               │
│   - Existing queries still work                                 │
│   - New column accepts values                                   │
└─────────────────────────────────────────────────────────────────┘

Review this plan before proceeding. [Approve/Edit/Cancel]
```

**Your review (T3 requirement):**
- Is this the right change?
- Is the impact analysis accurate?
- Is the rollback safe?
- Any concerns about lock duration?

### 3. Approve the Plan

```bash
harmony approve-spec migration-add-bio
```

### 4. AI Generates Migration Files

```bash
harmony build
```

AI creates:
- Migration file (SQL or ORM-specific)
- Rollback file
- Tests for the migration
- Updated types/schemas

```
Building migration...

Files created:
- migrations/20250106_add_bio_to_users.sql
- migrations/20250106_add_bio_to_users_rollback.sql
- tests/migrations/test_add_bio.py
- src/types/user.ts (updated)

Tests:
- Migration up: passing
- Migration down: passing
- Integrity check: passing

Creating PR #150...
```

### 5. Review and Test

**Review the PR:**
- Does the SQL look correct?
- Is the rollback correct?
- Are types updated properly?

**Test in preview:**
```bash
# Run migration on preview database
harmony migrate run --environment preview

# Verify
harmony migrate verify --environment preview
```

### 6. Ship to Production

```bash
# Merge PR
# Promote deployment
harmony ship migration-add-bio

# Run migration on production
harmony migrate run --environment production

# Monitor
harmony migrate status --environment production
```

---

## Migration Types

### Additive (Low Risk)

Adding columns, tables, or indexes.

```bash
harmony spec "add created_at column to orders table with default now()"
```

Usually safe, minimal locks.

### Modification (Medium Risk)

Changing column types, constraints, or defaults.

```bash
harmony spec "change users.email to be unique constraint"
```

AI will check:
- Existing data compatibility
- Lock duration
- Index impact

### Destructive (High Risk)

Dropping columns, tables, or constraints.

```bash
harmony spec "remove deprecated legacy_id column from users"
```

AI will:
- Verify no code references it
- Plan data backup
- Require explicit confirmation

### Data Migration (High Risk)

Moving data between tables or transforming data.

```bash
harmony spec "migrate user preferences from JSON column to separate preferences table"
```

AI will plan:
- Dual-write period
- Backfill strategy
- Verification queries

---

## Complex Migration Patterns

### Rename Column

```bash
harmony spec "rename users.name to users.display_name"
```

AI implements:
1. Add new column
2. Copy data
3. Update code to use new column
4. Remove old column (later)

### Split Table

```bash
harmony spec "extract billing info from users into billing_profiles table"
```

AI implements:
1. Create new table
2. Migrate data
3. Update foreign keys
4. Update application code
5. Remove old columns (later)

### Add NOT NULL Column

```bash
harmony spec "add required account_id to orders table"
```

AI plans:
1. Add nullable column
2. Backfill existing rows
3. Add NOT NULL constraint
4. Update code

---

## Safety Features

### AI Checks (Automatic)

- **Lock analysis**: Estimates lock duration
- **Data compatibility**: Checks if existing data is compatible
- **Dependent code**: Finds code that uses affected tables
- **Index impact**: Analyzes query performance
- **Backup verification**: Confirms backups exist

### Required Approvals (T3)

1. **Plan approval**: Review before AI generates files
2. **PR approval**: Review generated migration
3. **Prod approval**: Confirm before running in production

### Rollback Guarantee

Every migration includes:
- Rollback SQL
- Verification that rollback works
- Data preservation guarantee (where possible)

---

## Running Migrations

### Preview Environment

```bash
# Run pending migrations
harmony migrate run --environment preview

# Check status
harmony migrate status --environment preview

# Rollback if needed
harmony migrate rollback --environment preview
```

### Production

```bash
# Check what will run
harmony migrate plan --environment production

# Run with confirmation
harmony migrate run --environment production

# Watch for issues
harmony migrate watch --environment production
```

### Monitoring During Migration

```bash
# Real-time status
harmony migrate status --live

# Output example:
# Migration: 20250106_add_bio_to_users
# Status: Running
# Progress: Altering table...
# Duration: 3s
# Locks: None active
# Errors: None
```

---

## Rollback Procedures

### Automatic Rollback

If migration fails:
```
Migration failed at step 2/3

Error: Cannot add NOT NULL column to non-empty table

Automatic rollback initiated...
Rollback complete.

Table state: Original (no changes applied)
```

### Manual Rollback

```bash
# Rollback last migration
harmony migrate rollback --environment production

# Rollback specific migration
harmony migrate rollback 20250106_add_bio_to_users --environment production

# Verify rollback
harmony migrate verify --environment production
```

---

## Best Practices

### Do

- ✅ Always review migration plan before approving
- ✅ Test in preview before production
- ✅ Run during low-traffic periods
- ✅ Have rollback ready
- ✅ Monitor during and after migration

### Don't

- ❌ Run untested migrations in production
- ❌ Modify production data without backup verification
- ❌ Combine multiple risky changes in one migration
- ❌ Run during peak traffic
- ❌ Ignore lock warnings

---

## Troubleshooting

### Migration Takes Too Long

```bash
# Check status
harmony migrate status --live

# If stuck, AI analyzes
harmony diagnose migration-add-bio

# May recommend: cancel and reschedule for lower traffic
```

### Migration Fails

```bash
# AI auto-rollbacks if possible
# Check what happened
harmony migrate log 20250106_add_bio_to_users

# Fix and retry
harmony fix migration-add-bio
```

### Data Integrity Issue

```bash
# Verify data
harmony migrate verify --environment production --deep

# If issues found
harmony migrate repair --environment production
```

---

## What AI Does (Behind the Scenes)

1. **Schema Analysis**: Analyzes current database schema
2. **Impact Assessment**: Calculates lock duration, affected rows
3. **Code Search**: Finds application code using affected tables
4. **Plan Generation**: Creates optimal migration strategy
5. **Safety Checks**: Verifies rollback, backups, compatibility
6. **Migration Generation**: Creates migration and rollback files
7. **Testing**: Tests migration up and down
8. **Monitoring**: Watches execution for issues

---

## Time Estimates

| Migration Type | Review Time | Execution Time |
|----------------|-------------|----------------|
| Add nullable column | 10-15 min | Seconds |
| Add constraint | 15-20 min | Seconds-minutes |
| Data backfill | 30-45 min | Minutes-hours |
| Table restructure | 45-60 min | Varies |

---

## Next Steps

- [Handle a security issue](./handle-security-issue.md)
- [Fix a bug](./fix-a-bug.md)
- Back to [DAILY-FLOW.md](/.harmony/agency/practices/daily-flow.md)
