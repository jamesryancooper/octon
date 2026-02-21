# ADR 019: Deny-by-Default Uniform Enforcement and Agent-Only Operation

- Date: 2026-02-19
- Status: accepted

## Context

Harmony commits to deny-by-default as a core safety and trust invariant.

Operational review identified uneven enforcement across execution lanes:

1. Runtime services (`service.json` + runtime policy) enforce capabilities at
   invocation time.
2. Skills and shell services rely heavily on lint/validation and not always on
   runtime command/path enforcement.
3. Active artifacts still contain broad write scopes and unscoped command
   permissions that increase blast radius.

Harmony also needs policy behavior that supports both ACP-gated and fully
agentic execution while preserving fail-closed behavior.

## Decision

Adopt a single deny-by-default operating model across all lanes with these
rules:

1. Deny-by-default remains mandatory and is not optional.
2. All execution lanes must enforce policy at runtime, not only at validation
   time.
3. Active skills/services must use scoped permissions only:
   - `Bash(<scoped-command>)` required
   - `Write(<scoped-path>)` required
   - bare `Bash`/`Write` prohibited
4. Broad write scopes require a time-boxed exception lease with owner and
   expiry.
5. Exception leases are tracked in
   `.harmony/capabilities/_ops/state/deny-by-default-exceptions.yml` and CI
   fails on expired leases.
6. Introduce a low-risk `dev-fast` policy profile to reduce friction for
   routine local changes without weakening repository safety defaults.
7. Agent-only operation is supported via policy gates (risk tiers,
   separation-of-duties checks, and fail-closed rollback/kill-switch controls)
   rather than ACP gate prompts.

## Rationale

- Keeps trust and safety guarantees intact as autonomy increases.
- Aligns docs, validation, and runtime behavior.
- Reduces policy drift and hidden exception debt.
- Preserves practical development speed for low-risk edits.

## Consequences

### Positive

- Uniform policy behavior across runtime and shell execution paths.
- Reduced blast radius from scoped writes and scoped command execution.
- Explicit and auditable exception lifecycle.
- Better support for unattended agent execution.

### Costs

- Additional validation and runtime wrapper complexity.
- Migration effort to tighten existing broad scopes.
- Ongoing maintenance for exception leases and profile definitions.

## Alternatives Considered

1. Remove deny-by-default.
   - Rejected: conflicts with trust/governance guarantees and raises system
     risk.
2. Keep deny-by-default only in runtime lane.
   - Rejected: leaves inconsistent and bypassable behavior in shell lanes.
3. Keep broad-scope exceptions indefinitely.
   - Rejected: creates unmanaged privilege drift over time.

## Implementation Notes

- Extend service validation to enforce scoped `allowed-tools` for active
  services.
- Add runtime shell policy wrapper with command/path checks and fail-closed
  denies.
- Add exception lease schema + expiry checks in validators.
- Provide `dev-fast` profile and policy suggestion tooling.
- Add agent-only safety controls for high-risk classes.
