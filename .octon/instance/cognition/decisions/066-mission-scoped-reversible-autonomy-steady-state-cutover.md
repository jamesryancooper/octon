# ADR 066: Mission-Scoped Reversible Autonomy Steady-State Cutover

- Date: 2026-03-25
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-steady-state-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-steady-state-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover/`

## Context

ADR 064 completed the major MSRAOM cutover, but the repo still lacked the final
steady-state closure properties required by the active proposal:

- no durable migration plan or ADR for the final steady-state closeout
- `create-mission` still existed primarily as an overview-only workflow contract
- control-evidence coverage was only smoke-tested rather than enforced against
  the required mutation-class set
- version parity, mission-view format, and blocking CI expectations needed to
  converge under the `0.6.1` steady-state release

## Decision

Promote the steady-state MSRAOM closeout as one additional pre-1.0 atomic
cutover.

Rules:

1. `version.txt` and `/.octon/octon.yml` remain in enforced parity.
2. `create-mission` is treated as an operational mutating workflow contract
   that scaffolds authority and seeds control/generation state, not as an
   analysis-only placeholder.
3. The machine-readable mission projection format is
   `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`.
4. Retained control evidence must prove the required mutation classes rather
   than only proving that the receipt writer can emit one generic file.
5. The live validation mission remains the canonical in-repo proof surface for
   slice-linked intent, route linkage, generated mission views, and operator
   digests.

## Consequences

### Benefits

- The steady-state cutover is now backed by durable cognition records rather
  than only by proposal-local planning artifacts.
- Mission creation, control truth, route generation, read models, and evidence
  validation converge on one explicit operating model.
- The evidence validator can now fail closed on missing mutation-class coverage.

### Costs

- Additional retained validation receipts are committed for evidence-class
  coverage.
- Mission workflow contracts gained more explicit mutating stage structure.

### Follow-on Work

1. Verify GitHub branch protection/ruleset enforcement for the expanded
   architecture-conformance job set in the hosted environment.
2. Fold the remaining unrelated continuity-memory run-directory retention drift
   into a separate harness hygiene fix if it continues to block full-profile
   `alignment-check` runs.
