# File Change Map

## New framework runtime specs

| Target | Purpose |
|---|---|
| `.octon/framework/engine/runtime/spec/engagement-work-package-compiler-v1.md` | Runtime narrative contract for the prepare-only compiler boundary. |
| `.octon/framework/engine/runtime/spec/connector-posture-policy-v1.schema.json` | Machine-readable connector policy schema. |
| `.octon/framework/engine/runtime/spec/connector-posture-registry-v1.schema.json` | Machine-readable connector registry schema. |
| `.octon/framework/engine/runtime/spec/engagement-v1.schema.json` | Portable Engagement contract. |
| `.octon/framework/engine/runtime/spec/project-profile-v1.schema.json` | Portable Project Profile contract. |
| `.octon/framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json` | Per-engagement Objective Brief candidate/control-state contract. |
| `.octon/framework/engine/runtime/spec/work-package-v1.schema.json` | Portable Work Package contract. |
| `.octon/framework/engine/runtime/spec/decision-request-v1.schema.json` | Portable Decision Request contract. |
| `.octon/framework/engine/runtime/spec/evidence-profile-v1.schema.json` | Portable Evidence Profile contract. |
| `.octon/framework/engine/runtime/spec/preflight-evidence-lane-v1.md` | Preflight evidence lane contract. |
| `.octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json` | Stage-only v1 connector posture contract. |

## Constitutional contract updates

| Target | Purpose |
|---|---|
| `.octon/framework/constitution/contracts/registry.yml` | Register any new constitutional contract families. |
| `.octon/framework/constitution/contracts/{adapters,authority,objective,runtime}/family.yml` | Register new family-local contract members. |
| `.octon/framework/constitution/contracts/runtime/engagement-v1.schema.json` | Constitutional runtime mirror for Engagement. |
| `.octon/framework/constitution/contracts/runtime/project-profile-v1.schema.json` | Constitutional runtime mirror for Project Profile. |
| `.octon/framework/constitution/contracts/runtime/engagement-objective-brief-v1.schema.json` | Constitutional runtime mirror for per-engagement Objective Brief. |
| `.octon/framework/constitution/contracts/runtime/work-package-v1.schema.json` | Constitutional runtime mirror for Work Package. |
| `.octon/framework/constitution/contracts/runtime/evidence-profile-v1.schema.json` | Constitutional runtime mirror for Evidence Profile. |
| `.octon/framework/constitution/contracts/runtime/tool-connector-posture-v1.schema.json` | Constitutional runtime mirror for connector posture. |
| `.octon/framework/constitution/contracts/authority/decision-request-v1.schema.json` | Decision Request authority wrapper contract. |
| `.octon/framework/constitution/contracts/objective/engagement-objective-brief-v1.schema.json` | Constitutional objective mirror for per-engagement Objective Brief. |
| `.octon/framework/constitution/contracts/adapters/{connector-posture-policy-v1.schema.json,connector-posture-registry-v1.schema.json,tool-connector-posture-v1.schema.json}` | Constitutional adapter contracts for connector posture. |

## Architecture registry updates

| Target | Purpose |
|---|---|
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Add new path families for engagements, project profiles, work packages, decision requests, evidence profiles, connector posture, and preflight evidence. |
| `.octon/framework/cognition/_meta/architecture/specification.md` | Minimal narrative update only after registry change; do not duplicate a full path matrix. |

## Runtime implementation changes

| Target | Purpose |
|---|---|
| `.octon/framework/engine/runtime/crates/kernel/src/main.rs` | Add compiler CLI declarations for `start`, `profile`, `plan`, `arm`, `decide`, and `status`. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs` | Dispatch compiler commands and preserve `octon run start --contract` handoff. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/engagement.rs` | Compiler command implementation for `start`, `profile`, `plan`, `arm`, `decide`, and `status`. |

Split command files, authority-engine compiler modules, and a dedicated
context-pack request module are deferred unless and until they are promoted in
the live tree.

## Instance policy/configuration

| Target | Purpose |
|---|---|
| `.octon/instance/governance/policies/engagement-work-package-compiler.yml` | Work Package readiness gate policy. |
| `.octon/instance/governance/policies/evidence-profiles.yml` | Repo-local evidence-depth policy. |
| `.octon/instance/governance/policies/preflight-evidence-lane.yml` | Lane policy and allowed/forbidden actions. |
| `.octon/instance/governance/connectors/README.md` | Connector posture documentation; v1 stage-only/blocking. |
| `.octon/instance/governance/connectors/registry.yml` | Machine-readable connector posture registry. |
| `.octon/instance/governance/connectors/posture.yml` | Machine-readable connector stage/block/deny policy. |
| `.octon/instance/governance/engagements/path-families.yml` | Engagement compiler path-family declarations. |
| `.octon/instance/locality/project-profile.yml` | Durable repo-local Project Profile target; not live until created with retained source evidence. |

## State and generated paths

| Target | Purpose |
|---|---|
| `.octon/state/control/engagements/<engagement-id>/**` | Engagement and Work Package operational truth. |
| `.octon/state/evidence/engagements/<engagement-id>/**` | Retained engagement/work-package evidence. |
| `.octon/state/evidence/orientation/<orientation-id>/**` | Orientation evidence. |
| `.octon/state/evidence/project-profiles/<profile-id>/**` | Project Profile source evidence. |
| `.octon/generated/cognition/projections/materialized/engagements/**` | Non-authoritative operator read models. |

## Assurance

| Target | Purpose |
|---|---|
| `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-work-package-compiler.sh` | Validator. |
| `.octon/framework/assurance/runtime/_ops/tests/test-engagement-work-package-compiler.sh` | Proposal-bound regression test present in the live worktree; not a promotion target until proposal-path references are removed. |
