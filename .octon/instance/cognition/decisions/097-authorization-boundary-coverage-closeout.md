# ADR 097: Authorization Boundary Coverage Closeout

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
  - `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh`
  - `/.octon/state/evidence/validation/architecture/10of10-remediation/authorization-boundary/`

## Context

Octon already routed the major live execution entrypoints through
`authorize_execution(...)`, but the proof posture was incomplete. There was no
single retained coverage inventory, no dedicated validator for full material
path coverage, and some workflow paths under-classified their side effects.

## Decision

Treat authorization-boundary coverage as a first-class closure obligation.

Rules:

1. Material execution path families must be inventoried and retained as closure
   evidence.
2. Missing coverage is fail-closed.
3. Coverage validation must compose lower-level runtime and capability boundary
   checks without creating a rival control plane.

## Consequences

- The runtime boundary becomes auditable instead of merely plausible.
- Side-effect classification gaps become visible closure blockers.
- CI can enforce authorization coverage as architecture-level policy.
