# File Change Map

## Authored Product Contracts

| Path | Change |
| --- | --- |
| `.octon/framework/product/contracts/lifecycle-interaction-request-v1.schema.json` | Add request receipt schema. |
| `.octon/framework/product/contracts/lifecycle-interaction-return-v1.schema.json` | Add return receipt schema. |

## Authored Product And Runtime Documentation

| Path | Change |
| --- | --- |
| `.octon/framework/product/features/governed-lifecycle-orchestration.md` | Add Lifecycle Interaction Receipt Model boundary. |
| `.octon/framework/product/features/catalog.yml` | Add navigation refs for schemas, validator, tests, and generated projections. |

## Authored Lifecycle Contract And Extension Schema

| Path | Change |
| --- | --- |
| `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json` | Add optional interaction profile metadata. |
| `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json` | Allow interaction event/checkpoint references if needed. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml` | Declare proposal-packet emitted/accepted interaction metadata. |

## Authored Runtime

| Path | Change |
| --- | --- |
| `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json` | Add non-authorizing interaction ref context. |
| `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs` | Validate, record, and pass interaction refs without self-authorizing dispatch. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs` | Add request struct fields for interaction refs. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs` | Preserve target gate validation and mark interaction refs non-authorizing. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs` | Update adapter unit-test request fixtures for the new non-authorizing context fields. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs` | Update observer unit-test request fixtures for the new non-authorizing context fields. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs` | Update executor integration-test request fixtures for the new non-authorizing context fields. |

## Authored Skills And Validators

| Path | Change |
| --- | --- |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md` | Add typed request emission guidance when closeout is blocked by target-owned work. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md` | Add consumption-as-context boundary. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md` | Add consumption-as-context boundary. |
| `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md` | Add consumption-as-context boundary. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh` | Add receipt validator. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh` | Validate interaction metadata. |
| `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-interaction-receipts.sh` | Add positive and negative receipt tests. |
| `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh` | Add runner visibility without dispatch test. |
| `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh` | Add executor non-authority test. |

## Generated Projections

| Path | Change |
| --- | --- |
| `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycle.contract.yml` | Refresh derived projection from authored lifecycle contract. |
| `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md` | Refresh derived projection from authored skill. |

Generated projections are not source authority.
