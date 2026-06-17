# Executable Implementation Prompt

implementation_prompt_id: octon-instruction-layer-execution-envelope-hardening-implementation-prompt-20260617T133003Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-17T13:30:03Z

This prompt is an operational implementation aid for the accepted proposal packet. It does not approve execution, widen scope, create authority, replace run contracts, replace proposal manifests, or substitute for retained evidence.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening --require-implementation-authorization
```

Expected result before implementation: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: additive same-root hardening of instruction-layer provenance and capability-envelope normalization
- transitional exception: not authorized

## Mandatory Preflight

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
```

Refuse implementation if any change requires support-target widening, a new execution protocol, a new control/evidence root, generated authority, or a proposal-path runtime dependency.

## In Scope

Durable edits may touch only:

- `.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `.octon/instance/execution-roles/runtime/tool-output-budgets.yml`
- `.octon/framework/engine/runtime/spec/execution-request-v2.schema.json`
- `.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- `.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json`
- `.octon/instance/governance/policies/repo-shell-execution-classes.yml`
- `.octon/framework/capabilities/packs/shell/manifest.yml`
- `.octon/framework/capabilities/packs/repo/manifest.yml`
- `.octon/instance/governance/capability-packs/shell.yml`
- `.octon/instance/capabilities/runtime/packs/admissions/shell.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifest-depth.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-instruction-layer-manifest-depth.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-capability-envelope-normalization.sh`
- `.octon/generated/effective/capabilities/pack-routes.effective.yml`
- `.octon/generated/effective/capabilities/pack-routes.lock.yml`
- `.octon/generated/effective/runtime/route-bundle.yml`
- `.octon/generated/effective/runtime/route-bundle.lock.yml`
- `.octon/generated/effective/governance/support-envelope-reconciliation.yml`
- `.octon/generated/cognition/projections/materialized/runs`
- `.octon/state/evidence/validation/publication/capabilities`
- `.octon/state/evidence/validation/publication/runtime`
- `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health`
- `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/support-envelope`

Expected durable work:

1. Add instruction-layer manifest fields for capability pack refs, execution class refs, tool budget policy refs, context layer provenance, and compaction references without removing existing v2 fields.
2. Add request/grant/receipt fields for requested pack ids, execution class id, output-envelope policy ref, and raw payload refs.
3. Align repo-shell execution classes, shell/repo capability packs, shell governance, and shell runtime admission with normalized class, pack, receipt, and envelope evidence expectations.
4. Add packet-specific validators and tests that prove enriched manifest completeness and request/grant/receipt/class/pack/envelope coherence.
5. Refresh generated effective/read-model outputs only through owning scripts:
   - `generate-pack-routes.sh`
   - `generate-runtime-effective-route-bundle.sh`
   - `generate-support-envelope-reconciliation.sh`
   - `generate-run-health-read-model.sh --all-runs`
6. Do not edit `.github/workflows/architecture-conformance.yml` or the architecture-conformance runner in this implementation; neither is an accepted promotion target in `proposal.yml`. Treat workflow wiring as a follow-up unless the proposal manifest is explicitly revised through lifecycle review.

## Out Of Scope

Do not edit support-target declarations, governance exclusions, generated outputs by hand, new control roots, new evidence roots, authority-engine grant internals, connector effect handling, mission dispatch, or proposal lifecycle promotion. Do not change `proposal.yml#status` during implementation.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/octon-instruction-layer-execution-envelope-hardening/<timestamp>/
.octon/state/evidence/validation/publication/capabilities/
.octon/state/evidence/validation/publication/runtime/
.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health/
.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/support-envelope/
```

Retain:

- profile selection receipt;
- repository reconnaissance receipt;
- validator output for both packet-specific validators and both packet-specific tests;
- retained enriched instruction-layer manifest fixture;
- retained request/grant/receipt coherence fixture or fixture reference;
- support-target non-widening statement;
- rollback posture and minimality/anti-bloat receipt.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/SHA256SUMS.txt`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-instruction-layer-manifest-depth.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-capability-envelope-normalization.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifest-depth.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
```

## Rollback And Closeout Refusal

Rollback is a single revert of the schema, policy, pack, validator, test, generated-refresh, and proposal support changes from this packet, with generated outputs refreshed only by owning scripts. Refuse closeout or archive if support-targets were widened, if raw inputs or generated outputs became authority, if the new validators are absent or do not fail closed under their packet-specific tests, if retained fixtures do not prove enriched manifest and request/grant/receipt coherence, or if `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` do not pass.
