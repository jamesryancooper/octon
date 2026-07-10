# Greenfield Reference Architecture Review Method

**Method question:** *If this system or subsystem did not exist, what should we
build first?*

The Greenfield Reference Architecture Review Method is a companion method in the
Architecture Review Method Suite. Its output is **reference architecture** —
retained evidence or proposal input — and never implementation authority. This
non-authority posture is stated fail-closed in the [Output Boundary](#output-boundary-fail-closed)
below; it foreshadows and is bound by that boundary. Balanced Architecture
Review remains the suite default; Greenfield is selected only when the target
does not exist yet or is being replaced wholesale.

## Use Cases And Non-Goals

**Use cases.** Greenfield applies to:

- **new systems** that do not exist yet;
- **new subsystems** being introduced into an existing system;
- **major replacement candidates** — an existing system slated for wholesale
  replacement — evaluated *before* an implementation proposal exists.

**Non-goals.** Greenfield deliberately does not:

- **decide what to change in an existing system.** Assessing an existing design
  and producing a realistic what-to-change target is the **Balanced
  Architecture Review Method**'s job, not Greenfield's.
- **produce fantasy architecture.** A Greenfield reference design must respect
  Octon governance posture, support-claim boundaries, evidence obligations,
  validation, and operability from day one. A design that ignores these is out
  of contract.
- **absorb the companion methods' output contracts.** Option matrices belong to
  Architecture Tradeoff Review, failure-mode catalogs to Failure-Mode
  Architecture Review, fitness-function ownership to Evolution/Fitness
  Architecture Review, and actual-vs-claimed authority maps to Boundary/Authority
  Architecture Review. Greenfield escalates to these methods (see
  [Escalation Rules](#escalation-rules)); it does not restate their contracts.

## Required Inputs

A Greenfield review cannot start without:

1. **the system's job / mission statement** — what the system is *for* and the
   shape of its success;
2. **known hard constraints** — governance posture, evidence obligations, and
   support-claim boundaries the design must honor;
3. **an explicit statement of what is being replaced, if anything.** When an
   existing system is being replaced, this input engages the optional
   `current-reality-map` lens so the reference design is grounded against the
   real thing it supersedes; when nothing is being replaced, that lens is
   normally not applied.

## Lens Profile

Greenfield draws every lens from the shared
[Architecture Lens Bank](./architecture-lens-bank.md) and defines **no private
lens catalog**. The profile is the machine-checked contract in
[`lens-bank.yml`](./lens-bank.yml) at
`method_profiles.greenfield-reference-architecture-review-method`; the doc cites
lens ids only and must match that profile exactly (verified by the
doc-consistency check).

**Required (14):** `system-job-framing`, `domain-model`, `clean-sheet-reference`,
`quality-attribute-scenarios`, `failure-and-recovery`, `authority-boundary`,
`validation-strategy`, `non-goals-deletion`, `security-threat-model`,
`data-truth-lineage`, `contracts-compatibility`,
`operability-observability-evidence`, `evolution-fitness`,
`sequencing-mvp-migration`.

**Optional (3):** `current-reality-map` (engaged when replacing an existing
system), `complexity-separation`, `tradeoff-adr`.

Lens definitions, tiers, and when-to-apply guidance live in the lens bank and
are not restated here.

## Required Output Sections

Every Greenfield review must produce all five sections below, in order. Each
section is driven by the lenses named in brackets; that mapping is the binding
proof the doc-consistency check reads.

### 1. Domain / Job Model

The system's fundamental job, the problem it exists to solve, its bounded
contexts, ownership seams, and core entities. This section fixes *what the
system is for* before any structure is chosen. Lenses: [`system-job-framing`,
`domain-model`].

### 2. Reference Architecture — The Deliverable

The clean-sheet reference design: components, their responsibilities,
boundaries, and the contracts between them. In Greenfield this design **is the
deliverable**, not a comparison artifact. It states its integration and
compatibility posture, and separates essential structure from accidental
complexity so the first build stays coherent. Lenses: [`clean-sheet-reference`,
`contracts-compatibility`, `complexity-separation` (optional)].

### 3. Quality / Security / Ops Model

Testable quality-attribute scenarios (latency, reliability, maintainability),
the threat model with trust boundaries and abuse cases, failure and recovery
behavior, and observability/operability from day one. A Greenfield design that
cannot be operated, secured, or recovered is not done. Lenses:
[`quality-attribute-scenarios`, `security-threat-model`, `failure-and-recovery`,
`operability-observability-evidence`].

### 4. Authority / Evidence Model

Where durable authority lives, what must **never** become authority, the
data-truth and lineage model, and the validation strategy that makes the design
enforceable. This section is what prevents fantasy architecture: every reference
design must state its authority placement and evidence obligations concretely.
Lenses: [`authority-boundary`, `data-truth-lineage`, `validation-strategy`].

### 5. Evolution Plan

Fitness functions, drift and retirement triggers, compatibility posture, and
revisit cadence that keep the design healthy over time. Lenses:
[`evolution-fitness`].

## Build Discipline

Greenfield answers "what should we build *first*?" — so a reference design is
incomplete without an honest first-build plan.

- **Initial-build sequencing.** The ordered first increments to build, gated by
  their dependencies, so the system reaches its job in coherent thin slices
  rather than a big-bang landing. Lens: [`sequencing-mvp-migration`].
- **Minimum viable architecture.** The smallest coherent architecture that does
  the system's job with governance, evidence, and operability intact — not the
  smallest thing that compiles. Lenses: [`sequencing-mvp-migration`,
  `non-goals-deletion`].
- **What-not-to-build-yet list.** An explicit deferral/deletion list of
  components that are tempting but not yet justified. Each deferred item carries
  the concrete **trigger** that would justify building it later, so deferral is a
  recorded decision rather than an omission. Lens: [`non-goals-deletion`].

## Clean-Sheet Complementarity With Balanced

Greenfield and Balanced both use the `clean-sheet-reference` lens, but they use
it differently, and the two methods must not be confused:

- In **Balanced**, the clean-sheet reference is a **comparison tool** run against
  current reality — it feeds a realistic what-to-change target for a system that
  already exists (Balanced's Required Sequence steps 8–10).
- In **Greenfield**, the clean-sheet reference **is the deliverable** — there is
  no existing system to preserve, or the existing system is being replaced
  wholesale. Greenfield issues **no what-to-change verdict**.
- When an existing system is being replaced, the transition back to current
  reality is not Greenfield's output: it is handed to **Balanced Review** or to
  proposal drafting against current reality (see
  [Escalation Rules](#escalation-rules)).

## Escalation Rules

Greenfield does not own routing authority. The allowed methods per route, the
Balanced escalation map, and the constitutional-conflict route live in
[`review-routing.yml`](./review-routing.yml) `method_selection`; the rules below
cite that data and do not restate it as new authority:

- an **option choice inside the reference design** (two or more viable target
  designs) → **Architecture Tradeoff Review** (`tradeoff-review-method`); engage
  the optional `tradeoff-adr` lens to frame the choice for hand-off;
- a **runtime-critical subsystem** in the design whose failure behavior is in
  doubt → **Failure-Mode Architecture Review** (`failure-mode-review-method`);
- **before any implementation proposal** → **Balanced Review**, or proposal
  drafting against current reality when an existing system is being replaced;
- a **constitutional conflict** (the reference design collides with
  constitutional, precedence, authority, fail-closed, or evidence obligations) →
  **Constitutional Challenge**, per
  `method_selection.constitutional_conflict_routes_to`.

## Output Boundary (Fail-Closed)

Greenfield output is **reference architecture**. Stated fail-closed:

- it is retained **evidence** or **proposal input** — it is **never**
  implementation authority, **never** a lifecycle gate, and **never** a
  what-to-change verdict against an existing system;
- method selection grants a Greenfield output **no authority**; the
  **pre-integration architecture review support receipt remains the only
  lifecycle-gating review artifact**;
- a Greenfield output treated as implementation authority is **out of contract**:
  implementation still requires a proposal drafted against current reality and
  its own pre-integration architecture review.

Any run that cannot honor this boundary fails closed rather than promoting a
reference design into authority it was never granted.

## Related / Navigation

Navigation only — this section changes no doctrine above.

- Method taxonomy and default: [`naming.yml`](./naming.yml) `methods`.
- Shared lens catalog Greenfield draws from:
  [Architecture Lens Bank](./architecture-lens-bank.md)
  ([`lens-bank.yml`](./lens-bank.yml)).
- Allowed-methods and escalation routing:
  [`review-routing.yml`](./review-routing.yml) `method_selection`.
- The default method Greenfield complements:
  [Balanced Architecture Review Method](./balanced-architecture-review-method.md).
- Composition boundaries (cited, never modified): the **Architecture Readiness
  Audit** owns readiness verdicts — Greenfield issues none — and the **Surface
  Architecture Audit** critiques a single durable surface; both are audit routes
  in [`naming.yml`](./naming.yml) `canonical_modes`, not Greenfield outputs.
