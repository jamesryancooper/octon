# ADR 084: Unified Execution Constitution Final Cutover Closeout

- Date: 2026-03-29
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-final-cutover-closeout/plan.md`
  - `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-final-cutover-closeout/`
  - `/.octon/state/evidence/validation/publication/build-to-delete/2026-03-29/final-cutover-verdict.yml`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

Phases 0 through 7 had landed, and the repo now had packet-grade governance,
run, disclosure, support-target, and build-to-delete surfaces.

What still remained was one final closeout decision proving whether the
repository now satisfies:

- the packet cutover checklist,
- the final target-state claim criteria, and
- the packet’s own retirement expectation for promotion and archive readiness.

The final closeout also found one validation-drift issue:

- `validate-assurance-disclosure-expansion.sh` still expected the older Wave 6
  receipt for the assurance family even though the live assurance contract
  correctly points to the Phase 4 proof/lab expansion receipt.

## Decision

Treat this closeout as the final packet-grade adjudication point.

Rules:

1. The unified execution constitution claim is valid only if every checklist
   item and every final claim criterion is explicitly satisfied from live repo
   evidence.
2. Validation drift found during closeout must be fixed in the same branch as
   the final verdict.
3. The final verdict must separately record:
   - claim validity,
   - remaining blockers, if any,
   - packet promotion readiness, and
   - packet archive readiness.
4. Proposal lifecycle changes remain a separate step unless a human explicitly
   requests promotion/archive execution after the verdict is known.

## Consequences

### Benefits

- The packet now has one retained closeout verdict tied to live validators and
  durable governance surfaces.
- Promotion and archive readiness can be decided from canonical evidence rather
  than interpretation of intermediate phase bundles.
- The final cutover status is discoverable outside the proposal workspace.

### Costs

- The closeout required another full validator sweep and a same-change fix to a
  stale assurance/disclosure validator expectation.

## Completion

This closeout is complete once:

- the final validator set passes,
- the checklist and claim matrix are retained in the closeout bundle, and
- the final verdict explicitly states whether the packet is ready for promotion
  and archive
