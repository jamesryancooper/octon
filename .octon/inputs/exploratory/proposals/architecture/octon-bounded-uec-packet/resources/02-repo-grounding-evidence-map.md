# Repo Grounding Evidence Map

This file maps the core repo surfaces used by the proposal packet.

## 1. Claim-bearing closure surfaces

- `/.octon/instance/governance/disclosure/release-lineage.yml`
  - active release
  - active claim scope
  - active claim status
  - supersession history

- `/.octon/framework/constitution/claim-truth-conditions.yml`
  - truth conditions TC-01..TC-10
  - invalidators for claim overstatement

- `/.octon/instance/governance/closure/unified-execution-constitution.yml`
  - current closure declaration
  - current complete claim statement
  - final support universe summary

- `/.octon/instance/governance/disclosure/harness-card.yml`
  - release claim summary
  - release disclosure rollup

## 2. Constitutional kernel and canonicality surfaces

- `/.octon/framework/constitution/contracts/registry.yml`
  - active kernel surfaces
  - family activations
  - shim surface classifications
  - active integration surfaces

- `/.octon/instance/charter/README.md`
  - canonical workspace charter pair
  - historical lineage shims declared non-runtime

- `/.octon/instance/orchestration/missions/README.md`
  - mission remains continuity container, not atomic execution unit

## 3. Live authority family surfaces

- `/.octon/state/control/execution/approvals/README.md`
- `/.octon/state/control/execution/exceptions/README.md`
- `/.octon/state/control/execution/revocations/README.md`

These define approvals / exceptions / revocations as canonical live control roots and explicitly demote host labels/comments/checks as non-authoritative references.

## 4. Run and evidence surfaces

- `/.octon/state/control/execution/runs/**`
- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/disclosure/runs/**`
- `/.octon/state/evidence/disclosure/releases/**`

Particularly important:

- run contract / run manifest / runtime state
- instruction-layer manifests
- evidence classification
- RunCards and release HarnessCards

## 5. Lab and observability surfaces

- `/.octon/framework/lab/README.md`
  - authored lab surface for behavioral proof, replay, shadow, faults, adversarial discovery

- `/.octon/framework/observability/README.md`
  - measurement, intervention accounting, failure taxonomy, report-bundle conventions

## 6. Support-target and adapter surfaces

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**`
- `/.octon/generated/effective/governance/support-target-matrix.yml`
- `/.octon/framework/engine/runtime/adapters/host/**`
- `/.octon/framework/engine/runtime/adapters/model/**`
- `/.octon/framework/capabilities/packs/**`

## 7. Workflow surfaces

Key workflow files under `/.github/workflows/**`:

- `pr-autonomy-policy.yml`
- `ai-review-gate.yml`
- `closure-certification.yml`
- `closure-validator-sufficiency.yml`
- `uec-cutover-validate.yml`
- `uec-cutover-certify.yml`
- `uec-drift-watch.yml`
- `unified-execution-constitution-closure.yml`
- `validate-unified-execution-completion.yml`
- `agency-validate.yml`
- `architecture-conformance.yml`

## 8. Audit crosswalk and retirement surfaces

- `/.octon/instance/governance/closure/current-audit-crosswalk.yml`
- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/state/evidence/validation/publication/build-to-delete/**`
