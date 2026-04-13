# Validation Plan

## Structural validation

Required:
- workflow manifest/registry integrity after new workflow additions
- scenario registry integrity after repo-shell scenario registration
- overlay/legal-placement checks for new instance governance policy files
- assurance suite registration integrity for new functional suites

## Runtime/control validation

Required:
- `bootstrap-doctor` emits a readiness checkpoint under `state/control/execution/runs/<run-id>/checkpoints/bootstrap-doctor.yml`
- `repo-consequential-preflight` emits a freshness checkpoint under `state/control/execution/runs/<run-id>/checkpoints/repo-consequential-preflight.yml`
- repo-shell classifier outcomes surface through existing authorization/receipt channels rather than informal shell output
- repo-consequential workflows cannot proceed to broad verification without satisfied freshness-preflight conditions

## Assurance validation

Required suites:
- `repo-shell-execution-classification.yml`
- `bootstrap-doctor-readiness.yml`
- `repo-consequential-preflight.yml`
- `repo-shell-supported-scenario.yml`

## Evidence retention

Required:
- retained doctor/preflight receipts in `state/evidence/validation/publication/**`
- retained scenario proof bundles in `state/evidence/lab/**`
- retained run evidence proving failure-taxonomy citations and non-happy-path handling in `state/evidence/runs/**`
- retained control-plane mutation evidence if any policy routing or escalation state mutates in `state/evidence/control/execution/**`

## Generated output validation

Required:
- generated operator digests remain derived-only
- every generated degraded-status summary cites retained evidence roots and failure classes
- no generated summary becomes runtime or policy authority

## Operator/runtime usability validation

Required:
- `/bootstrap-doctor` is invokable from the canonical task workflow surface
- `/repo-consequential-preflight` is invokable before broad verification
- `/run-repo-shell-supported-scenario` is invokable for supported-scenario proof
- `agent-led-happy-path` clearly routes onboarding through doctor/preflight rather than bypassing it

## Pass criteria

Packet-level validation passes only when:
1. all new/edited authored surfaces validate,
2. all required assurance suites pass,
3. all required receipts are retained,
4. all selected workflows are discoverable,
5. operator/runtime touchpoints are usable end-to-end,
6. and the same result is achieved on two consecutive passes with no new blockers.
