# Validation Plan

## Current Packet Validation

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-workspace-projects
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-workspace-projects
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-workspace-projects
```

Structural success does not satisfy future architecture-review or
implementation gates.

Proposal validation also parses the exact design receipt and verifies the
accepted RP-01 digest, UUIDv7/JCS/SHA-256 layout, no-follow path rules,
correction precedence, immutable snapshot fields, non-authoritative index,
read-only inbox limits, exact 16-target parity, and that future UE-010 results
are not claimed executed.

## Future Implementation Validation

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-engagement-change-package-compiler.sh
cargo test -p octon_kernel
```

Run Cargo from `.octon/framework/engine/runtime/crates/`. The implementation
must add RP-10 assertions and fixtures to the declared validator owners rather
than create a parallel validation authority.

## Required Scenario Matrix

### Schema and identity

- missing required field, unknown field, authority-shaped field, invalid ID,
  unsafe storage key, invalid normalized path, and digest mismatch;
- two distinct projects with stable IDs;
- same-repository relocation preserves ID;
- clone/fork/conflicting identity blocks inheritance until explicit adoption.

### Boundaries and corrections

- explicit parent/child monorepo relation succeeds;
- ambiguous sibling/parent overlap denies;
- traversal, symlink, mount alias, case alias, and external path deny;
- operator correction survives repeated inference;
- an undeclared dependency and cross-project write deny.

### Snapshot and authority

- refresh after run start leaves project/Profile refs and digests unchanged;
- project/Profile fields cannot mint grant, capability, support admission,
  credential, egress, or expanded write scope;
- generated location and inbox views cannot satisfy control inputs.

### Inbox and recovery

- two project missions are distinguishable;
- paused mission reports exact resume command;
- revoked/closed mission cannot be resumed by inbox;
- inbox reads leave mission control digests unchanged;
- missing location index rebuilds;
- corrupt registry/pointer blocks only affected selection.

## Evidence Contract

Retain command, exact commit, inputs, bounded outputs, results, and artifact
digests under:

`.octon/state/evidence/validation/proposals/octon-architecture-migration-workspace-projects/`

Planned tests remain `UNVERIFIED` until executed. Successful static validation
may be classified `STATICALLY_INSPECTED`; scenario runs may be classified
`DYNAMICALLY_EXECUTED`; adversarial path and authority attacks may be
`ADVERSARIALLY_TESTED` only when their executing producer records a result.
