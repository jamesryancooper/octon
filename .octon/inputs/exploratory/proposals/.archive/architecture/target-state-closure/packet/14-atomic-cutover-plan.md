# 14. Atomic Cutover Plan

## 1. Objective

Define the exact sequence by which Octon’s live claim becomes true atomically rather than gradually.

## 2. Preconditions

Cutover may begin only when all of the following are true in candidate/shadow state:

- canonical schemas are merged
- run-contract-v3 is wired everywhere relevant
- mission-charter and quorum-policy contracts are live
- exemplar evidence classifications are non-empty
- wording coherence passes
- cross-artifact consistency passes
- support dossiers exist for all live tuples
- hidden-check / evaluator-independence / adversarial coverage meet policy minimums
- no unresolved critical or high findings remain
- one shadow release bundle has passed once

## 3. Cutover actors

- constitutional owner
- governance owner
- runtime owner
- CI system
- independent evaluator / reviewer
- release approver

## 4. Atomic cutover sequence

### Step 0 — Freeze
Freeze direct edits to:
- `instance/governance/disclosure/harness-card.yml`
- `instance/governance/closure/*.yml`
- any active proof-bundle exemplar RunCard or measurement summary

Only generator outputs may touch these during cutover.

### Step 1 — Clean baseline
Start from a clean checkout and clean generated/state projection surfaces needed for regeneration.
Do not delete retained evidence roots.

### Step 2 — Migration application
Apply the approved migration manifest:
- contract rewrites
- evidence-classification backfills
- lease/revocation normalization
- support dossier linkups
- measurement/intervention regeneration

### Step 3 — Candidate release bundle generation (Pass 1)
Run:
- validators
- RunCard generation
- HarnessCard generation
- closure bundle generation

Output:
- `state/evidence/disclosure/releases/<release-id>/...`

### Step 4 — Pass 1 validation
All gates G0–G13 must pass.
If any fail, abort cutover.

### Step 5 — Clean regeneration boundary
Wipe only generated disclosure/projection outputs and candidate control artifacts required for deterministic regeneration.
Do not wipe retained evidence, authored inputs, or migrated live control roots.

### Step 6 — Candidate release bundle generation (Pass 2)
Re-run the same generators and validators from clean generated state.

### Step 7 — Pass 2 validation
All gates G0–G13 must pass again.

### Step 8 — Dual-pass equivalence
Compare:
- release bundle manifest digests
- closure outcome
- gate-status contents
- support coverage
- proof-plane coverage
- cross-artifact consistency report
- generated RunCards / HarnessCard digests

If any differ, abort cutover.

### Step 9 — Write closure certificate
Generate:
- `closure-certificate.yml`
- `projection-parity-report.yml`

### Step 10 — Promote active release
Update:
- `instance/governance/disclosure/release-lineage.yml#active_release`

### Step 11 — Generate stable mirrors
Generate:
- `instance/governance/disclosure/harness-card.yml`
- `instance/governance/closure/*.yml`

These must be byte-equal to their release bundle source artifacts.

### Step 12 — Post-promotion verification
Run projection parity and active-release freshness one final time.
If they fail, rollback immediately.

## 5. Rollback plan

Rollback is a pointer + projection rollback, not a manual artifact rewrite.

If any post-promotion validation fails:
1. revert `release-lineage.yml#active_release` to previous release
2. regenerate stable mirrors from previous active release bundle
3. retain failed bundle as candidate/historical evidence, not active claim
4. open remediation issue with blocker classification

## 6. Cutover completion condition

Cutover succeeds only when:
- active release pointer is updated
- stable mirrors are generated and parity-valid
- final post-promotion validation passes
- no critical or high blocker remains open

Before that moment, target-state closure is not live.

## 7. Acceptance criteria

- cutover can be executed from a written scriptable sequence
- no hand editing is needed during cutover
- rollback is pointer-based and immediate
- active release becomes true atomically, not by drift
