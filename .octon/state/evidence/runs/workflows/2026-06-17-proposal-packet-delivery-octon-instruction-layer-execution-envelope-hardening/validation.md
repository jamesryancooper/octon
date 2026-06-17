# Validation

- delivery_profile: passed
- proposal_review_gate_with_implementation_authorization: blocked
- architecture_proposal: passed
- implementation_readiness: passed with one archived-prompt warning
- implementation_conformance: passed
- post_implementation_drift_churn: passed
- support_envelope_reconciliation: passed
- run_health_read_model: passed
- architecture_conformance: passed
- generated_non_authority: passed
- aggregate_delivery_receipt: blocked, validator reported `errors=5`

## Aggregate Receipt Validation Errors

- `accepted review freshness must be true`
- `implementation authorization must be true`
- `packet lifecycle verdict must be pass`
- `packet closeout fresh must be true`
- `packet closeout verdict must be pass`

## Blocked Delivery Reason

`outcome=cleaned` cannot be claimed for this wrapper invocation. The wrapper
was run after archive relocation, so the accepted review gate no longer passes
with `--require-implementation-authorization` against the current archived
packet and its digest. The earlier packet closeout receipt remains blocked, and
branch-no-pr Change closeout has not performed hosted landing, final sync, or
source-branch cleanup through its owning route.

## Highest Truthful Aggregate Outcome

`actual_outcome: blocked`.
