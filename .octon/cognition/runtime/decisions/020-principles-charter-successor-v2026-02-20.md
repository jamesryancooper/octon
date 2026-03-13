# ADR 020: Engineering Principles Charter Successor v2026-02-20

- Date: 2026-02-20
- Status: Superseded by ADR 042
- Owner: @you
- Review-by: 2026-08-20
- Superseded-by:
  - `042-principles-charter-human-override-direct-edit-policy`

## Context

At the time of this ADR, the canonical engineering charter at
`.octon/cognition/principles/principles.md` was treated as intentionally
immutable and enforced by governance lint and contract policy.

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
`.octon/cognition/principles/principles-v2026-02-20.md` that preserves the
current charter baseline and adds the identified governance improvements.

Under then-active policy, do not modify the immutable charter in place.

## Alternatives Considered

1. Edit `principles.md` directly.
   - Rejected under then-active policy: violated immutable-charter governance lint.
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
  `.octon/cognition/principles/principles.md`
- Versioned successor:
  `.octon/cognition/principles/principles-v2026-02-20.md`
- Principles index:
  `.octon/cognition/principles/README.md`

## Status Update (2026-02-24)

- ADR 042 supersedes this ADR's active policy posture.
- Paths in this ADR reflect a pre-governance-split layout and are retained as
  historical context only.
