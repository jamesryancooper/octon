# Architecture Lens Bank

One shared lens bank serves the whole Architecture Review Method Suite. A **lens**
is a reusable unit of architectural analysis: it asks one durable question,
produces one kind of evidence, and is worth applying under stated conditions. A
**method** owns the review's question, scope, routing, and output contract, and
*selects* lenses from this bank — it never defines a private lens catalog.

`lens-bank.yml` is the machine-checked contract for this doctrine: it declares the
18 lens ids in two tiers and the required/optional lens profile for each of the
six suite methods. This document and that YAML MUST agree on the lens ids, tiers,
and profiles; the YAML is authoritative for the machine, this doc for the human.

The default method is
[`balanced-architecture-review-method.md`](./balanced-architecture-review-method.md).
Balanced's required lens set is exactly its existing required sequence expressed
as lens ids — adopting the bank cross-references Balanced doctrine and does not
change it (see the appendix).

## Non-Goals

This bank creates **no** method, **no** routing, **no** lifecycle gate, and **no**
schema, and it grants **no** review output any authority. Review outputs remain
retained evidence or proposal input; the pre-integration architecture review
support receipt remains the only lifecycle-gating review artifact. The lens bank
is analysis tooling that methods select from — nothing more.

## Lens Catalog

18 lenses in two tiers. **Core** lenses are broadly reusable across reviews;
**extended** lenses are applied when the review's risk or domain demands them.
Each lens earns its place by producing a distinct architectural decision, evidence
artifact, or routing outcome.

### Core lenses (12)

| Lens id | Asks | Evidence it produces | When to apply |
| --- | --- | --- | --- |
| `system-job-framing` | What is the fundamental job, mission, and success shape of this system? | A stated system job and success shape. | Whenever a review needs to fix what the system is *for* before assessing structure. |
| `domain-model` | What are the bounded contexts, capabilities, ownership seams, and context maps? (Folds in event-storming and Wardley-style commodity/custom guidance as technique notes.) | A domain/context map with ownership seams. | When the review turns on domain boundaries, ownership, or capability decomposition. |
| `current-reality-map` | What actually exists today across architecture, runtime, state, workflows, validators, projections, and evidence roots? | A current-state map of the real system. | Whenever the reviewed thing already exists and its real shape must ground the analysis. |
| `steelman-chestertons-fence` | Why is the current design the way it is, and what must be preserved, moved, merged, or retired deliberately? | A steelman + preserve/move/merge/retire ledger. | Before proposing change to an existing design, to avoid discarding load-bearing constraints. |
| `complexity-separation` | Which complexity is essential vs accidental, compensating, operational, integration, or migration? | A complexity ledger classifying each source. | When simplification, consolidation, or accidental-complexity removal is on the table. |
| `clean-sheet-reference` | What would the ideal design be if current implementation shape were ignored for a moment? (Intentionally unconstrained; comparison tool only.) | An unconstrained reference design used for comparison. | To expose gaps and better structure — always compared back against current reality, never shipped alone. |
| `quality-attribute-scenarios` | What testable quality needs (latency, reliability, security, operability, maintainability) must the architecture satisfy? | Testable quality-attribute scenarios. | When quality requirements must be made explicit and testable. |
| `tradeoff-adr` | What options, tradeoffs, reversibility, and decision records does this choice imply? | An option comparison and decision record. | When a decision has real alternatives and reversibility matters. |
| `failure-and-recovery` | How does this fail, partially execute, get bypassed, lose evidence, and recover? | A failure-mode and recovery analysis. | Whenever partial execution, bypass, evidence loss, or recovery posture is a risk. |
| `authority-boundary` | Where does authority live (authored `framework/**`/`instance/**` vs generated/inputs/host/chat/memory), and what must never become authority? | An authority map plus what-must-never-become-authority list. | On any change touching authority class, evidence roots, run contracts, support claims, or fail-closed behavior. |
| `validation-strategy` | What schemas, validators, fixtures, negative controls, and fitness checks make the design enforceable? | A validation strategy with concrete checks. | Whenever durable change needs enforceable, fail-closed validation. |
| `non-goals-deletion` | What is explicitly out of scope, not built yet, or should be deleted? | An explicit non-goals / deletion list. | To bound scope and record what is deliberately not done or removed. |

### Extended lenses (6)

