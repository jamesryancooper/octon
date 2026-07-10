# Evolution/Fitness Architecture Review Method

**Method question:** *Will this architecture remain healthy as the system changes,
and how will we know?*

The Evolution/Fitness Architecture Review Method is a companion method in the
Architecture Review Method Suite. Its output is a **fitness and evolution
assessment** — retained evidence or proposal input — and never implementation
authority. This non-authority posture is stated fail-closed in the
[Output Boundary](#output-boundary-fail-closed) below; it foreshadows and is
bound by that boundary. Balanced Architecture Review remains the suite default;
Evolution/Fitness Review is selected when the concern is a design's health *over
time* rather than its correctness at a single point.

## Use Cases And Non-Goals

**Use cases.** Evolution/Fitness Review applies to:

- **long-lived mechanisms** expected to survive many changes;
- **compatibility-sensitive contracts** whose consumers must not be broken by
  change;
- **surfaces with revisit cadences or retirement registers** whose health must be
  re-checked on a schedule.

**Non-goals.** Evolution/Fitness Review deliberately does not:

- **do initial design.** Producing the design in the first place is the
  **Greenfield Reference Architecture Review Method**'s job for a clean sheet and
  the **Balanced Architecture Review Method**'s job for an existing system.
- **perform point-in-time failure analysis.** How the design breaks *right now*
  is the **Failure-Mode Architecture Review Method**'s job; this method is scoped
  to health as the system changes.
- **execute compatibility review itself.** Running the actual compatibility
  checks is owned by the governance surfaces that schedule them; this method
  states the fitness functions and needs, it does not run them.

## Required Inputs

An Evolution/Fitness Review cannot start without:

1. **the mechanism's contracts and consumers** — what it promises and who depends
   on those promises;
2. **its change history or expected change pressure** — how it has changed or is
   expected to change;
3. **its existing validator coverage** — what is already enforced and what is not.

## Lens Profile

Evolution/Fitness Review draws every lens from the shared
[Architecture Lens Bank](./architecture-lens-bank.md) and defines
**no private lens catalog**. The profile is the machine-checked contract in
[`lens-bank.yml`](./lens-bank.yml) at
`lens-bank.yml#method_profiles.evolution-fitness-review-method`; the doc cites
lens ids only and must match that profile exactly (verified by the doc-consistency
check).

**Required (5):** `current-reality-map`, `validation-strategy`, `contracts-compatibility`, `operability-observability-evidence`, `evolution-fitness`.

**Optional (10):** `system-job-framing`, `domain-model`, `steelman-chestertons-fence`, `complexity-separation`, `quality-attribute-scenarios`, `failure-and-recovery`, `authority-boundary`, `non-goals-deletion`, `data-truth-lineage`, `sequencing-mvp-migration`.

Lens definitions, tiers, and when-to-apply guidance live in the lens bank and are
not restated here.

## Required Output Sections

Every Evolution/Fitness Review must produce all six sections below, in order. Each
section is driven by the lenses named in brackets; that mapping is the binding
proof the doc-consistency check reads.

### 1. Architectural Fitness Functions

The testable functions that assert the design is still healthy — the properties
that must hold as the system changes, expressed so they can be checked rather than
asserted. Lenses: [`evolution-fitness`, `validation-strategy`].

### 2. Drift Triggers

The concrete signals that the design has drifted from its intended shape,
grounded against how it works today. Lenses: [`evolution-fitness`,
`current-reality-map`].

### 3. Retirement Triggers

The conditions under which the mechanism should be retired or replaced rather than
extended, so end-of-life is a recorded decision rather than an omission. Lenses:
[`evolution-fitness`, `non-goals-deletion`].

### 4. Compatibility Posture

How the design keeps faith with its contracts and consumers through change — what
is guaranteed stable, what may break, and under what notice. Lenses:
[`contracts-compatibility`].

### 5. Validator Needs

The fitness functions that need enforcement to hold over time — named as
validator needs for normal proposal routes to build, not authored here. Lenses:
[`validation-strategy`].

### 6. Revisit Cadence With Owner

When the design is re-checked, on what schedule, and who owns that revisit — so
health is maintained rather than assumed. Lenses:
[`operability-observability-evidence`, `evolution-fitness`].

## Escalation Rules

Evolution/Fitness Review does not own routing authority. The allowed methods per
route, the Balanced escalation map, and the constitutional-conflict route live in
[`review-routing.yml`](./review-routing.yml) `method_selection`; the rules below
cite that data and do not restate it as new authority:

- a **fitness function that needs enforcement** → validator work through normal
  proposal routes (this method states the need; it authors no validator);
- **discovered current-state incoherence** (the mechanism is already unhealthy,
  not just at risk over time) → **Balanced Architecture Review Method**
  (`balanced-architecture-review-method`) or the appropriate audit route;
- a **constitutional conflict** (a fitness or compatibility obligation collides
  with constitutional, precedence, authority, fail-closed, or evidence
  obligations) → **Constitutional Challenge**, per
  `method_selection.constitutional_conflict_routes_to`.

## Output Boundary (Fail-Closed)

Evolution/Fitness Review output is a **fitness and evolution assessment**. Stated
fail-closed:

- it is retained **evidence** or **proposal input** — it is **never**
  implementation authority and **never** a lifecycle gate;
- method selection grants an Evolution/Fitness Review output **no authority**; the
  **pre-integration architecture review support receipt remains the only
  lifecycle-gating review artifact**;
- a fitness assessment treated as authority to enforce is **out of contract**: a
  fitness function becomes enforced only through a validator built on a normal
  proposal route with its own pre-integration architecture review.

Any run that cannot honor this boundary fails closed rather than promoting a
fitness assessment into authority it was never granted.

## Related / Navigation

Navigation only — this section changes no doctrine above.

- Method taxonomy and default: [`naming.yml`](./naming.yml) `methods`.
- Shared lens catalog Evolution/Fitness Review draws from:
  [Architecture Lens Bank](./architecture-lens-bank.md)
  ([`lens-bank.yml`](./lens-bank.yml)).
- Allowed-methods and escalation routing:
  [`review-routing.yml`](./review-routing.yml) `method_selection`.
- The suite default this method complements:
  [Balanced Architecture Review Method](./balanced-architecture-review-method.md).
- Sibling companion for point-in-time failure behavior:
  [Failure-Mode Architecture Review Method](./failure-mode-review-method.md).
