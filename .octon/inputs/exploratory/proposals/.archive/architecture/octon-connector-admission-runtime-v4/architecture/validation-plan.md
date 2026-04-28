# Validation Plan

## Static validation

- Schema validation for connector operation, admission, trust dossier, and execution receipt.
- Path placement validation.
- Proposal manifest validation.
- Support-target reference validation.
- Capability-pack ID validation.
- Material-effect class validation.

## Governance validation

- No connector admission may reference a capability pack absent from `.octon/instance/governance/capability-packs/registry.yml`.
- No connector admission may claim live support unless its support-target tuple, proof bundle, dossier, and support card are present and consistent.
- No generated connector projection may be used as policy/support authority.
- No connector may widen support-target claims through generated support matrix output.

## Runtime validation

- `octon connector inspect` works without execution authority.
- `octon connector admit --stage-only` creates/updates the correct proposal/control/evidence artifacts or staged governance outputs.
- Material connector invocation fails closed unless routed through run contract, context pack, execution authorization, and verified effect token.
- Connector drift invalidates the operation posture.

## Evidence validation

- Admission proof writes to `state/evidence/connectors/**`.
- Execution attempt receipts write to run evidence and connector evidence.
- Quarantine/retirement emits evidence and revocation/control refs where needed.

## Negative tests

- Direct MCP/tool invocation without admission fails.
- Capability-pack mismatch fails.
- Material-effect class mismatch fails.
- Missing egress policy fails.
- Missing credential class fails.
- Missing rollback/compensation posture fails for effectful operations.
- Generated projection consumed as authority fails.
- Support-target generated widening fails.
