# State Control Architecture

`state/control/**` is the canonical mutable control-state surface for the
active `.octon/` harness.

## Canonical Control Records

| Path | Purpose |
| --- | --- |
| `.octon/state/control/extensions/active.yml` | Actual validated extension publication state, including desired versus published pack truth |
| `.octon/state/control/extensions/quarantine.yml` | Extension quarantine records with blocked packs, affected dependents, and reason codes |
| `.octon/state/control/locality/quarantine.yml` | Quarantined scopes and locality validation outcomes |

Other domain-owned control-state records may exist under `state/control/**`
when their owning contracts explicitly ratify them.

## Control-State Rules

- Control state records current mutable truth about what is active, blocked, or
  quarantined.
- Desired authored configuration remains outside `state/control/**`; for
  extensions that surface is `.octon/instance/extensions.yml`.
- Runtime-facing compiled publication remains under `generated/**`.
- Publication receipts for runtime-facing effective families live under
  `.octon/state/evidence/validation/publication/**`.
- Invalid control-state publication must fail closed rather than being ignored.

## Schema Contracts

- `schemas/extension-active-state.schema.json`
- `schemas/extension-quarantine-state.schema.json`
- `schemas/locality-quarantine-state.schema.json`
