# Correction Prompt: PPLM-VFY-001

## Finding

`support/follow-up-verification-prompt.md` required:

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --require-implementation-authorization
```

The packet is already `status: implemented`, so the strict
pre-implementation authorization mode fails by design. Implemented packets
must preserve accepted review evidence, then rely on implementation
conformance and post-implementation drift/churn gates for closeout readiness.

## Correction Scope

Update only the packet-local verification prompt so implemented-state
verification uses `validate-proposal-review-gate.sh` without
`--require-implementation-authorization`.

## Acceptance Criteria

- The verification prompt still checks preserved accepted review evidence.
- Mandatory implemented-packet conformance and drift/churn checks remain
  required closeout blockers.
- The packet standard validator passes after this correction.
- No durable implementation target is changed by this correction.
