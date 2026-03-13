---
title: Reversibility
description: Routine autonomous changes must be undoable. Design systems so mistakes are recoverable, not catastrophic.
pillar: Trust, Velocity
status: Active
---

# Reversibility

> For routine autonomous operations (ACP-1 through ACP-3), changes MUST be reversible or recoverable with a rollback handle.

## What This Means

Reversibility is a risk management principle: design routine autonomous changes so they can be rolled back safely. This includes code deployments, database migrations, feature releases, and configuration changes.

For routine autonomous operations (ACP-1 through ACP-3), promoted changes MUST include a recoverable rollback path and rollback handle. ACP-4 remains break-glass only and is blocked by default in normal runs.

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
3. **Finalize**: irreversible cleanup (for example hard delete) is ACP-4, blocked by default, and separate from routine promotion.

For destructive-adjacent operations, use soft destruction with a declared recovery window before any finalize step.

## Scope Boundary with ACP

Promotion and contraction authority is defined in
[Autonomous Control Points](./autonomous-control-points.md).

This document defines design guidance for reversible primitives, rollback paths,
and recovery windows. Human escalation occurs only when ACP policy triggers it
(for example threshold breach, unresolved disagreement, or break-glass policy).
Contraction/finalize actions require ACP contraction gate pass (policy +
evidence + rollback validation + quorum where applicable), not standing manual
sign-off.

Routine autonomy scope is ACP-1 through ACP-3. ACP-4 operations are break-glass,
blocked by default, explicitly audited, and out-of-band from normal autonomous runs.

## Canonical References

- Promotion/contraction mechanics: [Autonomous Control Points](./autonomous-control-points.md)
- Capability attempt authorization: [Deny by Default](./deny-by-default.md)

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

## In Practice

Aim for fast, tested rollback (typically seconds to minutes where platform/runtime supports it), with clear recovery windows for destructive-adjacent operations.

### ✅ Do

- Use expand/contract and dual-write/dual-read patterns for state transitions.
- Keep rollback handles and recovery windows in receipts for each promoted slice.
- Rehearse rollback paths in staging and keep rollback checks in CI for risky changes.
- Use feature flags and canary rollouts to reduce rollback blast radius.

### ❌ Don't

- Don’t couple durable promote steps with irreversible schema/data finalization.
- Don’t hard-delete as part of routine autonomous runs.
- Don’t ship changes without an explicit rollback path.

## Operational Detail (Progressive Disclosure)

Detailed runbooks and incident playbooks live in:

- `.octon/cognition/practices/methodology/reliability-and-ops.md`
- `.octon/cognition/practices/methodology/flow-and-wip-policy.md`
- `.octon/cognition/practices/methodology/README.md`

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Complexity Calibration | Complexity level must stay proportional so rollback paths remain robust and operable |
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
