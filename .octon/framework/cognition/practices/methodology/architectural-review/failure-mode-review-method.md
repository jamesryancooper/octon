# Failure-Mode Architecture Review Method

**Method question:** *How does this architecture fail, drift, get bypassed,
partially execute, lose evidence, confuse operators, or fail to recover?*

The Failure-Mode Architecture Review Method is a companion method in the
Architecture Review Method Suite. Its output is a **failure-mode analysis** —
retained evidence or proposal input — and never implementation authority, and
never a readiness verdict. This non-authority posture is stated fail-closed in
the [Output Boundary](#output-boundary-fail-closed) below; it foreshadows and is
bound by that boundary. Balanced Architecture Review remains the suite default;
Failure-Mode Review is selected to harden a runtime- or governance-critical
design against the ways it can break.

## Use Cases And Non-Goals

**Use cases.** Failure-Mode Review applies to:

- **runtime-critical or governance-critical surfaces** whose misbehavior has
  consequential blast radius;
- **anything fail-closed** — surfaces whose safety depends on refusing rather
  than proceeding under doubt;
- **recovery and continuity mechanisms** whose whole purpose is behaving under
  failure;
- **pre-acceptance hardening** of a chosen design before it is committed.

**Non-goals.** Failure-Mode Review deliberately does not:

- **score implementation readiness.** Readiness scoring — including the mandatory
  failure-mode assessment that feeds a readiness verdict — is owned by the
  **Architecture Readiness Audit**, not this method (see
  [Boundary With Readiness Doctrine](#boundary-with-readiness-doctrine)).
- **perform generic quality review.** Broad quality assessment across attributes
  is the **Balanced Architecture Review Method**'s job; this method is scoped to
  failure behavior.
- **run incident postmortems.** Postmortem analysis of a run that already
  happened is owned by the **Lifecycle Postmortem Evaluator**
  (`lifecycle-postmortem-evaluator`), not by this forward-looking review.

## Required Inputs

A Failure-Mode Review cannot start without:

1. **the design or mechanism under review** — the concrete surface whose failure
   behavior is being interrogated;
2. **its authority and evidence obligations** — what it is allowed to decide and
   what evidence it must retain;
3. **its recovery expectations** — what "recovered" means for this surface and
   who is expected to act.

## Lens Profile

Failure-Mode Review draws every lens from the shared
[Architecture Lens Bank](./architecture-lens-bank.md) and defines
**no private lens catalog**. The profile is the machine-checked contract in
[`lens-bank.yml`](./lens-bank.yml) at
`lens-bank.yml#method_profiles.failure-mode-review-method`; the doc cites lens
ids only and must match that profile exactly (verified by the doc-consistency
check).

**Required (6):** `current-reality-map`, `failure-and-recovery`, `authority-boundary`, `validation-strategy`, `security-threat-model`, `operability-observability-evidence`.

**Optional (4):** `system-job-framing`, `quality-attribute-scenarios`, `data-truth-lineage`, `contracts-compatibility`.

Lens definitions, tiers, and when-to-apply guidance live in the lens bank and are
not restated here.

## Required Output Sections

Every Failure-Mode Review must produce all five sections below, in order. Each
section is driven by the lenses named in brackets; that mapping is the binding
proof the doc-consistency check reads.

### 1. Failure-Mode Catalog

The enumerated ways this architecture breaks, grounded against how it actually
works today. The catalog must at minimum consider **authority inflation** (a
surface accreting control it was never granted), **stale evidence**,
**generated-output misuse** (a derived projection treated as authority), **bypass
paths** around the intended control flow, **partial execution**, **zombie runs**,
**rollback gaps**, and **operator confusion**. Lenses: [`current-reality-map`,
`failure-and-recovery`, `authority-boundary`, `security-threat-model`].

### 2. Per-Mode Detection And Containment

For each catalogued mode: how it is detected and what contains its blast radius
before it spreads — the observable signal and the boundary that holds. Lenses:
[`operability-observability-evidence`, `validation-strategy`].

### 3. Recovery Posture

What "recovered" means for this surface, how the design gets back to a known-good
state, and where recovery is currently unproven. Lenses: [`failure-and-recovery`].

### 4. Required Validators Or Negative Controls

The validators, negative controls, or fail-closed conditions the design needs so
that each catalogued mode is caught rather than tolerated. This names the checks;
it does not author them. Lenses: [`validation-strategy`].

### 5. Unresolved-Failure Blocker List

The failure modes that remain uncontained — each recorded as a blocker with the
evidence that it is real — so that no unaddressed failure is silently dropped.
Lenses: [`authority-boundary`, `failure-and-recovery`].

## Boundary With Readiness Doctrine

Scoring implementation readiness — including the **Architecture Readiness Audit**'s
mandatory failure-mode assessment
(`.octon/framework/cognition/practices/methodology/architecture-readiness/framework.md`,
"## Mandatory Failure-Mode Analysis") — is owned by the readiness audit, **not**
by this method. Failure-Mode Review **cites** that failure-mode vocabulary where
it overlaps and **issues no readiness verdict**. When a run needs a readiness
score or gate, it escalates to the Architecture Readiness Audit rather than
inferring one from this method's output.

## Escalation Rules

Failure-Mode Review does not own routing authority. The allowed methods per route,
the Balanced escalation map, and the constitutional-conflict route live in
[`review-routing.yml`](./review-routing.yml) `method_selection`; the rules below
cite that data and do not restate it as new authority:

- **failure modes rooted in authority placement** (where authority actually
  lives) → **Boundary/Authority Architecture Review**
  (`boundary-authority-review-method`);
- **failure modes that only appear over time** (drift, decay, compatibility
  erosion) → **Evolution/Fitness Architecture Review**
  (`evolution-fitness-review-method`);
- a **constitutional fail-closed conflict** (a failure mode collides with
  constitutional, precedence, authority, fail-closed, or evidence obligations) →
  **Constitutional Challenge**, per
  `method_selection.constitutional_conflict_routes_to`.

## Output Boundary (Fail-Closed)

Failure-Mode Review output is a **failure-mode analysis**. Stated fail-closed:

- it is retained **evidence** or **proposal input** — it is **never**
  implementation authority, **never** a lifecycle gate, and **never** a readiness
  verdict;
- method selection grants a Failure-Mode Review output **no authority**; the
  **pre-integration architecture review support receipt remains the only
  lifecycle-gating review artifact**;
- a failure-mode analysis treated as a readiness score or implementation
  authorization is **out of contract**: readiness is the Architecture Readiness
  Audit's to issue, and implementation still requires a proposal and its own
  pre-integration architecture review.

Any run that cannot honor this boundary fails closed rather than promoting a
failure-mode analysis into authority it was never granted.

## Related / Navigation

Navigation only — this section changes no doctrine above.

- Method taxonomy and default: [`naming.yml`](./naming.yml) `methods`.
- Shared lens catalog Failure-Mode Review draws from:
  [Architecture Lens Bank](./architecture-lens-bank.md)
  ([`lens-bank.yml`](./lens-bank.yml)).
- Allowed-methods and escalation routing:
  [`review-routing.yml`](./review-routing.yml) `method_selection`.
- The suite default this method complements:
  [Balanced Architecture Review Method](./balanced-architecture-review-method.md).
- Composition boundary (cited, never modified): the **Architecture Readiness
  Audit** owns readiness verdicts and the mandatory failure-mode assessment
  (`architecture-readiness/framework.md`); this method issues no readiness
  verdict.
