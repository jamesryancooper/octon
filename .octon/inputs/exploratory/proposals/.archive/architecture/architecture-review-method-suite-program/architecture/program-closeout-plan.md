# Program Closeout Plan

The program closes only when every registry child reaches an allowed
terminal outcome and aggregate evidence is retained outside proposal paths.

## Closeout Conditions

1. `architecture-lens-bank-foundation` — closed with the lens bank and
   lens-reference validator landed through governed acceptance, or rejected
   with rationale (which supersedes the entire program — see below).
2. `architecture-review-method-taxonomy-and-routing` — closed with naming
   v2 and routing v2 landed, validators green including negative controls,
   and no regression to existing routes, slugs, aliases, or the
   pre-integration gate.
3. `greenfield-reference-architecture-review-method` — closed with the
   method doc landed and doc-consistency checks green.
4. `companion-architecture-review-methods` — closed with all four method
   docs landed and boundary statements verified against readiness and
   surface-audit doctrine.
5. `architectural-review-schema-extensions` — closed with v2 schemas landed,
   fixtures (positive and negative) green, and v1 coexistence posture
   recorded; support receipt schema verified unchanged.
6. `architectural-review-suite-integration` — closed with workflow
   method-recording, feature/mechanism notes, and lifecycle advisory text
   landed; generated projections refreshed through canonical publishers
   with retained refresh evidence; full validator sweep green.
7. `architecture-review-command-facades` — closed as a landed facade packet,
   or recorded as program-local no-action with rationale (expected default).

## Standing Deferral Records (required at closeout)

- **Command facades no-action** (if not created): rationale, owner
  (octon-maintainers), and re-trigger condition (demonstrated operator
  demand for direct method invocation).
- **Boundary/Authority generic (adopted-repo) mode:** deferred with owner
  (octon-maintainers) and re-trigger condition (first concrete adopted-repo
  review need); recorded so the deferral is discoverable, not folklore.

## Closeout Mechanics

- Aggregate program evidence (per-child terminal outcomes, receipt digests,
  disposition notes, deferral records) is retained under
  `.octon/state/evidence/validation/proposals/architecture-review-method-suite-program/`
  before the parent may close.
- Parent closeout follows the proposal lifecycle closeout route with its own
  terminal closeout receipt; the parent then archives to the canonical
  archive path.
- Child evidence remains child-owned at closeout; the aggregate index points
  to child receipts by path and digest, it does not copy or replace them.
- If any required child is rejected or superseded, the parent records the
  disposition and either re-plans a replacement child (registry revision) or
  narrows the program scope with rationale before closing. Rejection of
  `architecture-lens-bank-foundation` or
  `architecture-review-method-taxonomy-and-routing` invalidates the suite
  premise; the expected disposition is program supersession or rejection,
  not scope narrowing.
- The intake unit under
  `.octon/inputs/additive/.incoming/architecture-review-method-suite/` is
  routed per governed incoming-intake rules once the program reaches a
  terminal state (its retention rationale — pending architect conversion —
  is then satisfied); this program does not itself mutate or remove the
  intake unit.

## Non-Closeout Boundaries

Program closeout does not: mutate authority, control truth, or generated
outputs; widen support claims; certify any review method beyond the registry
children's terminal outcomes; or grant any review output lifecycle gate
authority.
