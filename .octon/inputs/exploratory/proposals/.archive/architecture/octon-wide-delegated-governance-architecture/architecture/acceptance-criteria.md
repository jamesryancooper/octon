# Acceptance Criteria

## Architecture Acceptance

- The packet clearly states that automation is the default when authority can
  be machine-proven.
- Human approval is limited to typed exception grants for non-machine-provable
  boundaries.
- The lifecycle migration is identified as the reference implementation.
- Existing approval, exception, revocation, effect-token, control, and evidence
  infrastructure is preserved until replaced through accepted child packets.
- Generated outputs and read models are explicitly non-authoritative.
- External irreversible effects remain human-required unless rollback,
  compensation, token, and irreversibility proof are explicit.

## Future Implementation Acceptance

Future child packets must prove:

- default approval primitives are absent from migrated domains;
- generic approval-required states are replaced or narrowed to typed
  human-boundary states where applicable;
- unattended or autonomous execution cannot dispatch without retained proof;
- generated outputs and read models cannot grant authority;
- stale, missing, contradictory, ambiguous, or scope-mismatched evidence fails
  closed;
- connector or external irreversible effects are denied or human-required unless
  token, rollback, compensation, egress, and irreversibility proof passes;
- run-health and read-model projections remain observational;
- grant consumption writes evidence and still requires delegation proof.

## Rejection Criteria

Reject or revise the packet if it:

- treats importance alone as a human-only boundary;
- weakens canonical control truth;
- makes generated outputs, read models, or proposal-local receipts authority;
- removes approval infrastructure before defining a typed replacement;
- widens connector, support-target, or authority-zone permission;
- claims Octon-wide automation without domain-specific proof gates.
