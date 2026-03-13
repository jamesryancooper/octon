---
title: Accessibility Baseline
description: Build inclusive interfaces by default and treat accessibility checks as non-optional release quality gates.
pillar: Direction, Trust
status: Active
---

# Accessibility Baseline

> Accessibility is part of correctness, not a post-release enhancement.

## What This Means

User-facing flows must satisfy baseline accessibility expectations (semantic structure, keyboard operability, visible focus, and accessible names). CI should include automated checks.
Where accessibility validators are configured as ACP evidence, failures block promotion. Where they are not configured as gating evidence, failures must remain visible in stage artifacts and receipts until remediated or explicitly waived (see `.octon/cognition/practices/methodology/ci-cd-quality-gates.md`).

## Why It Matters

### Pillar Alignment: Direction through Validated Discovery

Direction includes user value. A feature that excludes users is not validated success.

### Pillar Alignment: Trust through Governed Determinism

Accessibility failures are predictable quality defects and should be treated like other regressions.

### Quality Attributes Promoted

- **Reliability**: UI works across assistive interaction modes.
- **Maintainability**: semantic markup reduces brittle UI behavior.
- **Simplicity**: clear structure improves usability for all users.

## In Practice

### ✅ Do

```typescript
// Good: semantic + labeled controls
export function SearchBox() {
  return (
    <form>
      <label htmlFor="q">Search</label>
      <input id="q" name="q" type="search" />
      <button type="submit">Submit</button>
    </form>
  );
}
```

```python
# Good: server-rendered template with labels and roles
HTML = """
<form>
  <label for='email'>Email</label>
  <input id='email' name='email' type='email' required />
  <button type='submit'>Save</button>
</form>
"""
```

### ❌ Don't

```typescript
// Bad: clickable div with no semantics or keyboard support
<div onClick={submit}>Save</div>
```

```python
# Bad: placeholder-only field, no programmatic label
HTML = "<input placeholder='Email' />"
```

## Relationship to Other Principles

- `Direction through Validated Discovery` requires serving real users.
- `Small Diffs, Trunk-based` helps ship incremental accessibility fixes quickly.
- `Guardrails` can enforce CI a11y gating.

## Anti-Pattern: Accessibility as Backlog Debt

Treating accessibility as “later cleanup” creates compounding remediation cost and user harm.

## Exceptions

Temporary exceptions are allowed only for non-user-facing prototypes and must not ship to production.
Waiver and exception semantics are defined in [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) (SSOT); ad-hoc approvals are invalid.

## Related Documentation

- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/practices/methodology/ci-cd-quality-gates.md`
- `.octon/cognition/governance/pillars/direction.md`
- `.octon/cognition/governance/pillars/trust.md`
