# Validation Plan

## Packet Validation

Run:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-architecture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-architecture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-architecture
```

## Future Implementation Validation

Future implementation packets must add domain-specific tests for:

- approval-default primitive rejection;
- proof-missing dispatch refusal;
- stale evidence refusal;
- contradictory evidence refusal;
- scope mismatch refusal;
- authority-zone mismatch refusal;
- generated-output authority misuse;
- read-model authority misuse;
- child or downstream authority takeover;
- missing receipt refusal;
- unsafe resume refusal;
- governance mutation without typed exception grant;
- policy override without typed exception grant;
- external irreversible effect without token, rollback, compensation, and human
  boundary proof.

## Review Evidence

Review should confirm that this packet is architecture-only and that no runtime,
schema, validator, connector, workflow, generated projection, state/control, or
state/evidence mutation is proposed as already complete.
