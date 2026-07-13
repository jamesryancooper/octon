# File Change Map

All targets are `.octon/**`; directory targets grant only the RP-08 artifacts
described here.

| Promotion target | Planned change | Ownership / boundary |
| --- | --- | --- |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Bind attempting/unknown/reconciling/manual-intervention behavior and status. | RP-08 semantics; RP-03 transitions unchanged. |
| `.octon/framework/engine/runtime/spec/effect-reconciliation-v1.md` | New provider classification, reconciliation, attribution, retry, PR, and degraded contract. | RP-08. |
| `.octon/framework/engine/runtime/spec/effect-reconciliation-v1.schema.json` | Strict observation/decision/receipt schema. | RP-08. |
| `.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json` | Add class/route, attempt, attribution, dependency, preserved-work, and next-action fields. | Projection only. |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | Document concise reconciliation/degraded status and non-authority. | RP-08 UX. |
| `.octon/framework/engine/runtime/spec/mission-autonomy-runtime-v2.md` | Integrate bounded SI-06 routes without changing class predicate. | Exact RP-08 integration. |
| `.octon/framework/engine/runtime/spec/mission-continuation-v1.md` | Require unknown reconciliation and bounded maintenance resume. | RP-08 exact behavior. |
| `.octon/framework/engine/runtime/spec/mission-runner-v1.md` | Bind scheduled governed runs to frozen route/effect/evidence contracts. | No new scheduler. |
| `.octon/framework/constitution/contracts/runtime/mission-run-ledger-v1.schema.json` | Record route digest, attempt/outcome attribution, unknown/manual state. | RP-08 exact fields. |
| `.octon/framework/constitution/contracts/runtime/mission-continuation-decision-v1.schema.json` | Deny continuation/retry while unknown and bind next probe. | RP-08 exact fields. |
| `.octon/framework/constitution/contracts/runtime/mission-closeout-v1.schema.json` | Require honest terminal/manual and signed completeness. | RP-08 exact fields. |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Register reconciliation/continuous-operation contracts. | Serialized exact entries. |
| `.octon/framework/constitution/contracts/registry.yml` | Register exact integration surfaces. | Serialized exact entries. |
| `.octon/framework/engine/runtime/crates/effect_reconciler/` | Add provider adapters, classifier, restart scanner, bounded probes, and legal RP-03 client. | RP-08; credentialless library with no store-writer, effect-dispatch, or policy authority. |
| `.octon/framework/engine/runtime/crates/Cargo.toml` | Add exact crate membership/dependencies. | Serialized entry. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mission.rs` | Wire bounded maintenance/status/reconcile commands through canonical runtime. | RP-08 exact command integration. |
| `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_run_admission.rs` | Bind frozen route digest and unknown/reconcile admission checks. | No authority predicate change. |
| `.octon/instance/governance/policies/mission-autonomy.yml` | Reference immutable route predicate and SI-06/reconciliation behavior. | Exact integration; RP-06 predicate values excluded. |
| `.octon/instance/governance/policies/mission-continuation.yml` | Require bounded restart/reconcile-before-retry and preserve work. | RP-08. |
| `.octon/instance/governance/policies/mission-closeout.yml` | Require honest attribution/terminal/manual completeness. | RP-08. |
| `.octon/instance/governance/policies/continuous-operation.yml` | New bounded maintenance/effect schedule policy over missions/runs. | RP-08; no scheduler/authority. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-effect-reconciliation.sh` | Validate frozen inputs, state behavior, attribution, retry, PR, degraded, and status. | RP-08. |
| `.octon/framework/assurance/runtime/_ops/tests/effect-reconciliation/` | Add crash/lost/duplicate/race/outage/attribution/route/PR fixtures. | RP-08 proof. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh` | Validate new status fields/freshness/non-authority. | RP-08 exact checks. |
| `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh` | Derive concise view from canonical refs only. | Projection generator. |
| `.octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh` | Add attempting/unknown/reconcile/manual/degraded snapshots. | RP-08. |
| `.octon/framework/assurance/runtime/_ops/scripts/test-mission-autonomy-scenarios.sh` | Add immutable A/B/C, zero-prompt, PR, scheduled/reversible cases. | RP-08 scenario additions. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-autonomy-runtime-v2.sh` | Enforce frozen predicate, SI-06, no trust-root/production and no blind retry. | RP-08 exact checks. |
| `.octon/framework/assurance/runtime/_ops/tests/test-mission-autonomy-runtime-v2.sh` | Add route/outage/continuous-operation integration fixtures. | RP-08. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-recovery-class-b/` | Retain route/fault/attribution/status/degraded/scheduled/reversible proof and receipts. | Evidence owner; scratch targets only. |

## Explicit Exclusions

- RP-03 SQL/schema/transitions/`runtime_bus`; RP-05 effect primitive;
  RP-06 predicate/verdict; RP-07 signing/head/reserve are not RP-08 targets.
- `.github/**`, production provider targets, trust-root activation, proposal
  registry, and raw generated status are not promotion targets.
