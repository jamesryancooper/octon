# File Change Map

## Framework Contracts

Add:

- `.octon/framework/engine/runtime/spec/stewardship-program-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-epoch-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-trigger-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-admission-decision-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-idle-decision-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-renewal-decision-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-epoch-closeout-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-ledger-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-evidence-profile-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-aware-decision-request-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-campaign-coordination-hook-v1.schema.json`
- `.octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md`
- `.octon/framework/constitution/contracts/runtime/stewardship-*.schema.json`
- `.octon/framework/constitution/contracts/authority/stewardship-aware-decision-request-v1.schema.json`
- `.octon/framework/constitution/contracts/{registry.yml,runtime/family.yml,authority/family.yml}`
- `.octon/framework/cognition/_meta/architecture/{contract-registry.yml,specification.md}`

Update or reference:

- `.octon/framework/engine/runtime/spec/mission-charter-v2.schema.json`
- `.octon/framework/engine/runtime/spec/mission-control-lease-v1.schema.json`
- `.octon/framework/engine/runtime/spec/autonomy-budget-v1.schema.json`
- `.octon/framework/engine/runtime/spec/circuit-breaker-v1.schema.json`
- `.octon/framework/engine/runtime/spec/action-slice-v1.schema.json`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`

## Framework Practices

Add:

- `.octon/framework/orchestration/practices/stewardship-lifecycle-standards.md`
- `.octon/framework/overlay-points/registry.yml` to declare `instance-stewardship-programs`.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-continuous-stewardship-runtime-v3.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-continuous-stewardship-runtime-v3.sh`

Update:

- `.octon/framework/orchestration/practices/README.md` to reference stewardship standards.
- `.octon/framework/orchestration/practices/campaign-promotion-criteria.md` only if needed to add stewardship cross-reference without changing campaign boundaries.

## Instance Authority

Add:

- `.octon/instance/stewardship/programs/<program-id>/program.yml`
- `.octon/instance/stewardship/programs/<program-id>/policy.yml`
- `.octon/instance/stewardship/programs/<program-id>/trigger-rules.yml`
- `.octon/instance/stewardship/programs/<program-id>/review-cadence.yml`
- `.octon/instance/stewardship/programs/<program-id>/campaign-policy.yml`
- `.octon/instance/manifest.yml`

## State Control

Add:

- `.octon/state/control/stewardship/programs/<program-id>/status.yml`
- `.octon/state/control/stewardship/programs/<program-id>/epochs/<epoch-id>/epoch.yml`
- `.octon/state/control/stewardship/programs/<program-id>/triggers/<trigger-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/admission-decisions/<decision-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/idle-decisions/<decision-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/renewal-decisions/<decision-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/decisions/<decision-request-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/epochs/<epoch-id>/closeout.yml`
- `.octon/state/control/stewardship/programs/<program-id>/mission-handoffs/<handoff-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/ledger.yml`

## State Evidence

Add retained proof roots under:

- `.octon/state/evidence/stewardship/programs/<program-id>/**`

## State Continuity

Add resumable context under:

- `.octon/state/continuity/stewardship/programs/<program-id>/**`

## Generated Projections

Add optional derived views under:

- `.octon/generated/cognition/projections/materialized/stewardship/**`

## Runtime / CLI

Add or wire:

- `octon steward open`
- `octon steward status`
- `octon steward observe`
- `octon steward admit`
- `octon steward idle`
- `octon steward renew`
- `octon steward pause`
- `octon steward resume`
- `octon steward revoke`
- `octon steward close`
- `octon steward ledger`
- `octon steward triggers`
- `octon steward epochs`
- `octon steward decisions`
- `octon decide list --program-id <program-id>`
- `octon decide resolve <decision-id> --program-id <program-id>`

Update:

- `.octon/framework/engine/runtime/README.md`
- `.octon/framework/engine/runtime/run`
- `.octon/framework/engine/runtime/run.cmd`
- `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/commands/stewardship.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/commands/mission.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/commands/engagement.rs`
