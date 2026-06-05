# Validation Plan

## Creation Validation

- Run proposal standard validation for the parent and every child packet.
- Run proposal program structure validation for the parent.
- Do not run child-readiness as a pass/fail creation gate until child-owned
  proposal reviews and implementation-grade completeness receipts exist.

## Future Program Gates

- Parent review gate with implementation authorization.
- Proposal program child-readiness gate.
- Child implementation-readiness validation.
- Targeted runner, validator, cleanup, evidence, and token-efficiency tests
  declared by each child.
- Negative controls proving hard blockers still stop the runner.

## Evidence Quality

Validation evidence must prove behavior, authority boundaries, generated/input
non-authority, child-owned receipt preservation, cleanup routing, and token
efficiency. Proposal-local summaries are not runtime authority.
