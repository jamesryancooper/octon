# Implementation Plan

## Program posture

Use a **hybrid bounded cutover**. The constitutional invariants stay live. New validators, registry consolidation, evidence-store contracts, promotion receipts, and operator views are introduced in staged gates. Runtime enforcement changes cut over only when coverage and negative tests pass.

## Workstream 1 — Registry consolidation

Dependencies: none.

Steps:

1. Audit all active topology/source-of-truth statements.
2. Expand `framework/cognition/_meta/architecture/contract-registry.yml` to include path families, authority class, allowed consumers, forbidden consumers, validators, publication rules, and doc-generation targets.
3. Add `validate-architecture-contract-registry.sh`.
4. Generate or registry-check `.octon/README.md`, `specification.md`, `START.md`, and ingress summaries.
5. Move historical wave/cutover narrative to decision records.

Stabilization gate: registry validator passes and active docs contain no hand-maintained contradictory path matrices.

Evidence: `state/evidence/validation/architecture/10of10-remediation/registry-consolidation/`.

## Workstream 2 — Authorization-boundary coverage

Dependencies: registry identifies material execution path families.

Steps:

1. Create side-effect path inventory.
2. Define `authorization-boundary-coverage-v1.md`.
3. Add static scan for side-effect-capable calls and required `authorize_execution` binding.
4. Add negative bypass tests for service, workflow, executor launch, repo mutation, publication, protected CI, adapter projection, egress, and model-backed execution.
5. Gate protected execution and deny-by-default workflows on coverage report.

Stabilization gate: no material path lacks coverage, and all bypass fixtures fail closed.

Evidence: coverage matrix, negative test receipts, grant/denial fixture results.

## Workstream 3 — Authority engine decomposition

Dependencies: authorization coverage inventory.

Steps:

1. Identify stable modules.
2. Extract pure validation/decision submodules first.
3. Preserve public API: `authorize_execution`, `finalize_execution`, receipt helpers.
4. Convert monolithic implementation to a thin facade.
5. Add fixture-driven unit tests per module.
6. Add code-size/auditability budget for authority modules.

Stabilization gate: existing runtime tests pass; new fixture tests cover allow/stage/deny/escalate outcomes.

Evidence: module map, test coverage report, reviewer signoff.

## Workstream 4 — Evidence durability and completeness

Dependencies: run lifecycle draft.

Steps:

1. Create evidence-store schema and runtime spec.
2. Define evidence classes, retention classes, hash/index format, and transport-vs-retained distinction.
3. Add `validate-evidence-completeness.sh`.
4. Make run closeout fail when required evidence is missing.
5. Generate RunCards, HarnessCards, replay bundles, denial bundles, and disclosure bundles from retained evidence only.

Stabilization gate: sample consequential run can close only after evidence completeness passes.

Evidence: evidence-store conformance bundle.

## Workstream 5 — Promotion semantics hardening

Dependencies: registry and evidence-store root.

Steps:

1. Create promotion receipt schema and repo policy.
2. Inventory current promotion/publication paths.
3. Require receipts for `inputs/**` or `generated/**` moving into `framework/**`, `instance/**`, `state/control/**`, or runtime-facing `generated/effective/**`.
4. Replace direct project-finding publication language with promotion workflow.
5. Add validator.

Stabilization gate: no quiet authority creation paths remain.

Evidence: promotion receipt ledger and validator report.

## Workstream 6 — Run lifecycle state machine

Dependencies: authorization/evidence contracts.

Steps:

1. Define `run-lifecycle-v1.md`.
2. Bind each state transition to authority, evidence, rollback, support, and operator visibility requirements.
3. Implement transition validation in runtime.
4. Update CLI inspect/replay/disclose/close behavior.
5. Add fixtures for denied, staged, paused, revoked, failed, rolled_back, and closed paths.

Stabilization gate: invalid transitions fail closed; closeout requires evidence completeness.

Evidence: lifecycle fixture report.

## Workstream 7 — Support-target proofing

Dependencies: evidence-store and validation.

Steps:

1. Define proof bundle schema.
2. Add `support-target-proofing.yml`.
3. Require proof bundle for each admitted tuple.
4. Validate live and denied scenarios.
5. Regenerate support-target matrix from admissions and proof dossiers.

Stabilization gate: support claims fail if proof bundle is missing or stale.

Evidence: per-tuple support proof card.

## Workstream 8 — Operator-grade read models

Dependencies: run lifecycle, evidence-store, support proofing.

Steps:

1. Define `operator-read-models-v1.md`.
2. Generate mission, run, grant, support, evidence, and closeout views.
3. Add traceability metadata to every generated field.
4. Add consistency validator.
5. Update CLI/TUI/Studio surfaces to consume read models as projections only.

Stabilization gate: operator views are complete, traceable, and non-authoritative.

Evidence: read-model consistency receipts.

## Completion conditions

The remediation program completes when all workstreams pass validators, evidence is retained, decision records are created, generated read models are traceable, and closure certification records the architecture as target-state-grade.
