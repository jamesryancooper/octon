# Artifact Regeneration Map

This appendix defines which canonical artifacts generate which downstream outputs.

## 1. Authored constitutional inputs

### Inputs
- `framework/constitution/**`
- `instance/governance/support-targets.yml`
- `instance/governance/disclosure/release-lineage.yml`
- `instance/charter/workspace.{md,yml}`
- `instance/orchestration/missions/**`
- instance governance policies and contracts

### Generated outputs
- `generated/effective/**`
- active release HarnessCard
- closure bundle policy digests
- support-universe coverage report

## 2. Run/control inputs

### Inputs
- `state/control/execution/runs/<run-id>/run-contract.yml`
- `run-manifest.yml`
- approvals / grants / leases / revocations
- checkpoints / runtime-state
- continuity artifacts

### Generated outputs
- authority summary
- runtime route summary
- replay manifest
- run-level disclosure summary
- cross-artifact consistency report

## 3. Evidence inputs

### Inputs
- retained-run-evidence
- evidence classification
- measurements records
- intervention records
- assurance reports
- replay/external indexes

### Generated outputs
- measurement summary
- intervention log/summary
- RunCard
- proof-plane coverage report
- closure summary contributions

## 4. Release bundle generation

### Inputs
- active release-lineage pointer
- support-target matrix and dossiers
- selected proof-bundle exemplar runs
- generated RunCards
- generated measurement and intervention summaries
- validator results

### Outputs
- release bundle manifest
- HarnessCard
- closure summary
- closure certificate
- projection parity report
- support-universe coverage
- cross-artifact consistency report
- claim drift report

## 5. Stable mirrors

### Inputs
- active release bundle only

### Outputs
- `instance/governance/disclosure/harness-card.yml`
- `instance/governance/closure/*.yml`

### Rule
No stable mirror may be generated from any source other than the active release bundle.

## 6. Regeneration triggers

Regenerate when:
- any authored constitutional input changes
- support-target matrix or dossier changes
- any active proof-bundle exemplar run changes
- any validator changes
- release-lineage changes
- any active adapter contract changes
- any claim wording policy changes

## 7. Validation chain

1. authored inputs validate
2. run/control bundle validates
3. evidence validates
4. release bundle generates
5. release bundle validates
6. stable mirrors generate
7. parity validates
8. active release pointer may change

## 8. Acceptance criteria

- every active claim-bearing artifact can be traced to canonical inputs
- no artifact has an undocumented handwritten dependency
- regeneration from clean state produces identical active outputs
