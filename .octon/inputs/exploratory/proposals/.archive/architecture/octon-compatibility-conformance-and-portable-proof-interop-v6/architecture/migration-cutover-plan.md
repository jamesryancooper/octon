# Migration and Cutover Plan

This is an additive new-surface proposal. It does not migrate existing run, support-target, proposal, or generated/effective truth.

## Cutover steps

1. Land framework schemas and practices.
2. Land instance trust policies with deny-by-default defaults.
3. Add control/evidence/continuity roots.
4. Add CLI inspection and proof/attestation commands.
5. Add validators and negative tests.
6. Add generated trust projections only after authority/control/evidence surfaces exist.
7. Run validation suite.

## Cutover guard

Cutover fails if imported proof is used as authority, attestation is accepted as approval, generated trust view is consumed by runtime/policy, blind `.octon/` full-state copy is supported, or support claims widen through external proof.
