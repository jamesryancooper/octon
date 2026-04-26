# File-Change Map

This map classifies proposed changes by authority class. It is a proposal map,
not an implemented change list.

| File or file family | Action | Authority class | Reason | Source-of-truth relationship | Validation | Rollback implication |
| --- | --- | --- | --- | --- | --- | --- |
| `.octon/framework/engine/runtime/spec/support-envelope-reconciliation-v1.md` | create | runtime spec | Define reconciler contract | Authored framework authority | schema + architecture conformance | Remove spec and dependent validators |
| `.octon/framework/engine/runtime/spec/support-envelope-reconciliation-result-v1.schema.json` | create | runtime spec/schema | Stabilize generated reconciler output | Authored framework authority | schema validation | Revert schema and generated output |
| `.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json` | create | runtime spec/schema | Define per-run health read model | Authored framework authority | schema + fixture validation | Remove schema/generator/read models |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | update | runtime spec | Register run-health as generated-only read model | Authored framework authority | no-generated-authority validation | Revert addition |
| `.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` | update | runtime spec | Clarify closure-grade token fields and verifier obligations | Authored framework authority | token enforcement tests | Revert to prior contract |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | update | runtime spec | Require path-by-path typed-token proof | Authored framework authority | boundary coverage validator | Revert coverage requirements |
| `.octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs` | update | runtime code | Add complete token model, verifier types, consumed receipts | Runtime code | cargo test + negative controls | Revert crate changes |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | update | runtime code | Issue tokens only after valid grant and route/support checks | Runtime code | authorization tests | Revert token issuance integration |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs` | update/create | runtime code | Centralize verification/consumption helpers | Runtime code | token verification tests | Remove helper and restore callers |
| `.octon/framework/engine/runtime/crates/kernel/src/{commands,stdio,pipeline,workflow}.rs` | update | runtime code | Require verified typed effects at material boundaries | Runtime code | material-path negative tests | Revert API changes |
| `.octon/framework/assurance/runtime/_ops/scripts/generate-support-envelope-reconciliation.sh` | create | validator/generator | Emit generated reconciliation result | Assurance tool | golden fixtures | Remove generator and outputs |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh` | create | validator | Gate support truth before publication/runtime activation | Assurance validator | positive/negative fixtures | Disable validator; restore prior gates |
| `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh` | create | generator | Generate per-run health read models | Assurance generator | run-health fixtures | Remove generated health outputs |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh` | create | validator | Prove health reflects canonical inputs and cannot authorize | Assurance validator | run-health negative fixtures | Disable validator |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh` | update | validator | Enforce end-to-end token closure | Assurance validator | token positive/negative tests | Revert validator changes |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | update | validator | Fail if material paths lack token proof | Assurance validator | coverage fixture suite | Revert validator changes |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh` | update | validator | Add new gates to existing conformance path | Assurance validator | architecture conformance | Revert script dispatch addition |
| `.octon/framework/assurance/runtime/_ops/tests/test-support-envelope-reconciliation.sh` | create | fixture/test | Prove support mismatches fail deterministically | Assurance test | shell test suite | Remove test |
| `.octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh` | create | fixture/test | Prove health statuses and non-authority | Assurance test | shell test suite | Remove test |
| `.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh` | update | fixture/test | Prove valid token path and single-use behavior | Assurance test | shell/cargo tests | Revert test update |
| `.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh` | update | fixture/test | Prove bypass denials | Assurance test | shell/cargo tests | Revert test update |
| `.octon/framework/assurance/runtime/_ops/fixtures/support-envelope-reconciliation/**` | create | fixture | Coherent and incoherent support states | Assurance fixture | reconciler tests | Remove fixtures |
| `.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/**` | create | fixture | Healthy/blocked/stale/revoked/closure-ready runs | Assurance fixture | run-health tests | Remove fixtures |
| `.octon/framework/assurance/runtime/_ops/fixtures/authorized-effect-token-enforcement/**` | create/update | fixture | Valid and invalid token attempts | Assurance fixture | token tests | Remove/revert fixtures |
| `.octon/generated/effective/governance/support-envelope-reconciliation.yml` | regenerate | generated/effective | Runtime-effective support reconciliation projection | Derived only | freshness + schema validation | Delete/regenerate from canonical inputs |
| `.octon/generated/cognition/projections/materialized/runs/**/health.yml` | generate | generated/read-model | Operator run health | Derived only | run-health validator | Delete/regenerate |
| `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/**` | create | state/evidence | Retained validation and closure proof | Retained evidence | evidence completeness | Preserve or mark superseded; do not use as authority |
| `.github/workflows/architecture-conformance.yml` | validate only | outside octon-internal scope | Existing workflow already invokes key architecture gates | Not changed by this packet | CI run | No rollback action in this packet |
