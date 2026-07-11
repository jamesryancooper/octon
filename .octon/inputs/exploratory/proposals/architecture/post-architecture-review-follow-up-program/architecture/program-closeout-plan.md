# Program Closeout Plan

The program closes only when every registry child reaches an allowed terminal
outcome and aggregate evidence is retained outside proposal paths.

## Closeout Conditions

1. `retirement-register-compatibility-refresh` — closed with zero overdue
   register entries or an explicitly re-dated, owner-confirmed cadence.
2. `runtime-spec-directory-index` — closed with the index landed and
   doc-consistency checks green, or rejected with rationale.
3. `retained-evidence-operability-contract` — closed with the store contract
   and the retention-enforcement decision landed through governed acceptance,
   and with its pre-acceptance gate satisfied: the targeted Prompt 5 domain
   audit evidence exists at its retained evidence path, is cited by the
   child's acceptance record, and carries a recorded disposition (proceed /
   revise / defer / escalate / no-action) with any routed out-of-scope
   concerns resolved per the registry `result_handling` block.
4. `continuity-coherence-validator` — closed with the validator defined,
   implemented through its own gates, and green in the assurance plane.
5. `evidence-classification-v2-migration` — closed with migration complete
   and validated, or explicitly staged with owner and remainder.
6. `historical-runcard-support-audit` — closed with remediation criteria
   adopted or the frozen-as-of-issuance declaration recorded.
7. `governance-quorum-revisit-trigger` — closed as a durable decision packet,
   or recorded as program-local no-action with rationale.

## Closeout Mechanics

- Aggregate program evidence (per-child terminal outcomes, receipt digests,
  disposition notes) is retained under
  `.octon/state/evidence/validation/proposals/post-architecture-review-follow-up-program/`
  before the parent may close.
- Parent closeout follows the proposal lifecycle closeout route with its own
  terminal closeout receipt; the parent then archives to the canonical
  archive path.
- Child evidence remains child-owned at closeout; the aggregate index points
  to child receipts by path and digest, it does not copy or replace them.
- If any required child is rejected or superseded, the parent records the
  disposition and either re-plans a replacement child (registry revision) or
  narrows the program scope with rationale before closing.
- The source review's open questions 2, 3, 4, and 7 must each be resolved or
  explicitly re-deferred with owner at closeout (they map to
  retained-evidence-operability-contract, historical-runcard-support-audit,
  and governance-quorum-revisit-trigger).

## Non-Closeout Boundaries

Program closeout does not: archive or advance the sibling
`runtime-environment-override-governance` packet; mutate authority, control
truth, or generated outputs; or certify anything beyond the seven registry
children's terminal outcomes.
