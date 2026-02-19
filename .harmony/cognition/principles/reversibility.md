---
title: Reversibility
description: Every change should be undoable. Design systems so mistakes are recoverable, not catastrophic.
pillar: Trust, Velocity
status: Active
---

# Reversibility

> Every change should be undoable. Design systems so mistakes are recoverable, not catastrophic.

## What This Means

Reversibility is a risk management principle: design every change so it can be rolled back safely. This includes code deployments, database migrations, feature releases, and configuration changes.

Reversibility is not just about having a rollback button — it's about designing changes so that rollback is:
- **Safe**: Rolling back doesn't cause data loss or corruption
- **Fast**: Seconds to minutes, not hours
- **Tested**: Rollback procedures are rehearsed, not theoretical

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

The Trust pillar promises "confidence in correctness, security, recoverability." Reversibility delivers recoverability directly:

- Developers ship confidently knowing mistakes are fixable
- Incidents have immediate mitigation (rollback) while root cause is investigated
- Security issues can be contained quickly by reverting changes

### Pillar Alignment: Velocity through Agentic Automation

Counterintuitively, reversibility enables speed. The Velocity pillar's promise of "sustained, high-frequency delivery" depends on:

- **Lower stakes per deployment**: If rollback is easy, each deploy is less risky
- **Faster feedback loops**: Ship small changes, revert if broken, iterate
- **Reduced fear**: Teams don't slow down out of caution when recovery is reliable

> *"Go fast because you can always go back."*

### The Expand/Contract Pattern

Reversibility is implemented through the expand/contract pattern:

1. **Expand**: Add new capability alongside existing (both work)
2. **Migrate**: Gradually shift traffic/data to new capability
3. **Contract**: Remove old capability only after new is proven

This ensures there's always a working state to return to.

### Stage, Promote, Finalize

Reversibility under RA/ACP uses explicit phases:

1. **Stage**: apply changes in reversible form (branch/overlay/canary/tombstone) that can be discarded safely.
2. **Promote**: move staged changes to durable state only after ACP gate pass (policy + evidence + rollback validation + quorum where applicable).
3. **Finalize**: irreversible cleanup (for example hard delete) remains blocked by default and is separate from routine promotion.

For destructive-adjacent operations, use soft destruction with a declared recovery window before any finalize step.

## Scope Boundary with ACP

Promotion and contraction authority is defined in
[Autonomous Control Points](./autonomous-control-points.md).

This document defines design guidance for reversible primitives, rollback paths,
and recovery windows. Human escalation occurs only when ACP policy triggers it
(for example threshold breach, unresolved disagreement, or break-glass policy).

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
This principle defines reversible design patterns; ACP defines durable-state authority.

## In Practice

### Deployment Reversibility

Every deployment should be instantly reversible:

| Mechanism | Rollback Time | Use Case |
|-----------|---------------|----------|
| Re-promote prior version | Seconds | Standard rollback |
| Feature flag toggle | Milliseconds | Disable specific feature |
| Traffic shift | Seconds | Gradual rollout reversal |
| Database restore | Minutes | Data corruption (last resort) |

### ✅ Do

**Use feature flags as kill switches:**

```typescript
// Good: Feature can be disabled instantly
async function processPayment(order: Order) {
  if (await flags.isEnabled('new-payment-processor')) {
    return newProcessor.charge(order);
  }
  return legacyProcessor.charge(order);
}
```

**Design migrations to be reversible:**

```sql
-- Migration: Add column (reversible)
-- Up
ALTER TABLE users ADD COLUMN preferred_name VARCHAR(255);

-- Down
ALTER TABLE users DROP COLUMN preferred_name;
```

```sql
-- Migration: Rename column (expand/contract)
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN display_name VARCHAR(255);
UPDATE users SET display_name = name;

-- Step 2: Application reads from both, writes to both
-- Step 3: After verification, drop old column
ALTER TABLE users DROP COLUMN name;
```

**Rehearse rollback procedures:**

```yaml
# runbooks/rollback.md
## Production Rollback Procedure

### Prerequisites
- [ ] Identify the last known good version
- [ ] Verify rollback target is deployable

### Steps
1. Navigate to deployment dashboard
2. Select prior version
3. Click "Promote to Production"
4. Verify health checks pass
5. Monitor error rates for 5 minutes

### Verification
- [ ] Error rate returned to baseline
- [ ] No increase in support tickets
- [ ] Core flows functional (smoke test)
```

**Keep rollback paths tested:**

```typescript
// Good: Rollback path is exercised in tests
describe('payment processor migration', () => {
  it('processes payment with new processor', async () => {
    await flags.enable('new-payment-processor');
    const result = await processPayment(testOrder);
    expect(result.status).toBe('success');
  });

  it('falls back to legacy processor when flag disabled', async () => {
    await flags.disable('new-payment-processor');
    const result = await processPayment(testOrder);
    expect(result.status).toBe('success');  // Legacy still works
  });
});
```

