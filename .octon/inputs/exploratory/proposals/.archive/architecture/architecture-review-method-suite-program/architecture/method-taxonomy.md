# Final Method Taxonomy

The Architecture Review Method Suite is the method layer of the Architectural
Review Mechanism. Routed modes in `review-routing.yml` are review
*occasions*; methods are *how* a review is conducted. Every review run
selects exactly one method; Balanced Architecture Review is the default when
no selection is made. Methods own the question, scope, routing, and output
contract; lenses come from the shared bank (`lens-bank-design.md`).

Common rules for every method:

- Output is retained evidence or proposal input. No method output gains
  lifecycle gate authority; the pre-integration support receipt remains the
  only gating review artifact.
- Every method report records the method slug and the lens profile actually
  applied (schema extension child).
- Constitutional conflicts route to Constitutional Challenge regardless of
  method (existing kernel gate).
- Unknown method selection is fail-closed (`unknown_method`).

## 1. Balanced Architecture Review Method

- **Slug:** `balanced-architecture-review-method` (unchanged; existing
  doctrine at `balanced-architecture-review-method.md` is preserved).
- **Question:** Given current reality, what should change next — and what
  must be preserved?
- **Use cases:** default for any architecture change evaluation; existing
  systems; pre-integration reviews of architecture proposals.
- **Non-goals:** designing from zero (Greenfield); exhaustive option scoring
  (Tradeoff); readiness verdicts (readiness audit).
- **Required inputs:** review charter (decision, scope, risk tolerance,
  non-goals); access to current surfaces and evidence roots.
- **Outputs:** existing output contract (charter, current-reality map,
  steelman/Chesterton's Fence, constraint and complexity ledgers,
  clean-sheet comparison, realistic target architecture, authority/evidence/
  validation/rollback plan, verdict).
- **Escalation:** ≥2 viable target designs needing explicit comparison →
  Tradeoff Review; runtime-critical or governance-critical failure behavior
  in doubt → Failure-Mode Review; long-lived mechanism health in doubt →
  Evolution/Fitness Review; authority location in doubt →
  Boundary/Authority Review; target does not exist yet → Greenfield Review.

## 2. Greenfield Reference Architecture Review

- **Slug:** `greenfield-reference-architecture-review`.
- **Question:** If this system or subsystem did not exist, what should we
  build first?
- **Use cases:** new systems, new subsystems, major replacement candidates
  before implementation proposals exist.
- **Non-goals:** deciding what to change in an existing system (Balanced);
  fantasy architecture — output must respect Octon governance, support
  claims, validation, and operability from day one; absorbing companion
  methods' output contracts.
- **Required inputs:** the system job / mission statement; known hard
  constraints (governance posture, evidence obligations, support-claim
  boundaries); explicit statement of what is being replaced, if anything.
- **Outputs (five required sections):** domain/job model; reference
  architecture; quality/security/ops model; authority/evidence model;
  evolution plan — plus initial-build sequencing, minimum viable
  architecture, and an explicit what-not-to-build-yet list. Output is
  reference architecture: evidence or proposal input, never implementation
  authority.
- **Escalation:** option choice inside the reference design → Tradeoff
  Review; runtime-critical subsystem in the design → Failure-Mode Review;
  before any implementation proposal → Balanced Review or proposal drafting
  against current reality (when replacing an existing system).

## 3. Architecture Tradeoff Review

- **Slug:** `architecture-tradeoff-review`.
- **Question:** Given the candidate designs, which tradeoffs are we
  accepting, and which option should we recommend?
- **Use cases:** ≥2 explicit candidate designs; reversibility-sensitive
  decisions; ADR preparation.
- **Non-goals:** generating the candidates (Balanced or Greenfield do that);
  re-litigating settled constraints; standing in for a full review of the
  chosen option.
- **Required inputs:** named candidate designs; quality attributes that
  matter for this decision; risk tolerance and time horizon.
- **Outputs:** option matrix; quality-attribute assessment; tradeoff,
  risk, and reversibility analysis per option; recommendation with rejected
  alternatives; ADR-ready decision record input with revisit triggers.
- **Escalation:** a leading option with unclear failure behavior →
  Failure-Mode Review; a leading option that is long-lived infrastructure →
  Evolution/Fitness Review; candidates that differ mainly in where authority
  lives → Boundary/Authority Review.