| Lens id | Asks | Evidence it produces | When to apply |
| --- | --- | --- | --- |
| `security-threat-model` | What are the trust boundaries, abuse cases, secrets/identity concerns, supply-chain and provenance risks, and privacy/data-risk obligations? | A threat model with trust boundaries and abuse cases. | When trust boundaries, secrets, supply chain, or privacy risk are material. |
| `data-truth-lineage` | Who owns each datum; what is the source of truth; what are lineage, migration, replay, backup, and recovery postures? | A data ownership / source-of-truth and lineage map. | When data ownership, source of truth, migration, or replay is in scope. |
| `contracts-compatibility` | What API/integration contracts, versioning, idempotency, and compatibility posture does the design commit to? | A contract and compatibility posture statement. | When integration contracts, versioning, or backward compatibility are at stake. |
| `operability-observability-evidence` | Is the design deployable, rollbackable, observable (logs/metrics/traces/audit trails), supportable, and evidence-retaining? (Consolidates SRE-readiness, observability, and operational-readiness.) | An operability/observability/evidence readiness assessment. | When deployment, rollback, observability, or operational support are material. |
| `evolution-fitness` | What fitness functions, drift triggers, retirement triggers, and revisit cadence keep this healthy? | Fitness functions and drift/retirement/revisit triggers. | When the design must stay healthy over time under drift. |
| `sequencing-mvp-migration` | What thin-slice sequencing, coexistence/strangler, cutover, rollback, and decommissioning plan gets us there? (Includes build-vs-buy, explicit deferral, and premortem/assumption-register capture.) | A sequencing/migration plan with cutover and rollback. | When delivery requires phased sequencing, coexistence, or migration. |

### Intake bullets deliberately not admitted as lenses

