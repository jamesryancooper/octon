# Runtime and CLI Shape

## Current CLI posture

The kernel remains run-first. Material workflow execution must enter through
`octon run start --contract`; the Engagement compiler can only prepare a
candidate and readiness envelope for that entrypoint.

The MVP compiler command surface is limited to Engagement preparation and
operator-facing Decision Request/status control:

- `octon start`
- `octon profile`
- `octon plan`
- `octon arm --prepare-only`
- `octon decide`
- `octon status`

Decision Requests exist as Work Package/control records. `octon decide`
records an operator-facing resolution and materializes canonical low-level
approval, exception, revocation, risk, or evidence refs as applicable, but it
does not authorize material execution by itself.

## MVP v1 commands

### `octon start`

Creates a draft Engagement, captures seed intent, performs safe adoption preflight, and reports classification. Does not mutate project code.

### `octon profile`

Builds or reconciles Project Profile from retained orientation evidence.

### `octon plan`

Creates a per-engagement Objective Brief candidate, charter reconciliation
result, risk/materiality classification, validation/rollback plan, and Work
Package draft. The Objective Brief is engagement control state, not workspace
charter authority.

### `octon arm --prepare-only`

Resolves support/capability posture, evidence profile, context-pack request, Decision Requests, and first run-contract candidate. Prepare-only is the v1 default for new compiler surfaces.

### `octon decide`

Resolves Decision Requests into canonical approval/denial/exception/risk
acceptance/clarification artifacts where allowed. The Decision Request remains
a wrapper; canonical execution authority remains under existing low-level
control roots.

### `octon status`

Shows Engagement status from canonical Engagement control/evidence refs and
optional non-authoritative projections.

## Handoff to existing run lifecycle

After the Work Package returns `ready_for_authorization`, the operator or runtime may call:

```text
octon run start --contract .octon/state/control/execution/runs/<run-id>/run-contract.yml
```

The compiler must not bypass this existing entrypoint in v1.
