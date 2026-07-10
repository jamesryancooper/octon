# Preserved Source — Method Taxonomy §§3–6 + Composition

Verbatim extract of the parent program's
`architecture/method-taxonomy.md` (the companion-method sections and the
composition-with-adjacent-doctrine section) preserved as lineage. The canonical
method **slugs** in the live `naming.yml` v2 differ from the descriptive slugs
below; the repository slugs govern (see `../architecture/current-state-gap-map.md`
§Source ⇄ Repository Reconciliations). Lineage only — not authority.

---

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

---

## Repository-Grounded Slug And Path Corrections

| Source (method-taxonomy) | Live repository (governs) |
| --- | --- |
| `architecture-tradeoff-review` | `tradeoff-review-method` |
| `failure-mode-architecture-review` | `failure-mode-review-method` |
| `evolution-fitness-architecture-review` | `evolution-fitness-review-method` |
| `boundary-authority-architecture-review` | `boundary-authority-review-method` |
| `audits/surface-architecture.md` | `.octon/framework/cognition/practices/methodology/audits/surface-architecture.md` |
| readiness "failure-mode assessment" | `architecture-readiness/framework.md` → "## Mandatory Failure-Mode Analysis" |
