# Run Lifecycle v1 Validation Report

- status: `pass`
- validator: `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh`
- fixture_set: `.octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/lifecycle-fixtures.yml`
- generated_at: `2026-04-24T12:09:27Z`
- journal_append_boundary_guard: `pass`

## Coverage
- authority-preconditions
- authorized-stage-only
- bound-stage-only
- boundary-composition
- closeout-completeness
- context-refresh
- denial-path
- effect-token-preconditions
- generated-non-authority
- invalid-transitions-fail-closed
- journal-append-boundary
- journal-derived-runtime-state
- pause-resume
- positive-transitions
- rollback
- stage-only
- unknown-state-fail-closed

## Cases
- `successful-closeout`: pass (closed)
- `paused-resumed-success`: pass (closed)
- `denied-closeout`: pass (closed)
- `stage-only-closeout-boundary`: pass (closed)
- `authorized-stage-only-closeout-boundary`: pass (closed)
- `failed-rolled-back-closeout`: pass (closed)
- `invalid-running-before-authorized`: expected-fail-closed (running)
- `bound-staged-without-stage-only-authority`: expected-fail-closed (staged)
- `bound-staged-with-allow-decision`: expected-fail-closed (staged)
- `authorized-without-grant`: expected-fail-closed (authorized)
- `runtime-state-drift`: expected-fail-closed (authorized)
- `closeout-missing-evidence`: expected-fail-closed (closed)
- `closeout-fake-evidence-ref`: expected-fail-closed (closed)
- `closeout-unresolved-blocking-risk`: expected-fail-closed (closed)
- `generated-read-model-authority`: expected-fail-closed (authorized)
- `absolute-generated-read-model-authority`: expected-fail-closed (authorized)
- `effect-token-outside-running`: expected-fail-closed (staged)
- `unknown-created-state`: expected-fail-closed (bound)
- `unknown-authorizing-state`: expected-fail-closed (authorizing)
