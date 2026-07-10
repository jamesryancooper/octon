# Shared Architecture Lens Bank Design

One lens bank serves the whole suite. Methods select lenses; lenses never
own questions, routing, or output contracts. The implementation shape is two
artifacts in the methodology directory:

- `architecture-lens-bank.md` — lens doctrine: what each lens asks, what
  evidence it produces, when it is worth applying.
- `lens-bank.yml` — machine-readable lens ids plus per-method lens profiles
  (required/optional lens sets), so validators can check that method docs
  reference only defined lenses and that every method has a profile.

Rationale for the machine-readable half: lens profiles are a validated
cross-reference surface (methods ↔ lenses). Surface-architecture doctrine
rejects prose as the canonical contract for validated behavior; a prose-only
catalog would drift silently.

## Lens Catalog (18 lenses, two tiers)

Core lenses are broadly reusable; extended lenses are applied when the
review's risk or domain demands them. Intake bullets were consolidated —
each lens must earn its place by producing a distinct architectural
decision, evidence artifact, or routing outcome.

| # | Lens id | Tier | Asks |
| --- | --- | --- | --- |
| 1 | `system-job-framing` | core | What is the fundamental job, mission, and success shape of this system? |
| 2 | `domain-model` | core | What are the bounded contexts, capabilities, ownership seams, and context maps? (Folds in event-storming and Wardley-style commodity/custom guidance as technique notes, not separate lenses.) |
| 3 | `current-reality-map` | core | What actually exists today across architecture, runtime, state, workflows, validators, projections, and evidence roots? |
| 4 | `steelman-chestertons-fence` | core | Why is the current design the way it is, and what must be preserved, moved, merged, or retired deliberately? |
| 5 | `complexity-separation` | core | Which complexity is essential vs accidental, compensating, operational, integration, or migration? |
| 6 | `clean-sheet-reference` | core | What would the ideal design be if current implementation shape were ignored for a moment? (Intentionally unconstrained; comparison tool only.) |
| 7 | `quality-attribute-scenarios` | core | What testable quality needs (latency, reliability, security, operability, maintainability) must the architecture satisfy? |
| 8 | `tradeoff-adr` | core | What options, tradeoffs, reversibility, and decision records does this choice imply? |
| 9 | `failure-and-recovery` | core | How does this fail, partially execute, get bypassed, lose evidence, and recover? |
| 10 | `authority-boundary` | core | Where does authority live (authored `framework/**`/`instance/**` vs generated/inputs/host/chat/memory), and what must never become authority? Includes evidence roots, run contracts, support claims, fail-closed behavior. |
| 11 | `validation-strategy` | core | What schemas, validators, fixtures, negative controls, and fitness checks make the design enforceable? |
| 12 | `non-goals-deletion` | core | What is explicitly out of scope, not built yet, or should be deleted? |
| 13 | `security-threat-model` | extended | What are the trust boundaries, abuse cases, secrets/identity concerns, supply-chain and provenance risks, and privacy/data-risk obligations? |
| 14 | `data-truth-lineage` | extended | Who owns each datum; what is the source of truth; what are lineage, migration, replay, backup, and recovery postures? |
| 15 | `contracts-compatibility` | extended | What API/integration contracts, versioning, idempotency, and compatibility posture does the design commit to? |
| 16 | `operability-observability-evidence` | extended | Is the design deployable, rollbackable, observable (logs/metrics/traces/audit trails), supportable, and evidence-retaining? (Consolidates the intake's SRE-readiness, observability, and operational-readiness bullets.) |
| 17 | `evolution-fitness` | extended | What fitness functions, drift triggers, retirement triggers, and revisit cadence keep this healthy? |
| 18 | `sequencing-mvp-migration` | extended | What thin-slice sequencing, coexistence/strangler, cutover, rollback, and decommissioning plan gets us there? Includes build-vs-buy and explicit deferral, plus premortem/assumption-register capture for the chosen sequence. |

Intake bullets **not** admitted as lenses (folded into lens guidance or
dropped as not decision-producing for Octon-internal reviews): C4/4+1/arc42
view notation (documentation technique inside `domain-model` and reference
architecture outputs, not an analysis lens); cost/FinOps and Team
Topologies/Conway (technique notes under `quality-attribute-scenarios` and
`domain-model`; promotable to lenses later if reviews demonstrably need
them); platform/IaC boundaries (subsumed by `operability-observability-
evidence` and `security-threat-model` for Octon's scope).

## Method Lens Profiles

R = required, O = optional (applied when charter/risk demands), — = normally
not applied. Method-specific concerns listed after the table are owned by
the method doc, not the bank.

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

Method-specific concerns (owned by method docs): Greenfield —
initial-build sequence, minimum viable architecture, what-not-to-build;
Tradeoff — option matrix and reversibility scoring; Failure-Mode — FMEA-style
mode catalog with detection/containment per mode; Evolution/Fitness —
fitness-function definitions and cadence ownership; Boundary/Authority —
actual-vs-claimed authority map and containment plan.

Balanced's required set is exactly its existing required sequence expressed
as lens ids — adopting the bank must not change Balanced doctrine, only
cross-reference it.

## Clean-Sheet vs Greenfield (Complementarity Statement)

- **Clean-sheet** (`clean-sheet-reference` lens) is a comparison tool inside
  a broader review. It is intentionally unconstrained, exists to expose
  gaps, accidental complexity, and better structure, and is always compared
  back against current reality. It never ships as a deliverable on its own.
- **Greenfield** is a method. It uses the clean-sheet lens as an opening
  posture but must land on a practical initial-build reference
  architecture that honors real constraints: Octon governance, support
  claims, validation, operability, evidence obligations, and a first
  implementation scope with an explicit what-not-to-build list.
- Rule of thumb: clean-sheet answers "what would ideal look like?" inside a
  review of something that exists; Greenfield answers "what should we build
  first?" for something that does not exist yet (or is being replaced
  wholesale). Greenfield output feeds Balanced Review, Tradeoff Review, or
  proposal drafting — never implementation directly.

## Sprawl Controls

1. New lenses require a proposal that names the architectural decision,
   evidence artifact, or routing outcome the lens produces; "useful
   checklist item" is insufficient.
2. Methods may not define private lens catalogs; method-specific concerns
   live in the method's output contract, capped and named in the method doc.
3. The lens-reference validator fails when a method doc references an
   undefined lens id or a defined method lacks a profile in `lens-bank.yml`.
4. Retiring a lens follows the same naming/retirement discipline as other
   methodology surfaces (explicit legacy alias entry, no silent removal).