### ❌ Don't

**Don't make irreversible changes in a single step:**

```sql
-- Bad: Destructive migration
DROP TABLE old_users;
ALTER TABLE new_users RENAME TO users;

-- Good: Expand/contract
-- Step 1: Create new table, copy data
-- Step 2: Application uses new table
-- Step 3: After verification period, drop old table
```

**Don't couple deployment with data migration:**

```yaml
# Bad: Deploy and migrate atomically
deploy:
  - run: npm run build
  - run: npm run db:migrate  # Irreversible
  - run: npm run deploy

# Good: Separate concerns
deploy:
  - run: npm run build
  - run: npm run deploy
  # Migration runs separately with rollback plan
```

**Don't skip the dual-write period:**

```typescript
// Bad: Instant cutover
const user = await newDatabase.getUser(id);

// Good: Dual-read with fallback during migration
const user = await newDatabase.getUser(id)
  ?? await legacyDatabase.getUser(id);
```

**Don't deploy without a rollback plan:**

```markdown
<!-- Bad: PR without rollback consideration -->
## Changes
- Updated payment processor integration

<!-- Good: PR with rollback plan -->
## Changes
- Updated payment processor integration

## Rollback Plan
- Disable `new-payment-processor` flag
- Re-promote v2.3.1 if flag disable insufficient
- No data migration; rollback is clean
```

## Implementation Patterns

### Feature Flag Lifecycle

```
OFF (default) → Canary (1%) → Gradual (10%, 50%) → GA (100%) → Cleanup
     ↑                                                              │
     └──────────────── Rollback at any stage ──────────────────────┘
```

### Database Migration Strategy

| Change Type | Strategy | Rollback Complexity |
|-------------|----------|---------------------|
| Add column | Direct add | Drop column (simple) |
| Remove column | Stop using → deploy → drop | Re-add (if within retention) |
| Rename column | Add new → dual-write → drop old | Use old column |
| Change type | Add new column → migrate → drop | Use old column |
| Add table | Direct add | Drop table |
| Remove table | Stop using → deploy → drop | Restore from backup |

### Deployment Slots

```
Production Slots:
├── Slot A: v2.3.1 (currently live)
├── Slot B: v2.3.2 (warming up)
└── Rollback: Redirect traffic A → B or B → A
```

### Configuration Rollback

```yaml
# config/production.yaml
version: 2.3.2
previous_version: 2.3.1  # Always track for rollback

rollback_procedure:
  1. Set version: 2.3.1
  2. Redeploy
  3. Verify
```

## Rollback Decision Framework

When something goes wrong:

```
Issue detected
     │
     ▼
Can we fix forward in < 15 minutes?
     │
   Yes ──→ Fix forward (hotfix)
     │
    No
     │
     ▼
Is rollback safe (no data migration)?
     │
   Yes ──→ Rollback immediately
     │
    No
     │
     ▼
Can we disable via feature flag?
     │
   Yes ──→ Disable flag, investigate
     │
    No
     │
     ▼
Incident escalation: careful rollback with data consideration
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Simplicity Over Complexity | Simple systems are easier to roll back |
| Small Diffs, Trunk-Based | Small changes have smaller rollback blast radius |
| Flags by Default | Feature flags enable instant reversibility |
| Determinism | Deterministic systems have predictable rollback behavior |

## Exceptions

Some changes are inherently difficult to reverse:

- **Data deletion**: Implement soft-delete with retention period
- **External API changes**: Version APIs, maintain old versions
- **Cryptographic key rotation**: Keep old keys valid during transition
- **User-facing URL changes**: Implement redirects before removing old URLs

For these cases:
1. Extend the expand phase
2. Require explicit ACP contraction gate pass (policy + evidence + rollback validation + quorum where applicable)
3. Use soft-destruction defaults with declared recovery windows before finalization
4. Document the point of no return

## Anti-Pattern: Big Bang Release

The primary failure mode of ignoring reversibility is the **big bang release** — a large change deployed without rollback capability.

Signs of big bang releases:
- "We can't roll back because of the database migration"
- Deployment takes hours with manual steps
- No feature flags for new functionality
- "Let's wait until we're sure" delays shipping

Prevention:
- Break large changes into reversible increments
- Always ship behind flags
- Never couple deploy with irreversible data changes
- Practice rollback in staging

## Related Documentation

- [Trust Pillar](../pillars/trust.md) — Confidence through recoverability
- [Velocity Pillar](../pillars/velocity.md) — Speed enabled by safe rollback
- [Flags by Default](./flags-by-default.md) — Feature flags for reversibility
- [Small Diffs, Trunk-based](./small-diffs-trunk-based.md) — Smaller changes, easier rollback
- [Autonomous Control Points](./autonomous-control-points.md) — Stage/promote governance and exception escalation policy
