# Decision Record Plan

## Required decision records

If implementation changes durable architecture or runtime behavior beyond direct enforcement of existing contracts, add ADRs under the active instance decision path.

Recommended ADRs:

1. **ADR: Run Lifecycle v1 is the sole runtime state machine for consequential Runs**
   - Why `runtime-state.yml` is derived only.
   - Why journal wins on conflict.
   - Why invalid transitions fail closed.

2. **ADR: Lifecycle reconstruction is required support-target proof for repo-consequential tuples**
   - How lifecycle validation supports existing `support-targets.yml` requirements.
   - Why this does not widen support.

3. **ADR: Historical runs without reconstruction proof are legacy evidence, not lifecycle-conformant claims**
   - Compatibility treatment for pre-cutover run roots.

## Decision record non-goals

Do not create ADRs that re-open:

- Octon's class-root topology;
- Run vs Mission terminology;
- Authorized Effect Token requirement;
- Context Pack Builder requirement;
- support-target matrix expansion.
