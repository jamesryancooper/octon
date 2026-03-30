# Missing Evidence Fail Closed

- fixture: `missing-evidence-fail-closed`
- based on: `supported-envelope-positive`
- intentionally omitted artifact: `external-replay-index`
- retained decision artifact:
  `/.octon/state/evidence/control/execution/authority-decision-uec-closure-missing-evidence-20260330.yml`

This fixture proves the supported tuple fails closed when a required closure
artifact is missing. The closure validator blocks publication rather than
silently preserving eligibility.

Result: PASS
