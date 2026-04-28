# File Change Map

## Framework contracts

```text
.octon/framework/engine/runtime/spec/autonomy-window-v1.schema.json
.octon/framework/engine/runtime/spec/mission-queue-v1.schema.json
.octon/framework/engine/runtime/spec/mission-continuation-decision-v1.schema.json
.octon/framework/engine/runtime/spec/mission-run-ledger-v1.schema.json
.octon/framework/engine/runtime/spec/mission-closeout-v1.schema.json
.octon/framework/engine/runtime/spec/connector-operation-v1.schema.json
.octon/framework/engine/runtime/spec/connector-admission-v1.schema.json
.octon/framework/engine/runtime/spec/mission-evidence-profile-v1.schema.json
.octon/framework/engine/runtime/spec/mission-runner-v1.md
.octon/framework/engine/runtime/spec/mission-continuation-v1.md
```

## Instance governance

```text
.octon/instance/governance/policies/mission-continuation.yml
.octon/instance/governance/policies/autonomy-window.yml
.octon/instance/governance/policies/connector-admission.yml
.octon/instance/governance/policies/mission-closeout.yml
.octon/instance/governance/connectors/README.md
.octon/instance/governance/connector-admissions/README.md
```

## Runtime implementation

```text
.octon/framework/engine/runtime/crates/kernel/src/mission/**
.octon/framework/engine/runtime/crates/kernel/src/main.rs
.octon/framework/engine/runtime/crates/policy_engine/**
.octon/framework/engine/runtime/crates/authority_engine/**
.octon/framework/engine/runtime/crates/replay_store/**
.octon/framework/engine/runtime/crates/telemetry_sink/**
```

## Runtime-created control/evidence/continuity

Do not prepopulate as authored authority. The runtime creates:

```text
.octon/state/control/engagements/<engagement-id>/active-mission.yml
.octon/state/control/execution/missions/<mission-id>/**
.octon/state/evidence/control/execution/missions/<mission-id>/**
.octon/state/continuity/repo/missions/<mission-id>/**
.octon/generated/cognition/projections/materialized/missions/**
```