To control sprawl, several intake candidates were folded into lens guidance or
dropped as not decision-producing for Octon-internal reviews: C4/4+1/arc42 view
notation (a documentation technique inside `domain-model` and reference-architecture
outputs, not an analysis lens); cost/FinOps and Team Topologies/Conway (technique
notes under `quality-attribute-scenarios` and `domain-model`, promotable to lenses
later only if reviews demonstrably need them); and platform/IaC boundaries
(subsumed by `operability-observability-evidence` and `security-threat-model` for
Octon's scope).

## Method Lens Profiles (human view)

R = required, O = optional (applied when charter/risk demands), — = normally not
applied. This table mirrors `method_profiles` in `lens-bank.yml`; the YAML is the
machine-checked contract. Method-specific concerns listed below the table are
owned by each method doc, not by the bank.

| Lens | Balanced | Greenfield | Tradeoff | Failure-Mode | Evolution/Fitness | Boundary/Authority |
| --- | --- | --- | --- | --- | --- | --- |
| `system-job-framing` | R | R | O | O | O | O |
| `domain-model` | O | R | O | — | O | O |
| `current-reality-map` | R | O | O | R | R | R |
| `steelman-chestertons-fence` | R | — | O | — | O | O |
| `complexity-separation` | R | O | O | — | O | — |
| `clean-sheet-reference` | R | R | O | — | — | — |
| `quality-attribute-scenarios` | O | R | R | O | O | — |
| `tradeoff-adr` | R | O | R | — | — | — |
| `failure-and-recovery` | R | R | O | R | O | O |
| `authority-boundary` | R | R | O | R | O | R |
| `validation-strategy` | R | R | O | R | R | O |
| `non-goals-deletion` | R | R | O | — | O | O |
| `security-threat-model` | O | R | O | R | — | O |
| `data-truth-lineage` | O | R | O | O | O | O |
| `contracts-compatibility` | O | R | O | O | R | O |
| `operability-observability-evidence` | O | R | O | R | R | — |
| `evolution-fitness` | O | R | O | — | R | — |
| `sequencing-mvp-migration` | O | R | O | — | O | — |

Method-specific concerns (owned by method docs, not the bank): Greenfield —
initial-build sequence, minimum viable architecture, what-not-to-build; Tradeoff —
option matrix and reversibility scoring; Failure-Mode — FMEA-style mode catalog
with detection/containment per mode; Evolution/Fitness — fitness-function
definitions and cadence ownership; Boundary/Authority — actual-vs-claimed
authority map and containment plan.

The five companion method slugs (Greenfield, Tradeoff, Failure-Mode,
Evolution/Fitness, Boundary/Authority) are **provisional** in `lens-bank.yml`. The
phase-1 `architecture-review-method-taxonomy-and-routing` child owns the canonical
method slugs in `naming.yml` v2 and reconciles them against this bank at its
verification gate.

## Clean-Sheet vs Greenfield Complementarity

- **Clean-sheet** (`clean-sheet-reference` lens) is a comparison tool inside a
  broader review. It is intentionally unconstrained, exists to expose gaps,
  accidental complexity, and better structure, and is always compared back against
  current reality. It never ships as a deliverable on its own.
- **Greenfield** is a method. It uses the clean-sheet lens as an opening posture
  but must land on a practical initial-build reference architecture that honors
  real constraints: Octon governance, support claims, validation, operability,
  evidence obligations, and a first implementation scope with an explicit
  what-not-to-build list.
- Rule of thumb: clean-sheet answers "what would ideal look like?" inside a review
  of something that exists; Greenfield answers "what should we build first?" for
  something that does not exist yet (or is being replaced wholesale). Greenfield
  output feeds Balanced Review, Tradeoff Review, or proposal drafting — never
  implementation directly.

## Sprawl Controls

1. **New-lens admission requires a named outcome.** A new lens requires a proposal
   that names the architectural decision, evidence artifact, or routing outcome
   the lens produces. "Useful checklist item" is insufficient.
2. **No private lens catalogs.** Methods may not define private lens catalogs;
   method-specific concerns live in the method's output contract, capped and named
   in the method doc. `lens-bank.yml` is the suite's only lens catalog.
3. **The lens-reference validator fails closed.**
   `validate-architectural-review-lens-references.sh` exits non-zero when a method
   profile or method doc references a lens id not defined in `lens-bank.yml`, or
   when a bank-known suite method lacks a complete profile.
4. **Retirement follows naming/retirement discipline.** Retiring a lens follows the
   same naming/retirement discipline as other methodology surfaces: an explicit
   legacy alias entry, never a silent removal.

## Appendix — Balanced Required Sequence Expressed As Lens Ids

The parent design fixes: *"Balanced's required set is exactly its existing required
sequence expressed as lens ids."* The live
[`balanced-architecture-review-method.md`](./balanced-architecture-review-method.md)
Required Sequence (11 steps) and Output Contract map onto the ten Balanced-required
lens ids as follows. This appendix is authored here; the Balanced doc itself is
**not** edited.

| Balanced sequence / output element (live doc) | Lens id |
| --- | --- |
| Step 1: Frame review charter | method framing (charter precedes lens work; not a lens) |
| Step 2: Identify the fundamental job | `system-job-framing` |
| Step 3: Map current reality across all surfaces | `current-reality-map` |
| Steps 4–5: Steelman + Chesterton's Fence | `steelman-chestertons-fence` |
| Step 6: Separate essential vs accidental/other complexity | `complexity-separation` |
| Step 7: Stale/valid constraints, hidden contracts, bottlenecks, leverage | folded into `current-reality-map` + `complexity-separation` |
| Step 8: Build clean-sheet reference design | `clean-sheet-reference` |
| Step 9: Compare current state vs clean-sheet | method activity across `current-reality-map` + `clean-sheet-reference` |
| Step 10: Produce realistic target architecture | method output (not a single lens) |
| Step 11: Routing, authority boundaries, evidence, validators, rollback, revisit | `authority-boundary` + `validation-strategy` |
| Output: option comparison and recommendation | `tradeoff-adr` |
| Output: failure-mode and second-order-effect analysis | `failure-and-recovery` |
| Output: explicit non-goals / what to delete | `non-goals-deletion` |

The 11 live sequence steps fold to **10** required lens ids: charter framing
(step 1), the step-9 compare, and the step-10 target-architecture output are
method-level activities, not lenses, and several steps map many-to-one. The
resulting Balanced required lens set (10) is: `system-job-framing`,
`current-reality-map`, `steelman-chestertons-fence`, `complexity-separation`,
`clean-sheet-reference`, `tradeoff-adr`, `failure-and-recovery`,
`authority-boundary`, `validation-strategy`, `non-goals-deletion`. This exactly
equals the Balanced `R` column of the profile table above, proving adoption is
cross-reference-only and Balanced doctrine is unchanged.
