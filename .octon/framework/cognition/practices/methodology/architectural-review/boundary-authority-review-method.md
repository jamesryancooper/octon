# Boundary/Authority Architecture Review Method

**Method question:** *Where does authority actually live for this surface, and
what must never become authority?*

The Boundary/Authority Architecture Review Method is a companion method in the
Architecture Review Method Suite. Its output is an **authority-placement
analysis** — retained evidence or proposal input — and never implementation
authority. This non-authority posture is stated fail-closed in the
[Output Boundary](#output-boundary-fail-closed) below; it foreshadows and is
bound by that boundary. Balanced Architecture Review remains the suite default;
Boundary/Authority Review is selected when the concern is where authority sits
across a design and what could become an accidental control surface. It ships
**Octon-only in v1** (a generic mode is deferred at the program level and is not
introduced here).

## Use Cases And Non-Goals

**Use cases.** Boundary/Authority Review applies to:

- **workflows, capabilities, proposals, generated projections, and adapters** —
  any surface where authority placement is consequential;
- **any surface where prose, generated outputs, raw inputs, host state, chat,
  dashboards, or model memory could become an accidental control surface** —
  i.e., could be treated as authority it was never granted.

It is **Octon-specific in v1**; the generic mode is deferred.

**Non-goals.** Boundary/Authority Review deliberately does not:

- **classify a single unit's smallest-robust authority model.** Classifying one
  surface as `contract-first`/`mixed`/`markdown-first`/`human-led` is owned by the
  **Surface Architecture Audit**, not this method (see
  [Boundary With Surface-Audit Doctrine](#boundary-with-surface-audit-doctrine)).
  This method reviews authority *placement and containment across a design* and
  escalates single-unit follow-ups to that audit.
- **score readiness.** Readiness scoring is the **Architecture Readiness Audit**'s
  job; this method issues no readiness verdict.

## Required Inputs

A Boundary/Authority Review cannot start without:

1. **the design or surface set under review** — the concrete surfaces whose
   authority is being examined;
2. **the claimed authority map** — where the design *says* authority lives;
3. **the authored/generated/input/state classification of every artifact
   involved** — so claimed authority can be checked against how each artifact is
   actually produced and consumed.

## Lens Profile

Boundary/Authority Review draws every lens from the shared
[Architecture Lens Bank](./architecture-lens-bank.md) and defines
**no private lens catalog**. The profile is the machine-checked contract in
[`lens-bank.yml`](./lens-bank.yml) at
`lens-bank.yml#method_profiles.boundary-authority-review-method`; the doc cites
lens ids only and must match that profile exactly (verified by the doc-consistency
check).

**Required (2):** `current-reality-map`, `authority-boundary`.

**Optional (9):** `system-job-framing`, `domain-model`, `steelman-chestertons-fence`, `failure-and-recovery`, `validation-strategy`, `non-goals-deletion`, `security-threat-model`, `data-truth-lineage`, `contracts-compatibility`.

Lens definitions, tiers, and when-to-apply guidance live in the lens bank and are
not restated here.

## Required Output Sections

Every Boundary/Authority Review must produce all five sections below, in order.
Each section is driven by the lenses named in brackets; that mapping is the
binding proof the doc-consistency check reads.

### 1. Actual-vs-Claimed Authority Map

Where authority *actually* lives across the design, mapped against where it is
*claimed* to live, so every divergence is explicit. Lenses: [`current-reality-map`,
`authority-boundary`].

### 2. Accidental-Control-Surface Findings

The surfaces — prose, generated outputs, raw inputs, host state, chat,
dashboards, model memory — that could be treated as authority they were never
granted, each recorded as a finding. Lenses: [`authority-boundary`,
`data-truth-lineage`].

### 3. Containment Plan

For each divergence: what must move **into `framework/**`** or **`instance/**`** to
become durable authority, and what must be **demoted to evidence or projection**
so it stops acting as authority. Lenses: [`authority-boundary`,
`non-goals-deletion`].

### 4. Fail-Closed And Support-Claim Implications

How the corrected authority map changes fail-closed behavior and what the design
may and may not claim support for, so authority placement and support claims stay
consistent. Lenses: [`authority-boundary`, `failure-and-recovery`].

### 5. Blocker List

The authority-placement problems that remain unresolved — each recorded as a
blocker with the evidence that it is real — so no accidental control surface is
silently left in place. Lenses: [`authority-boundary`].

## Boundary With Surface-Audit Doctrine

Classifying a **single unit's** smallest-robust authority model with the
`contract-first`/`mixed`/`markdown-first`/`human-led` vocabulary is owned by the
**Surface Architecture Audit**
(`.octon/framework/cognition/practices/methodology/audits/surface-architecture.md`,
"## Authority Model Classification"), **not** by this method. Boundary/Authority
Review reviews authority *placement and containment across a design* and
**escalates single-unit follow-ups to that audit**. This method ships
**Octon-only in v1**; the generic mode is deferred at the program level.

## Escalation Rules

Boundary/Authority Review does not own routing authority. The allowed methods per
route, the Balanced escalation map, and the constitutional-conflict route live in
[`review-routing.yml`](./review-routing.yml) `method_selection`; the rules below
cite that data and do not restate it as new authority:

- a **single-unit authority-shape follow-up** (classify one surface's smallest
  robust authority model) → **Surface Architecture Audit**
  (`surface-architecture-audit`);
- a **constitutional authority conflict** (an authority-placement problem
  collides with constitutional, precedence, authority, fail-closed, or evidence
  obligations) → **Constitutional Challenge**, per
  `method_selection.constitutional_conflict_routes_to`.

## Output Boundary (Fail-Closed)

Boundary/Authority Review output is an **authority-placement analysis**. Stated
fail-closed:

- it is retained **evidence** or **proposal input** — it is **never**
  implementation authority and **never** a lifecycle gate;
- method selection grants a Boundary/Authority Review output **no authority**; the
  **pre-integration architecture review support receipt remains the only
  lifecycle-gating review artifact**;
- a containment plan treated as authority to move or demote surfaces is **out of
  contract**: any such change lands only through a proposal on a normal route with
  its own pre-integration architecture review.

Any run that cannot honor this boundary fails closed rather than promoting an
authority-placement analysis into authority it was never granted.

## Related / Navigation

Navigation only — this section changes no doctrine above.

- Method taxonomy and default: [`naming.yml`](./naming.yml) `methods`.
- Shared lens catalog Boundary/Authority Review draws from:
  [Architecture Lens Bank](./architecture-lens-bank.md)
  ([`lens-bank.yml`](./lens-bank.yml)).
- Allowed-methods and escalation routing:
  [`review-routing.yml`](./review-routing.yml) `method_selection`.
- The suite default this method complements:
  [Balanced Architecture Review Method](./balanced-architecture-review-method.md).
- Composition boundary (cited, never modified): the **Surface Architecture Audit**
  owns single-unit authority-model classification
  (`audits/surface-architecture.md`); this method escalates single-unit
  follow-ups to it.
