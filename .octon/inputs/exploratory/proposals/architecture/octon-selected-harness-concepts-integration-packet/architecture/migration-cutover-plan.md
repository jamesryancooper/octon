# Migration / cutover plan

## Primary conclusion

**No repo-wide topology migration is required.** The recommended motions are additive refinements of existing surfaces.

## Why no broad migration is needed

- The repo already has the correct class-root architecture.
- The repo already has mission/run control roots.
- The repo already has retained evidence and disclosure roots.
- The recommended changes extend schemas/policies/workflows inside already-canonical locations.

## Where cutover is still relevant

### 1. Schema introduction cutover
New contracts must be introduced in an additive way so that:
- validators can begin in report-only or dual-read mode if needed,
- historical run/evidence records remain readable,
- new control/evidence files become required only after the paired validator is promoted.

### 2. Policy adoption cutover
For mission classification and review dispositions:
- introduce policy and contracts first,
- begin writing new files alongside existing run records,
- then enable fail-closed gating after at least one clean validation pass over representative runs.

### 3. Distillation / hardening cutover
Distillation workflows should begin as evidence-only jobs:
- produce retained bundles,
- generate recommendations,
- promote nothing automatically.
Only after bundle quality is trusted should promoted updates start landing in instance/framework authority surfaces.

## Existing migration workflow reference

`/.octon/octon.yml` references a named migration workflow path:
`framework/orchestration/runtime/workflows/meta/migrate-harness/README.md`

This packet did **not** independently inspect that workflow README, so it does not claim more than the reference itself proves. If maintainers choose to promote shared contract changes through a named migration carrier, that referenced workflow is the first candidate to evaluate.

## Cutover profile for this packet

### Recommended profile
- additive contracts first
- retained evidence second
- validators third
- fail-closed gates last

### Not recommended
- one-shot replacement of existing schemas
- backfilling authority from proposal-local packet files
- automatic promotion from distillation outputs to authority

## No-migration rationale for already-covered concepts

Progressive-disclosure context, reversible work-item control, and evidence bundles/disclosure already live in correct surfaces. No migration is needed because no architecture change is proposed.
