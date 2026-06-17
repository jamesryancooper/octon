# Child Packet Contract

## Authority Boundary

Children are sibling proposal packets. The parent does not own child packet
directories, child implementation truth, child promotion evidence, child
closeout state, or child archive readiness.

## Required Child Fields

Each child packet must declare:

- objective and scope
- owning durable targets
- route ownership boundaries
- generated-output non-authority posture
- evidence requirements
- negative controls
- rollback posture
- validation commands
- closeout blockers

## Forbidden Transfers

- Parent program evidence must not satisfy child packet receipts.
- Child packets must not edit the completed instruction-envelope receipts.
- Child packets must not hand-edit generated outputs.
- Child packets must not delete protected retained evidence except through a
  route-owned cleanup authorization.
- Child packets must not make blocked receipts pass by changing booleans.
- Child packets must not claim `cleaned` without landing, sync, cleanup, and
  final validation proof.

## Expected Return Evidence

Each implemented child must return child-owned evidence covering review,
implementation readiness, implementation run, conformance, drift/churn,
validation, promotion, closeout, and any generated publication or cleanup
evidence it affects.
