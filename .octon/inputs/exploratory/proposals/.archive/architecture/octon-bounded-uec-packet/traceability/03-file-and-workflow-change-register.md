# File and Workflow Change Register

## 1. Immediate edits or additions required

| Path | Change type | Purpose | Dependency |
|---|---|---|---|
| `/.octon/instance/governance/disclosure/release-lineage.yml` | Edit | activate recertification-open release and supersede over-strong complete release | none |
| `/.octon/instance/governance/closure/unified-execution-constitution.yml` | Edit | downgrade active claim state until recertification closes | release-lineage update |
| `/.octon/instance/governance/disclosure/harness-card.yml` | Edit | align public wording with recertification-open state | closure state edit |
| `/.octon/generated/effective/closure/claim-status.yml` | Edit/regenerate | keep effective projections aligned with authored claim state | release-lineage update |
| `/.octon/state/evidence/disclosure/releases/2026-04-11-uec-bounded-recertification-open/**` | Add | provisional active release bundle | release-lineage update |
| `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json` | Add | harden instruction-layer manifests | runtime/evidence stage |
| `/.octon/framework/constitution/contracts/retention/run-evidence-classification-v2.schema.json` | Add | harden evidence classification | runtime/evidence stage |
| `/.octon/framework/constitution/contracts/disclosure/claim-bearing-run-bundle-v1.schema.json` | Add | bind run-level disclosure completeness | runtime/evidence stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-run-authority-ledger-coherence.sh` | Add | detect authority mismatches | authority stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-live-authority-no-exercise-residue.sh` | Add | reject claim-bearing exercise residue | authority stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifests.sh` | Add | reject skeletal manifests | runtime/evidence stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-classification.sh` | Add | reject empty evidence classifications | runtime/evidence stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-host-projection-purity.sh` | Add | prove host non-authority | workflow stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-authority-derivation.sh` | Add | ensure workflows derive from canonical artifacts | workflow stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-proof-plane-coverage.sh` | Add | gate six-plane coverage | proof stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-agency-overlay-containment.sh` | Add | prove overlay containment | agency stage |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-build-to-delete-evidence.sh` | Add | operationalize retirement reviews | retirement stage |

## 2. Named blocker artifacts — required resolution

| Path | Resolution class | Recommended action |
|---|---|---|
| `state/control/execution/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/run-contract.yml` | Re-bound or supersede | preserve as historical/non-claim-bearing if contaminated chain remains; otherwise normalize coherently |
| `state/control/execution/approvals/requests/uec-bounded-repo-shell-boundary-sensitive-20260409.yml` | Re-bound or supersede | remove from active claim-bearing set or normalize support tier / target id / reason codes |
| `state/control/execution/exceptions/leases/lease-uec-bounded-repo-shell-boundary-sensitive-20260409.yml` | Re-bound or supersede | preserve as exercise lineage or replace with fresh clean lease |
| `state/control/execution/revocations/revoke-uec-bounded-repo-shell-boundary-sensitive-20260409.yml` | Re-bound or supersede | preserve as exercise lineage or replace with fresh clean revocation |
| `state/evidence/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/instruction-layer-manifest.json` | Backfill or supersede | if run stays claim-bearing, upgrade to v2; otherwise remove from active exemplar set |
| `state/evidence/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/evidence-classification.yml` | Backfill or supersede | if run stays claim-bearing, populate non-empty artifact map; otherwise remove from active exemplar set |

## 3. Workflow files to harden

- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/closure-certification.yml`
- `.github/workflows/closure-validator-sufficiency.yml`
- `.github/workflows/uec-cutover-validate.yml`
- `.github/workflows/uec-cutover-certify.yml`
- `.github/workflows/unified-execution-constitution-closure.yml`
- `.github/workflows/agency-validate.yml`
- `.github/workflows/architecture-conformance.yml`
- `.github/workflows/uec-drift-watch.yml`

## 4. Disclosure outputs to add per release candidate

- `closure/authority-ledger-coherence-report.yml`
- `closure/no-exercise-residue-report.yml`
- `closure/instruction-manifest-completeness-report.yml`
- `closure/evidence-classification-completeness-report.yml`
- `closure/claim-calibration-report.yml`
- `closure/host-projection-purity-report.yml`
- `closure/workflow-authority-derivation-report.yml`
- `closure/proof-plane-coverage.yml`
- `closure/recovery-drill-report.yml`
- `closure/support-target-coverage-report.yml`
- `closure/build-to-delete-report.yml`
- `closure/agency-overlay-containment-report.yml`
- `closure/dual-pass-diff-report.yml`
