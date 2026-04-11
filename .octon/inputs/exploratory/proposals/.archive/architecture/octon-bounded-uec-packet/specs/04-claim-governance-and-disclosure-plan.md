# Claim Governance and Disclosure Plan

## 1. Recommendation

Adopt **Path B — claim-safe recertification**.

The repo should not continue to present the active bounded claim as `complete` while known closure blockers remain inside authority and evidence surfaces.

## 2. Immediate claim-state transition

### 2.1 Current problem

The active release lineage and closure file currently present a complete bounded claim. The current repo state is better described as:

> bounded constitutional implementation substantially attained; complete claim under active recertification.

### 2.2 Immediate fix

Create a new active release:

- `2026-04-11-uec-bounded-recertification-open`

Update:

- `/.octon/instance/governance/disclosure/release-lineage.yml`
- `/.octon/instance/governance/closure/unified-execution-constitution.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/generated/effective/closure/recertification-status.yml`

### 2.3 Required active status semantics

| Field | Interim value |
|---|---|
| active release status | `active` |
| claim status | `recertification_open` |
| claim scope | `bounded-admitted-live-universe` |
| release wording | no complete-attainment wording allowed |
| complete-claim citation | prohibited |

## 3. Allowed interim public wording

Until recertification completes, the most permissive honest wording is:

> **Octon presently operates a bounded unified execution constitution architecture for the admitted live support universe, with the complete closure claim under active recertification pending authority-ledger normalization, run-bundle hardening, workflow non-authority proof, and disclosure re-alignment.**

This wording:

- preserves the bounded architecture claim,
- avoids saying complete,
- and aligns public disclosure with the blocker state.

## 4. Disallowed interim wording

Until recertification completes, the following are disallowed:

- “Octon has attained a fully unified execution constitution.”
- “The bounded UEC claim is complete.”
- any wording stronger than the weakest active claim-bearing run bundle.

## 5. Recertification-open release bundle contents

The provisional release bundle must include:

- the downgraded HarnessCard
- a provisional closure certificate
- the blocker register
- traceability matrix reference
- known-limits statement
- explicit statement that 2026-04-09 complete-claim lineage is superseded by a stricter recertification-open release

## 6. Complete-claim re-attainment mechanics

### 6.1 New final release

When all blockers are closed, mint a new release, e.g.:

- `2026-04-XX-uec-bounded-recertified-complete`

### 6.2 Required state transitions

| File / surface | Required transition |
|---|---|
| `release-lineage.yml` | active release becomes the recertified-complete release |
| closure file | `claim_status: complete` only after dual-pass green |
| authored HarnessCard | allowed to use bounded complete wording |
| generated/effective claim status | regenerated from new active release |
| prior recertification-open release | superseded, retained as history |

### 6.3 Required final wording

Only after all conditions are met:

> **Octon materially substantiates a fully hardened, normalized, evidence-backed bounded Unified Execution Constitution for the admitted live support universe, with release disclosure, support claims, exemplar run evidence, and dual-pass certification regenerated from canonical repo surfaces.**

## 7. Fallback narrowing option

If a preserved full admitted universe cannot be closed on time, the fallback is:

- keep support-targets.yml as the authoritative admitted universe,
- narrow only the **public complete claim scope** to the fully substantiated subset,
- and publish explicit out-of-scope tuples in the active HarnessCard.

This fallback is honest but less desirable than completing the full bounded universe.

## 8. RunCard / HarnessCard coupling rules

### RunCard

Each exemplar claim-bearing run must disclose:

- support-target tuple id
- authority artifact refs
- run bundle manifest ref
- proof-plane refs
- recovery / replay refs
- known limits and interventions

### HarnessCard

The active HarnessCard must disclose:

- active claim status
- active support scope
- active exemplar run refs
- proof-plane coverage refs
- known limits
- historical supersessions
- no hidden strengthening beyond run or release evidence
