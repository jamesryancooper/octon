# 07. Disclosure, Claim Calibration, and Certification Spec

## 1. Goal

Make every claim-bearing surface a generated consequence of canonical control/evidence roots and validator outputs, not a prose assertion.

## 2. Disclosure hierarchy

### Run-level disclosure
Canonical:
- `.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml`

Optional projections:
- rendered markdown or HTML in `generated/reports/runs/<run-id>.*`

### Release-level disclosure
Canonical:
- `.octon/state/evidence/disclosure/releases/<release-id>/harness-card.yml`
- `.octon/state/evidence/disclosure/releases/<release-id>/closure/**`

Stable mirrors:
- `.octon/instance/governance/disclosure/harness-card.yml`
- `.octon/instance/governance/closure/*.yml` (generated only)

### Authored release governance
Authored:
- `.octon/instance/governance/disclosure/release-lineage.yml`

Rule:
- lineage is authored
- cards and closure statuses are generated

## 3. RunCard policy

RunCard must be generated from:
- Run Contract
- Run Manifest
- DecisionArtifact
- Grant bundle
- support-target matrix
- retained-run-evidence summary
- measurement summary
- intervention log
- assurance reports

RunCard fields must never be manually widened beyond what the source artifacts support.

## 4. HarnessCard policy

HarnessCard must be generated from:
- constitutional charter/version
- support-target matrix
- adapter inventories
- closure bundle coverage reports
- known limits declared by release-lineage and exclusion policy

The instance-level `harness-card.yml` path becomes a generated active-release mirror only.

## 5. Closure bundle

Canonical release closure bundle contents:

- `manifest.yml`
- `gate-status.yml`
- `closure-summary.yml`
- `closure-certificate.yml`
- `support-universe-coverage.yml`
- `proof-plane-coverage.yml`
- `cross-artifact-consistency.yml`
- `claim-drift-report.yml`
- `projection-parity-report.yml`

## 6. Claim-truth conditions

Preserve authored:
- `.octon/framework/constitution/claim-truth-conditions.yml`

But change how it is used:
- validators evaluate truth conditions from canonical run/control/evidence roots
- gate-status is generated from validator outputs
- manual green-check editing is prohibited

## 7. Wording coherence

Forbidden in any active claim-bearing artifact once superseded:
- “global complete”
- “globally complete support universe”
- any broader support description than the active release-lineage and support-target matrix allow

Create validator:
- `validate-disclosure-wording-coherence.sh`

This validator scans:
- active RunCards
- active HarnessCard
- active measurement summaries
- closure summaries
- support coverage reports
- any stable mirror paths

## 8. Release-bundle freshness

Every release bundle needs a manifest that records:
- authored input digests
- validator versions
- generation timestamps
- generator versions
- replay bundle refs
- support-target version refs

Create validator:
- `validate-release-bundle-freshness.sh`

The release bundle is stale if:
- any authored input digest changed
- any canonical validator changed
- any active proof-bundle exemplar run changed
- support-target matrix changed
- release-lineage points to the bundle but freshness validation fails

## 9. Cross-artifact consistency

Create:
- `validate-cross-artifact-support-tuple-consistency.sh`
- `validate-cross-artifact-capability-pack-consistency.sh`
- `validate-cross-artifact-route-consistency.sh`

These compare at minimum:
- Run Contract
- Run Manifest
- DecisionArtifact
- Approval/Grant bundle
- RunCard
- support-target matrix
- host adapter contract
- model adapter contract

Required matching fields:
- support target ref / tuple
- requested capability packs
- host adapter id and status
- model adapter id and status
- route
- support status
- requires_mission
- reversibility class

## 10. Projection parity

Create validator:
- `validate-projection-byte-parity.sh`

Rule:
- stable mirrors under `instance/governance/disclosure/**` and `instance/governance/closure/**` must be byte-equal to their active release bundle source artifacts

## 11. Certification-oriented disclosure rules

A release may become active only if:
- closure bundle is generated
- wording coherence passes
- cross-artifact consistency passes
- projection parity passes
- freshness passes
- all truth-condition invalidators are false
- final certificate is written

## 12. Migration

1. add disclosure contract family
2. introduce release-bundle generators
3. generate candidate bundles in shadow roots
4. compare candidate bundle to active mirrors
5. cut active_release pointer only after two-pass identical outcome
6. keep mirror paths for compatibility but delete authorability permanently

## 13. Acceptance criteria

- active RunCard / HarnessCard / closure surfaces are all generated
- no green status is possible while contradicted by retained evidence
- no superseded wording survives in active claim-bearing artifacts
- release-lineage supersession is reflected everywhere active
- certification surfaces can be regenerated from source inputs exactly
