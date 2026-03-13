# {{feature-name}} - Feature Story (Execution Plan)

## Context Packets

- Domain notes, glossary, and example payloads
- Constraints: compliance, latency budgets, scale limits
- Links: [spec.md](./spec.md), ADRs, contracts, runbook

## Agent Plan (Small Diffs)

1. Contracts first: author OpenAPI and JSON Schema; add stub handlers and
   contract tests.
2. Core implementation: add domain logic and integration adapters.
3. Interface wiring: expose endpoints or entry points behind `flag.{{feature-name}}`
   when applicable.
4. Artifact generation (if applicable): produce reproducible manifests/snapshots.
5. Preview/staging smoke: validate acceptance criteria before rollout.

## Acceptance Criteria (Observable)

- Given/When/Then outcomes tied to contracts and flags
- Negative cases derived from the threat model

## Contracts (Source of Truth)

- OpenAPI: `packages/contracts/openapi.yaml`
- JSON Schema: `packages/contracts/schemas/feature-name.schema.json`
- Optional consumer/provider contract tests when multiple repos interact

## Test Plan

- Unit tests near business logic
- Contract tests at integration boundaries
- E2E smoke tests for critical workflows
- Artifact validation for schema_version and integrity (if applicable)

## Rollout and Observability

- Rollout strategy: internal -> canary -> general availability
- Flag strategy: `flag.{{feature-name}}` (if applicable)
- Monitoring: SLOs, dashboards, alerts, traces

## Definition of Done

- Lint, typecheck, unit tests, contract checks, static analysis, dependency
  policy checks, and secret scans are green.
- Preview/staging smoke checks pass.
- Docs and runbook updates are merged with implementation changes.

## Notes for AI IDE (Optional Prompt)

```text
Given the Spec and Feature Story above, propose a minimal file-by-file diff
with tests and contracts.
Highlight security/privacy concerns. Avoid new dependencies unless justified.
Propose negative tests from the threat model and summarize rollback impact.
```