## 4. Failure-Mode Architecture Review

- **Slug:** `failure-mode-architecture-review`.
- **Question:** How does this architecture fail, drift, get bypassed,
  partially execute, lose evidence, confuse operators, or fail to recover?
- **Use cases:** runtime-critical or governance-critical surfaces; anything
  fail-closed; recovery and continuity mechanisms; pre-acceptance
  hardening of a chosen design.
- **Non-goals:** scoring implementation readiness (the readiness audit's
  mandatory failure-mode assessment owns that verdict context); generic
  quality review; incident postmortems (lifecycle-postmortem-evaluator).
- **Required inputs:** the design or mechanism under review; its authority
  and evidence obligations; its recovery expectations.
- **Outputs:** failure-mode catalog (including authority inflation, stale
  evidence, generated-output misuse, bypass paths, partial execution, zombie
  runs, rollback gaps, operator confusion); detection and containment
  expectations per mode; recovery posture; required validators or negative
  controls; unresolved-failure blocker list.
- **Escalation:** failure modes rooted in authority placement →
  Boundary/Authority Review; failure modes that only appear over time →
  Evolution/Fitness Review; constitutional fail-closed conflicts →
  Constitutional Challenge.

## 5. Evolution/Fitness Architecture Review

- **Slug:** `evolution-fitness-architecture-review`.
- **Question:** Will this architecture remain healthy as the system changes,
  and how will we know?
- **Use cases:** long-lived mechanisms; compatibility-sensitive contracts;
  surfaces with revisit cadences or retirement registers.
- **Non-goals:** initial design (Greenfield/Balanced); point-in-time failure
  analysis (Failure-Mode); compatibility review execution itself (owned by
  the governance surfaces that schedule them).
- **Required inputs:** the mechanism's contracts and consumers; its change
  history or expected change pressure; existing validator coverage.
- **Outputs:** architectural fitness functions; drift triggers; retirement
  triggers; compatibility posture; validator needs; revisit cadence with
  owner.
- **Escalation:** a fitness function that needs enforcement → validator work
  through normal proposal routes; discovered current-state incoherence →
  Balanced Review or the appropriate audit.

## 6. Boundary/Authority Architecture Review

- **Slug:** `boundary-authority-architecture-review`.
- **Question:** Where does authority actually live for this surface, and
  what must never become authority?
- **Use cases:** workflows, capabilities, proposals, generated projections,
  adapters, and any surface where prose, generated outputs, raw inputs, host
  state, chat, dashboards, or model memory could become accidental control
  surfaces. Octon-specific in v1 (generic mode deferred).
- **Non-goals:** classifying one surface's smallest robust authority model
  with the surface-architecture audit's vocabulary (that audit owns
  `contract-first`/`mixed`/`markdown-first`/`human-led` classification of a
  single unit — this method reviews authority *placement and containment*
  across a design); readiness scoring.
- **Required inputs:** the design or surface set under review; the claimed
  authority map; the authored/generated/input/state classification of every
  artifact involved.
- **Outputs:** actual-vs-claimed authority map; accidental-control-surface
  findings; containment plan (what must be moved into `framework/**` or
  `instance/**`, what must be demoted to evidence or projection); fail-closed
  and support-claim implications; blocker list.
- **Escalation:** single-unit authority-shape follow-up →
  `surface-architecture-audit`; constitutional authority conflicts →
  Constitutional Challenge.

## Composition With Adjacent Doctrine (No Duplication)

- **Architecture Readiness Evaluation** (`architecture-readiness/`): owns
  readiness verdicts, scoring dimensions, hard gates, and its mandatory
  failure-mode assessment for whole-harness/bounded-domain targets. The
  suite never issues readiness verdicts; Failure-Mode Review cites readiness
  doctrine's failure-mode vocabulary where it overlaps instead of redefining
  it.
- **Surface Architecture Audit** (`audits/surface-architecture.md`): owns
  single-unit authority-model classification and smallest-robust-correction
  findings. Boundary/Authority Review escalates single-unit follow-ups to
  it.
- **Domain Architecture Audit / readiness audit routes:** unchanged review
  occasions; a suite method may be selected within them where their doctrine
  permits, recorded in evidence.
