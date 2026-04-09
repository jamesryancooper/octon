# Path-Specific Execution Program

This document is path-specific and implementation-oriented. It is not a new architecture proposal.

## 1. Paths to preserve unchanged

- `/.octon/framework/constitution/**`
- `/.octon/octon.yml`
- `/.octon/README.md`
- `/.octon/instance/charter/**`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/execution/{approvals,exceptions,revocations}/**`
- `/.octon/state/evidence/control/execution/**`
- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/disclosure/**`
- `/.octon/framework/lab/**`
- `/.octon/framework/observability/**`
- `/.octon/framework/engine/runtime/adapters/{host,model}/**`
- `/.octon/framework/capabilities/packs/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**`

## 2. New authored files to add (minimal-change, inside existing roots)

### 2.1 Lab integrity
- `/.octon/state/evidence/lab/index/by-scenario.yml`

### 2.2 Assurance / validation
- `/.octon/framework/assurance/behavioral/suites/lab-reference-integrity.yml`
- `/.octon/framework/assurance/recovery/suites/lab-replay-shadow-fault-integrity.yml`
- `/.octon/framework/assurance/governance/suites/support-dossier-admission-parity.yml`
- `/.octon/framework/assurance/governance/suites/host-authority-purity.yml`
- `/.octon/framework/assurance/governance/suites/host-projection-parity.yml`
- `/.octon/framework/assurance/governance/suites/authority-lineage-completeness.yml`
- `/.octon/framework/assurance/runtime/suites/runtime-family-depth.yml`
- `/.octon/framework/assurance/runtime/suites/continuity-linkage.yml`
- `/.octon/framework/assurance/runtime/suites/contamination-retry-depth.yml`

### 2.3 Validator scripts
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-lab-reference-integrity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-support-dossier-parity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-host-authority-purity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-host-adapter-projection-parity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-runtime-family-depth.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-continuity-linkage.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-release-known-limits.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-retirement-rationale.sh`

### 2.4 Release-local closeout artifacts (next release only)
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/residual-ledger.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/host-authority-purity-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/lab-reference-integrity-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/runtime-family-depth-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/continuity-linkage-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/contamination-retry-depth-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/support-universe-evidence-depth-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/retirement-rationale-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/ablation-review-report.yml`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/disclosure-calibration-report.yml`

## 3. Existing files to update

### 3.1 Workflow updates
- `/.github/workflows/pr-autonomy-policy.yml`
- `/.github/workflows/validate-unified-execution-completion.yml`
- `/.github/workflows/closure-validator-sufficiency.yml`
- `/.github/workflows/closure-certification.yml`
- `/.github/workflows/uec-drift-watch.yml`
- optionally `/.github/workflows/architecture-conformance.yml`

### 3.2 Lab registry update
- `/.octon/framework/lab/scenarios/registry.yml`

### 3.3 Dossier / admission updates
- `/.octon/instance/governance/support-dossiers/**/dossier.yml`
- optionally `/.octon/instance/governance/support-target-admissions/**.yml` where admission files should carry explicit scenario references or parity hints

### 3.4 Disclosure updates
- `/.octon/instance/governance/disclosure/HarnessCard.yml` (or equivalent authored source)
- `/.octon/instance/governance/disclosure/release-lineage.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/generated/effective/closure/recertification-status.yml`
- `/.octon/generated/effective/governance/support-target-matrix.yml` if parity generation depends on new residual ledger / hardening reports

### 3.5 Retirement / closeout updates
- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/instance/governance/contracts/support-target-review.yml`
- any existing closeout / release-review contract family under `/.octon/instance/governance/contracts/**`

### 3.6 Ingress / agency simplification updates
- `/.octon/AGENTS.md`
- `/AGENTS.md`
- `/CLAUDE.md`
- `/.octon/instance/ingress/AGENTS.md`
- retained identity/persona surfaces under `/.octon/framework/agency/**`

## 4. Minimal-change rules

1. Do not add new top-level domains.
2. Do not move canonical control families.
3. Do not create a new control plane.
4. Prefer validators, manifests, indices, and release receipts inside existing roots.
5. Only tighten schemas after current exemplars and fixtures have been backfilled.

## 5. Path-specific acceptance outcomes

- `framework/lab/scenarios/registry.yml` is updated and consumed by dossier/proof integrity validators.
- `state/evidence/lab/index/by-scenario.yml` exists and is consumed by closure/reporting validators.
- Workflow suite cannot pass if a host-native authority path is detected.
- Every admitted run class has deterministic runtime-family depth validation.
- HarnessCard `known_limits` is generated from or checked against the residual ledger.
- Release-lineage only rolls to a new active release when all claim-critical reports are green.
