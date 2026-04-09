# Disclosure Normalization Plan

## Objective
Ensure every claim-bearing artifact says exactly what the active release can honestly support—no less, no more.

## 1. Disclosure Source Model
### RunCards
`/.octon/state/evidence/disclosure/runs/**/run-card.yml`
- become the canonical run-level claim surface,
- derive support wording from:
  - `support_target_admission_ref`
  - `support_target_tuple_id`
  - active `release-lineage.yml`
  - generated blocker ledger,
- may summarize non-authoritative host-adapter behavior, but may not imply exclusion from the active claim if the tuple is admitted.

### HarnessCard
`/.octon/state/evidence/disclosure/releases/**/harness-card.yml`
- becomes a computed release summary,
- `claim_status` is generated from certification outputs,
- `known_limits` is generated from blocker ledger + exclusions + intentionally bounded live support realities,
- `known_limits: []` is legal only when the blocker ledger is zero and there is no remaining boundedness that must be told to the reader.

### Evidence Classification
`/.octon/state/evidence/runs/**/evidence-classification.yml`
- remains a retention/classing surface only,
- may contain artifact class lists, retention refs, and missing-artifact facts,
- may not contain live-claim-envelope wording for active admitted runs.

## 2. Normalize the Affected Artifacts
### Active retained run evidence
Update these files and any analogous siblings:
- `/.octon/state/evidence/runs/uec-global-github-repo-consequential-20260404/evidence-classification.yml`
- `/.octon/state/control/execution/runs/uec-global-github-repo-consequential-20260404/stage-attempts/*.yml`
- `/.octon/state/control/execution/runs/uec-global-frontier-browser-api-studio-20260404/stage-attempts/*.yml`

### Release disclosure
Regenerate:
- `/.octon/state/evidence/disclosure/releases/2026-04-08-uec-full-attainment-cutover/harness-card.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- governance mirror surfaces under `/.octon/instance/governance/disclosure/**` and `/.octon/instance/governance/closure/**`

## 3. Banned Phrases in Active Claim-Bearing Artifacts
The following phrases are forbidden in active claim-bearing runtime/disclosure artifacts unless the artifact is explicitly historical or superseded:
- `stage-only and excluded from the live claim envelope`
- `excluded from the bounded live claim`
- `bounded live claim envelope`
- `not part of the live claim` (for admitted live tuples)

## 4. Allowed Phrases
The following are allowed when accurate:
- `supported under canonical authority and evidence controls`
- `host adapter remains projection-only and non-authoritative`
- `historical release lineage only` (historical surfaces only)
- `superseded release evidence` (superseded surfaces only)

## 5. Known-Limits Policy
Add `/.octon/instance/governance/disclosure/known-limits-policy.yml` with rules:
- list every unresolved blocker as a known limit until blocker ledger is zero,
- list every still-bounded support fact that materially qualifies the active claim,
- forbid empty known-limits when any blocker remains,
- forbid known-limits that contradict the active release scope.

## 6. Generated / Effective Parity Requirement
All governance mirror and generated/effective disclosure surfaces must be generated from the active release bundle. Manual edits are disallowed. Byte-parity or semantic parity is required, depending on surface role.
