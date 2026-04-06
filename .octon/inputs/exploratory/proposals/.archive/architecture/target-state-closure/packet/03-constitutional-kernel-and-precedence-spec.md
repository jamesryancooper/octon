# 03. Constitutional Kernel and Precedence Spec

## 1. Goal

Make the constitutional kernel singular, supreme, and closure-bearing by construction.

## 2. Preserve the current kernel

Preserve the following as the authored constitutional roots:

- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/framework/constitution/claim-truth-conditions.yml`
- `.octon/framework/constitution/support-targets.schema.json`

Preserve the following as authored release-governance inputs:

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/disclosure/release-lineage.yml`
- `.octon/instance/governance/exclusions/**/*.yml`
- `.octon/instance/governance/policies/**/*.yml`

## 3. Re-bound all claim-bearing surfaces

### 3.1 Canonical live claim-bearing outputs

Canonical live closure outputs move to:

- `.octon/state/evidence/disclosure/releases/<release-id>/harness-card.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/gate-status.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/closure-summary.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/closure-certificate.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/support-universe-coverage.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/proof-plane-coverage.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/cross-artifact-consistency.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/claim-drift-report.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/projection-parity-report.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/manifest.yml`

These are the only live claim-bearing closure artifacts.

### 3.2 Stable projection mirrors

The following convenience paths may remain, but only as generated mirrors of the active release bundle:

- `.octon/instance/governance/disclosure/harness-card.yml`
- `.octon/instance/governance/closure/unified-execution-constitution-status.yml`
- `.octon/instance/governance/closure/preclaim-blockers.yml`
- `.octon/instance/governance/closure/gate-status.yml`
- `.octon/instance/governance/closure/closure-summary.yml`

Rule:
- no human may directly author these after cutover
- CI fails on any diff that cannot be reproduced from the active release bundle

## 4. New constitutional disclosure contract family

Create:

- `.octon/framework/constitution/contracts/disclosure/closure-certificate-v1.schema.json`
- `.octon/framework/constitution/contracts/disclosure/closure-gate-report-v1.schema.json`
- `.octon/framework/constitution/contracts/disclosure/release-bundle-manifest-v1.schema.json`
- `.octon/framework/constitution/contracts/disclosure/projection-parity-report-v1.schema.json`
- `.octon/framework/constitution/contracts/disclosure/claim-drift-report-v1.schema.json`

## 5. Precedence model

### 5.1 Normative authority precedence

1. non-waivable external obligations and emergency revocations
2. constitutional kernel
3. instance governance declarations
4. active release-lineage pointer
5. active release bundle outputs
6. generated projection mirrors
7. informative docs, summaries, and commentary

### 5.2 Epistemic grounding precedence

1. live control roots
2. retained evidence roots
3. active release bundle
4. freshness-valid generated effective projections
5. authored narrative docs

If a generated mirror differs from the active release bundle, the bundle wins and CI fails.

If a release bundle differs from retained evidence or control truth, closure generation fails.

## 6. Generators

Add or normalize these generators under `.octon/framework/assurance/runtime/_ops/scripts/`:

- `generate-release-bundle.sh`
- `generate-harness-card.sh`
- `generate-closure-bundle.sh`
- `generate-closure-projections.sh`
- `generate-claim-drift-report.sh`
- `generate-proof-plane-coverage-report.sh`
- `generate-cross-artifact-consistency-report.sh`

## 7. Validators

Add:

- `validate-claim-surface-generated-only.sh`
- `validate-projection-byte-parity.sh`
- `validate-release-bundle-freshness.sh`
- `validate-disclosure-wording-coherence.sh`
- `validate-claim-truth-boundary.sh`

## 8. Migration

1. Add the disclosure contract family.
2. Introduce shadow release bundle generation.
3. Generate projection mirrors from candidate bundles.
4. Fail CI if mirrors drift from the active release bundle.
5. Move active claim-bearing truth to the release bundle at cutover.
6. Keep instance-path mirrors for one compatibility window, then evaluate whether they still earn their keep.

## 9. Acceptance criteria

- there is exactly one canonical live source for closure truth: the active release bundle
- all instance closure/disclosure convenience paths are generated mirrors only
- no authored change to a live claim-bearing mirror can merge
- release-lineage supersession is reflected everywhere active
- every active closure artifact is reproducible from authored constitutional inputs plus validators and retained evidence
