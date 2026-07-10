# Architecture Tradeoff Review Method

**Method question:** *Given the candidate designs, which tradeoffs are we
accepting, and which option should we recommend?*

The Architecture Tradeoff Review Method is a companion method in the Architecture
Review Method Suite. Its output is a **tradeoff analysis and recommendation** —
retained evidence or proposal input — and never implementation authority. This
non-authority posture is stated fail-closed in the [Output Boundary](#output-boundary-fail-closed)
below; it foreshadows and is bound by that boundary. Balanced Architecture Review
remains the suite default; Tradeoff Review is selected only when two or more
explicit candidate designs already exist and the decision *between* them — not
their generation — is the work.

## Use Cases And Non-Goals

**Use cases.** Tradeoff Review applies when:

- **two or more explicit candidate designs** are already on the table;
- a **reversibility-sensitive decision** must be made and the cost of choosing
  wrong is asymmetric;
- an **ADR** is being prepared and the decision needs a defensible, recorded
  rationale.

**Non-goals.** Tradeoff Review deliberately does not:

- **generate the candidate designs.** Producing candidates for an existing
  system is the **Balanced Architecture Review Method**'s job, and producing a
  clean-sheet candidate is the **Greenfield Reference Architecture Review
  Method**'s job; Tradeoff Review compares candidates it is handed.
- **re-litigate settled constraints.** Governance posture, evidence obligations,
  and support-claim boundaries are inputs to the comparison, not open questions
  it reopens.
- **stand in for a full review of the chosen option.** Once an option is
  recommended, the winning design still needs its own review and its own
  pre-integration architecture review before implementation.

## Required Inputs

A Tradeoff Review cannot start without:

1. **named candidate designs** — two or more, each described concretely enough to
   compare on the same terms;
2. **the quality attributes that matter for this decision** — the attributes
   against which the options are actually scored;
3. **the risk tolerance and time horizon** — how reversible the decision must be
   and how long the chosen design is expected to last.

## Lens Profile

Tradeoff Review draws every lens from the shared
[Architecture Lens Bank](./architecture-lens-bank.md) and defines
**no private lens catalog**. The profile is the machine-checked contract in
[`lens-bank.yml`](./lens-bank.yml) at
`lens-bank.yml#method_profiles.tradeoff-review-method`; the doc cites lens ids
only and must match that profile exactly (verified by the doc-consistency check).

**Required (2):** `quality-attribute-scenarios`, `tradeoff-adr`.

**Optional (16):** `system-job-framing`, `domain-model`, `current-reality-map`, `steelman-chestertons-fence`, `complexity-separation`, `clean-sheet-reference`, `failure-and-recovery`, `authority-boundary`, `validation-strategy`, `non-goals-deletion`, `security-threat-model`, `data-truth-lineage`, `contracts-compatibility`, `operability-observability-evidence`, `evolution-fitness`, `sequencing-mvp-migration`.

Lens definitions, tiers, and when-to-apply guidance live in the lens bank and are
not restated here.

## Required Output Sections

Every Tradeoff Review must produce all five sections below, in order. Each section
is driven by the lenses named in brackets; that mapping is the binding proof the
doc-consistency check reads.

### 1. Option Matrix

The candidate designs laid out side by side against the quality attributes and
constraints that decide the choice, so the comparison is explicit rather than
narrative. Lenses: [`tradeoff-adr`, `quality-attribute-scenarios`].

### 2. Quality-Attribute Assessment

Testable quality-attribute scenarios (latency, reliability, maintainability,
operability) scored per option, so "better" is measured against named attributes
rather than asserted. Lenses: [`quality-attribute-scenarios`].

### 3. Per-Option Tradeoff, Risk, And Reversibility Analysis

For each option: what it buys, what it costs, how it fails, and how hard it is to
reverse once built. Reversibility is a first-class axis, not an afterthought.
Lenses: [`tradeoff-adr`, `failure-and-recovery`, `evolution-fitness`].

### 4. Recommendation With Rejected Alternatives

A single recommended option with the explicit reasons the others were rejected,
so the decision is auditable and the rejected paths are recorded rather than
forgotten. Lenses: [`tradeoff-adr`].

### 5. ADR-Ready Decision-Record Input With Revisit Triggers

A decision record shaped for direct hand-off to ADR drafting, including the
concrete conditions that would justify revisiting the decision later. Lenses:
[`tradeoff-adr`, `evolution-fitness`].

## Escalation Rules

Tradeoff Review does not own routing authority. The allowed methods per route, the
Balanced escalation map, and the constitutional-conflict route live in
[`review-routing.yml`](./review-routing.yml) `method_selection`; the rules below
cite that data and do not restate it as new authority:

- a **leading option whose failure behavior is in doubt** → **Failure-Mode
  Architecture Review** (`failure-mode-review-method`);
- a **leading option that is long-lived infrastructure** whose health over time
  is in doubt → **Evolution/Fitness Architecture Review**
  (`evolution-fitness-review-method`);
- **candidates that differ mainly in where authority lives** → **Boundary/Authority
  Architecture Review** (`boundary-authority-review-method`);
- a **constitutional conflict** (a candidate collides with constitutional,
  precedence, authority, fail-closed, or evidence obligations) → **Constitutional
  Challenge**, per `method_selection.constitutional_conflict_routes_to`.

## Output Boundary (Fail-Closed)

Tradeoff Review output is a **tradeoff analysis and recommendation**. Stated
fail-closed:

- it is retained **evidence** or **proposal input** — it is **never**
  implementation authority and **never** a lifecycle gate;
- method selection grants a Tradeoff Review output **no authority**; the
  **pre-integration architecture review support receipt remains the only
  lifecycle-gating review artifact**;
- a recommendation treated as implementation authority is **out of contract**:
  the recommended option still requires its own review and its own
  pre-integration architecture review before implementation.

Any run that cannot honor this boundary fails closed rather than promoting a
recommendation into authority it was never granted.

## Related / Navigation

Navigation only — this section changes no doctrine above.

- Method taxonomy and default: [`naming.yml`](./naming.yml) `methods`.
- Shared lens catalog Tradeoff Review draws from:
  [Architecture Lens Bank](./architecture-lens-bank.md)
  ([`lens-bank.yml`](./lens-bank.yml)).
- Allowed-methods and escalation routing:
  [`review-routing.yml`](./review-routing.yml) `method_selection`.
- The suite default this method complements:
  [Balanced Architecture Review Method](./balanced-architecture-review-method.md).
- Sibling companion that generates clean-sheet candidates:
  [Greenfield Reference Architecture Review Method](./greenfield-reference-architecture-review-method.md).
