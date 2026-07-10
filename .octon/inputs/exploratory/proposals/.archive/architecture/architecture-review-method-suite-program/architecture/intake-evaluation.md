# Intake Evaluation

Evaluation of the non-authoritative intake unit
`.octon/inputs/additive/.incoming/architecture-review-method-suite/` against
the live repository. Verdict classes: **accept**, **revise**, **merge**,
**defer**, **reject**.

## Accepted

| Intake element | Disposition rationale |
| --- | --- |
| Suite name "Architecture Review Method Suite" | Clear, matches the existing "Architectural Review Mechanism" family without colliding with it. |
| Balanced Architecture Review stays the default general method | Matches current doctrine (`balanced-architecture-review-method.md`); nothing in the intake justifies a competing default. |
| Core design rule: methods own question/scope/routing/output contract; lenses are reusable analysis tools | Adopted verbatim as the suite's constitutional design rule. |
| One shared lens bank instead of per-method catalogs | Prevents the exact sprawl the intake warns about; adopted with a machine-readable form (`lens-bank.yml`) so profiles are validatable. |
| Clean-sheet = comparison lens, Greenfield = practical initial-build method | Adopted; see `lens-bank-design.md` for the full complementarity statement. |
| Five companion methods (Greenfield, Tradeoff, Failure-Mode, Evolution/Fitness, Boundary/Authority) as distinct, callable methods | Each produces a distinct architectural decision class and output contract; none reduces to a lens without losing its escalation and output semantics. |
| Greenfield's five required sections (domain/job model; reference architecture; quality/security/ops model; authority/evidence model; evolution plan) | Adopted as the Greenfield output contract skeleton. |
| Guardrails: no sprawl, no duplication of readiness/surface-audit doctrine, generated outputs derived-only, review outputs evidence-only | Adopted and bound into the child packet contract. |

## Revised

| Intake element | Revision |
| --- | --- |
| Open question: "should companions become first-class routed workflow modes?" | Resolved as **no for this program**. Methods enter `naming.yml` as a methods list and `review-routing.yml` as method-selection semantics; they do not get workflow directories, evidence roots, or `use_when` routes of their own. Routed modes remain review occasions; any occasion may select a suite method, recorded in evidence. New routed modes would need a later proposal with demonstrated demand. |
| Candidate lens bank (28 loosely-scoped bullets) | Consolidated to a bounded catalog of 18 lenses in two tiers (core / extended), with several intake bullets merged (e.g., SRE readiness + observability + operational readiness → one operability-observability-evidence lens; event storming and Wardley mapping folded into the domain-model lens guidance rather than standing as separate lenses). See `lens-bank-design.md`. |
| Candidate file name `architecture-lens-bank.md` | Kept, plus a machine-readable `lens-bank.yml` so method profiles reference lens ids that validators can check. Prose-only lens catalogs invite silent drift (surface-architecture doctrine: prose must not be the canonical contract for a validated surface). |
| "Greenfield may use the broadest lens set" | Accepted with a hard cap: Greenfield's profile is the broadest **selection from the shared bank** plus three method-specific concerns (initial-build sequencing, minimum viable architecture, what-not-to-build). It may call companions; it may not absorb their output contracts. |

## Merged

| Intake element | Merged into |
| --- | --- |
| "Likely child packets" items 1–2 (taxonomy/routing, lens bank) | Two children, with the lens bank first — taxonomy profiles reference lens ids, so the bank is the foundation (`architecture-lens-bank-foundation`, `architecture-review-method-taxonomy-and-routing`). |
| "Likely child packets" item 4 (four companion methods) | One child (`companion-architecture-review-methods`) — four sibling docs with an identical contract shape; four packets would be lifecycle churn without independent decisions. |
| "Likely child packets" items 5 and 7 (schemas; validators/projections) | Schema and receipt-validator work in `architectural-review-schema-extensions`; projection refresh and the validator sweep in `architectural-review-suite-integration`. |
| "Likely child packets" items 6 and 8 (workflow/command/skill integration; docs and lifecycle integration) | Workflow method-recording, product feature note, and lifecycle advisory text in `architectural-review-suite-integration`; command/skill facades split out as the conditional `architecture-review-command-facades`. |

## Deferred

| Intake element | Deferral rationale |
| --- | --- |
| Command and skill facades for suite methods | Conditional child. Methods are reachable through existing review occasions and lifecycle prompts; facades are operator convenience, added only if demand appears during program execution. Default closure is a recorded no-action. |
| Generic (adopted-repository) mode for Boundary/Authority Review | Octon-only in v1. The method's value is precisely its Octon authority model; a generic mode needs adopted-repo experience that does not exist yet. Deferral recorded at program closeout with owner and trigger. |
| Schema-backed receipt giving Greenfield output any gate authority | Rejected for this program (below) as authority, deferred as mechanics: Greenfield reports use the extended report schema as evidence; any future gate contract is a separate lifecycle proposal. |

## Rejected

| Intake element / latent risk | Rejection rationale |
| --- | --- |
| Separate large lens banks per method | Method sprawl; the intake itself argues against this. One bank, per-method profiles. |
| Greenfield absorbing companion methods | Companions must stay distinct and callable from Balanced, Greenfield, or lifecycle contexts; Greenfield escalates to them instead of inlining their contracts. |
| Any new lifecycle gate, closeout authority, or review-output authority | Review outputs remain evidence or proposal input. The pre-integration support receipt remains the only lifecycle-gating review artifact; the suite adds no gates. |
| A new mechanism parallel to the Architectural Review Mechanism | The suite is the method layer inside the existing mechanism; a parallel mechanism would duplicate routing, naming, schemas, and validators wholesale. |
| Treating the intake's acceptance criteria or impact map as binding | They are advisory; this program's own acceptance criteria and disposition matrix govern. |

## Intake Open Questions — Architect Answers

1. *First-class routed workflow modes vs methodology-only?* Methods are
   first-class methodology surfaces selected through routing semantics; no
   new routed workflow modes in this program (see "Revised").
2. *Greenfield schema-backed receipt now or later?* Greenfield reports use
   the extended report schema (method + lens fields) as retained evidence;
   no dedicated receipt and no gate authority now.
3. *Which methods get command/skill facades in wave one?* None; conditional
   child, default no-action.
4. *Boundary/Authority Octon-only or generic?* Octon-only in v1; generic mode
   deferred with recorded rationale.
5. *Which generated projections must refresh after landing?* Whatever
   canonical publishers cover the touched surfaces — at minimum the proposal
   registry, capability/host projections, and any published methodology or
   feature-catalog projections; enumerated concretely by
   `architectural-review-suite-integration` at its creation, refreshed only
   through canonical publication scripts.
