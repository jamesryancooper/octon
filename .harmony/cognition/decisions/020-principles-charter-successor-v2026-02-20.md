# ADR 020: Engineering Principles Charter Successor v2026-02-20

- Date: 2026-02-20
- Status: accepted
- Owner: @you
- Review-by: 2026-08-20

## Context

The canonical engineering charter at
`.harmony/cognition/principles/principles.md` is intentionally immutable and
enforced by governance lint and contract policy.

A comparison against an expanded standards draft identified useful additions
that improve precision and enforceability but are not explicitly present in the
immutable charter:

1. Defined glossary terms, including `significant change`.
2. Explicit subsystem ownership requirement.
3. Stricter SSOT hub minimum contract and discoverability requirement.
4. Explicit rule that configuration is part of the public surface.
5. Explicit prohibition of cross-boundary internal reach-in/backdoor imports.
6. ADR minimum required fields.
7. Performance-proof requirement for performance-motivated changes.
8. Explicit anti-pattern callout for mixed refactor + behavior PRs.
9. Explicit linkage of critical runbooks from SSOT hubs.

## Decision

Create versioned successor
`.harmony/cognition/principles/principles-v2026-02-20.md` that preserves the
current charter baseline and adds the identified governance improvements.

Do not modify the immutable charter in place.

## Alternatives Considered

1. Edit `principles.md` directly.
   - Rejected: violates immutable charter policy and governance lint.
2. Leave charter unchanged and capture additions only in discussion notes.
   - Rejected: loses enforceability and discoverability in the principles SSOT.
3. Add only an ADR without a successor charter file.
   - Rejected: records rationale but does not provide an actionable updated
     standards document.

## Consequences

### Positive

- Adds precise terms and stronger requirements without violating immutability.
- Improves documentation and boundary governance clarity for significant changes.
- Establishes explicit ADR content expectations and stronger PR quality signals.

### Costs

- Introduces two charter versions that require an explicit adoption/supersession
  choice by owners.
- Requires downstream references to decide when to point at the successor file.

## Links

- Immutable charter:
  `.harmony/cognition/principles/principles.md`
- Versioned successor:
  `.harmony/cognition/principles/principles-v2026-02-20.md`
- Principles index:
  `.harmony/cognition/principles/README.md`
