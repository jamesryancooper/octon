# Path-Specific Remediation Specifications

This file translates the closure-hardening program into exact repo paths, change types, and acceptance criteria.

## 1. Claim-governance and release-state paths

### 1.1 New active recertification release (recommended)

**Add:**

- `/.octon/state/evidence/disclosure/releases/2026-04-11-uec-bounded-recertification-open/manifest.yml`
- `/.octon/state/evidence/disclosure/releases/2026-04-11-uec-bounded-recertification-open/harness-card.yml`
- `/.octon/state/evidence/disclosure/releases/2026-04-11-uec-bounded-recertification-open/closure/provisional-certificate.yml`
- `/.octon/state/evidence/disclosure/releases/2026-04-11-uec-bounded-recertification-open/closure/blocker-register.yml`
- `/.octon/state/evidence/disclosure/releases/2026-04-11-uec-bounded-recertification-open/closure/traceability-matrix.yml`

**Edit:**

- `/.octon/instance/governance/disclosure/release-lineage.yml`
- `/.octon/instance/governance/closure/unified-execution-constitution.yml`
- `/.octon/instance/governance/closure/unified-execution-constitution-status.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/generated/effective/closure/recertification-status.yml`

**Required change:**

- active release becomes the recertification-open release
- public claim wording changes from `complete` to `recertification_open`
- the 2026-04-09 closure release is preserved but superseded as an over-strong claim state

**Acceptance:**

- exactly one active release remains
- no file says `claim_status: complete` for the active release until recertification succeeds
- generated/effective closure projections match authored lineage

## 2. Sampled blocker run handling

### 2.1 Claim-bearing quarantine or supersession

**Named blocker paths:**

- `/.octon/state/control/execution/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/run-contract.yml`
- `/.octon/state/control/execution/approvals/requests/uec-bounded-repo-shell-boundary-sensitive-20260409.yml`
- `/.octon/state/control/execution/exceptions/leases/lease-uec-bounded-repo-shell-boundary-sensitive-20260409.yml`
- `/.octon/state/control/execution/revocations/revoke-uec-bounded-repo-shell-boundary-sensitive-20260409.yml`
- `/.octon/state/evidence/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/instruction-layer-manifest.json`
- `/.octon/state/evidence/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/evidence-classification.yml`

**Recommended action:**

- do not silently rewrite these into a “clean” exemplar
- mark them non-claim-bearing for the active recertification program, or supersede them via a fresh clean run

**If superseding with a fresh run, add:**

- `/.octon/state/control/execution/runs/<new-run-id>/**`
- `/.octon/state/evidence/runs/<new-run-id>/**`
- `/.octon/state/evidence/disclosure/runs/<new-run-id>/run-card.yml`
- `/.octon/state/evidence/disclosure/runs/<new-run-id>/manifest.yml`

**Acceptance:**

- no active complete or recertification-complete release cites the contaminated 2026-04-09 boundary-sensitive run as the active exemplar
- a fresh clean claim-bearing exemplar exists before the final complete claim is reissued

### 2.2 If in-place normalization is chosen instead of supersession

Only acceptable if provenance policy explicitly allows it.

**Edit required:**

- approval request: align `support_tier`, target semantics, reason codes, ownership, and reversibility with the run contract
- exception lease: remove `governance/exercise`, `example.invalid`, `safe-stage`, and exercise-specific wording from any claim-bearing lease
- revocation: remove exercise-only notes from any claim-bearing revocation

**Acceptance:**

- authority family and run contract are coherent under validator
- no exercise-only residue remains in claim-bearing artifacts

## 3. Instruction-layer manifest and evidence classification

### 3.1 New contracts / schemas

**Add:**

- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/constitution/contracts/retention/run-evidence-classification-v2.schema.json`

### 3.2 New required fields

**For instruction-layer-manifest-v2:**

- `run_id`
- `mission_id` or `run_mode`
- `workspace_charter_refs[]`
- `mission_refs[]`
- `run_contract_ref`
- `support_target_tuple_id`
- `authority_refs[]`
- `precedence_stack[]`
- `adapter_projection_refs[]`
- `generated_at`
- `source_digests[]`

**For run-evidence-classification-v2:**

- `artifacts[]` non-empty
- each artifact has `artifact_id`, `path_or_pointer`, `evidence_class`, `required_for_claim`, `proof_planes[]`, `retention_policy`, `digest_or_locator`

### 3.3 Validators

**Add:**

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifests.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-classification.sh`

**Acceptance:**

- any claim-bearing run with skeletal artifacts fails CI and closure certification

## 4. Run disclosure and release disclosure coupling

### 4.1 New run-bundle manifest

**Add:**

- `/.octon/framework/constitution/contracts/disclosure/claim-bearing-run-bundle-v1.schema.json`
- `/.octon/state/evidence/disclosure/runs/<run-id>/manifest.yml`

### 4.2 Release closure outputs

**Add outputs per release:**

- `closure/claim-calibration-report.yml`
- `closure/run-disclosure-parity-report.yml`
- `closure/release-bundle-integrity-report.yml`

**Acceptance:**

- HarnessCard and release closure bundle aggregate only from validated run bundle manifests

## 5. Host adapter and workflow proof

### 5.1 Existing paths to modify

- `/.octon/framework/engine/runtime/adapters/host/github-control-plane.yml`
- `/.github/workflows/pr-autonomy-policy.yml`
- `/.github/workflows/ai-review-gate.yml`
- `/.github/workflows/closure-certification.yml`
- `/.github/workflows/uec-cutover-validate.yml`
- `/.github/workflows/uec-cutover-certify.yml`
- `/.github/workflows/unified-execution-constitution-closure.yml`

### 5.2 New validators

**Add:**

- `validate-host-projection-purity.sh`
- `validate-workflow-authority-derivation.sh`
- `validate-host-canonical-parity.sh`

**Required rules:**

- workflows may read canonical approval/exception/revocation artifacts
- workflows may publish derived checks / labels / comments
- workflows may not treat host state as sufficient authority
- workflow env may not repair missing canonical authority artifacts

## 6. Support-target hardening

### 6.1 Existing governed paths

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**`
- `/.octon/framework/engine/runtime/adapters/host/**`
- `/.octon/framework/engine/runtime/adapters/model/**`
- `/.octon/framework/capabilities/packs/**`
- `/.octon/generated/effective/governance/support-target-matrix.yml`

### 6.2 Required additions

For every admitted tuple lacking closure-grade backing, add or refresh:

- dossier evidence
- capability-pack coverage statement
- exemplar run coverage
- disclosure row in the active HarnessCard
- proof-plane references

### 6.3 New validators

**Add:**

- `validate-support-target-coverage.sh`
- `validate-support-dossier-evidence-depth.sh` (extend if already present)
- `validate-harness-card-support-row-parity.sh`

## 7. Agency simplification and overlays

### 7.1 Paths to audit and possibly edit

- `/.octon/framework/agency/**`
- `/.octon/instance/ingress/**`
- `/.octon/AGENTS.md`
- `/AGENTS.md`
- `/CLAUDE.md`
- `/.octon/instance/governance/non-authority-register.yml`

### 7.2 Add validators

- `validate-agency-overlay-containment.sh`
- `validate-non-authority-register-completeness.sh`

### 7.3 Acceptance

- every surviving overlay or shim is declared and non-authoritative
- no persona / overlay surface outside allowed roots can affect runtime governance

## 8. Retirement / build-to-delete operationalization

### 8.1 Paths

- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/state/evidence/validation/publication/build-to-delete/**`
- `/.octon/instance/governance/closure/recertification-trigger-log.yml`

### 8.2 Add outputs

- `closure/retirement-review-report.yml`
- `closure/build-to-delete-report.yml`
- `closure/shim-retention-rationale-report.yml`

### 8.3 Acceptance

- all material retirement triggers have review evidence
- stale shims are either justified, queued, or deleted
