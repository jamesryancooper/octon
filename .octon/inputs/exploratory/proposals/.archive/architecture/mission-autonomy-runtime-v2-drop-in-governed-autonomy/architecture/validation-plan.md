# Validation Plan

## Static validation

- Validate all new JSON schemas.
- Validate all new YAML policy files.
- Validate proposal manifests.
- Validate root placement.
- Validate no runtime/policy dependency on `inputs/**` or proposal paths.
- Validate generated read models are non-authoritative.

## Runtime validation

- Refuse continuation without active mission-control lease.
- Refuse expired, paused, revoked, or out-of-scope lease.
- Refuse continuation when budget is `exhausted`.
- Narrow/checkpoint/request decision when budget is `warning`.
- Refuse continuation when circuit breaker is `tripped` or `latched`.
- Refuse stale context or rebuild context before authorization.
- Refuse support/capability/connector drift.
- Refuse progress churn and repeated Action Slice failure.
- Refuse mission closeout until closeout gate passes.

## Run lifecycle integration

- `octon mission continue` compiles a run-contract candidate and enters the existing run-first path.
- No material side effect occurs before authorization.
- Mission Queue item selection never bypasses run contract binding.
- Continuation Decision is emitted after each run attempt.
- Mission Run Ledger indexes runs without replacing run journals.

## Connector validation

- Stage-only connector operation produces stage-only outcome.
- Unadmitted connector operation produces blocked/denied outcome.
- Connector operation maps to capability packs and material-effect classes.
- Connector posture drift blocks continuation.

## Evidence validation

- Mission evidence references per-run evidence without replacing it.
- Mission Evidence Profiles select required evidence categories.
- Closeout fails when mission evidence is incomplete.
- Generated mission status projections trace to control/evidence and remain non-authoritative.

## CLI validation

- CLI help lists mission/continue/decide/connector commands.
- Parse tests for all new commands.
- Prepare-only mission continuation produces no material effect.
