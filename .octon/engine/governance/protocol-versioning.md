# Protocol Versioning

## Policy

Engine protocol/schema changes MUST use explicit versioning and MUST NOT silently redefine existing versions.

## Governance Linkage

Every protocol-affecting change must carry an execution-profile receipt with:

- `change_profile`
- `release_state`
- hard-gate facts
- `transitional_exception_note` when required

## Rules

- New incompatible protocol behavior requires a new version identifier.
- Existing version semantics are immutable once released.
- Runtime validation must reject unsupported protocol versions (fail closed).
- Engine policy launcher contracts under `engine/runtime/spec/` follow the same
  versioning rule (for example `policy-interface-v1.md`).

## Compatibility Matrix

| Surface | Current | Supported | Unsupported Handling |
|---|---|---|---|
| Harness manifest schema (`/.octon/octon.yml:schema_version`) | `1.0` | `1.0` only | Reject (fail-closed) and route to deterministic `/migrate-harness` instructions in `/.octon/octon.yml` |
| Engine stdio protocol | `octon-stdio-v1` | `octon-stdio-v1` only | Reject handshake with `PROTOCOL_UNSUPPORTED` |
| Policy command interface | `policy-interface-v1` | `policy-interface-v1` only | Reject command with explicit schema/version violation |
| Policy receipt schema | `policy-receipt-v1` | `policy-receipt-v1` only | Reject receipt validation and fail policy gate |

## Upgrade Rules

1. Any incompatible version change MUST:
   - publish a new version identifier,
   - update the compatibility matrix in this document,
   - update `/.octon/octon.yml` version contract (if harness-facing), and
   - update `/.octon/orchestration/runtime/workflows/meta/migrate-harness/` migration instructions.
2. Promotion MUST be blocked until local and CI validators enforce the new version contract.
3. Promotion MUST include `Profile Selection Receipt`, `Implementation Plan`, `Impact Map`, `Compliance Receipt`, and `Exceptions/Escalations`.
4. In pre-1.0 mode, transitional protocol rollout requires a complete `transitional_exception_note`.

## Deterministic Unsupported-Version Path

When an unsupported version is detected, enforcement MUST:

1. Fail closed without partial compatibility shims.
2. Emit deterministic migration instructions (workflow + ordered steps).
3. Require rerunning governed validation gates before promotion.
