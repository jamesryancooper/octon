# Recertification Runtime v1

## Purpose

The Recertification Runtime validates that Octon remains coherent after an
approved self-evolution promotion. A promotion is not complete until
recertification passes or fails closed with retained evidence.

## Required Dimensions

Recertification validates:

- authority placement
- root boundaries
- runtime authorization coverage
- support-target claims
- capability-pack routes
- connector admissions
- generated/effective handles and freshness
- context-pack behavior
- run lifecycle
- evidence completeness
- rollback or retirement posture
- operator read-model non-authority
- documentation/runtime consistency
- validator health
- proof-plane completeness

## Outputs

- `state/control/evolution/recertifications/<recertification-id>.yml`
- `state/evidence/evolution/recertifications/<recertification-id>/**`
- derived generated recertification status projections

## Failure Rule

Failed or missing recertification blocks closeout and must produce remediation,
rollback, retirement, Decision Request, or fail-closed evidence.
