# speckit — Feature Story (Execution Plan)

## Context Packets

- Purpose: standardize spec‑first authoring via a thin wrapper over GitHub SpecKit, aligned to Harmony’s methodology (spec → ADR → plan → tiny PRs behind flags → previews → gates).
- Constraints: simplicity‑first; contracts as source of truth; internal rollout behind `flag.speckit`; budgets: validate p95 ≤ 300ms, availability 99.9% when HTTP is enabled; no secrets in specs/logs.
- Adjacent kits: PlanKit (owns ADR/planning), Dockit (publish), DiagramKit (render), TestKit/PolicyKit/ComplianceKit (gates), ObservaKit (traces/logs), FlagKit (rollout).
- Links: [spec.md](./spec.md), [ADR-0001](./adr-0001.md), component guide: [Spec service guide](../../../.harmony/capabilities/services/planning/spec/guide.md), runbook: [Spec service runbook](../../../.harmony/capabilities/services/planning/spec/runbook.md)
- Contracts: `packages/contracts/openapi.yaml`; schemas: `packages/contracts/schemas/spec-frontmatter.schema.json`.
- Tech choices & rationale: see ADR; contracts enforced in CI via oasdiff + JSON Schema; tiny HTTP/MCP surface only.

## Agent Plan (tiny diffs)

1. Contracts first: confirm `packages/contracts/openapi.yaml` covers `init`, `validate`, `render`, `diagram`; wire oasdiff in CI.
2. Adapter + service skeletons: implement CLI/FS adapters and domain service that call SpecKit (`specify`) with strict arg validation.
3. Routing/wiring: expose `/v1/speckit/*`; guard with `flag.speckit`; return Harmony error envelopes on failures.
4. Artifacts: ensure wrapper writes deterministic outputs (`.specify/**`, `docs/specs/<feature>/**`); optionally emit `snapshot/manifest.json` with `schema_version` + checksums.
5. Contract tests: add acceptance/negative cases for 400/404/409 and schema validation; parity checks between CLI and HTTP/MCP.
6. Preview smoke: deploy PR preview (if HTTP); validate AC; enable structured logs/traces with `run_id` + `idempotency_key`.

## Acceptance Criteria (Observable)

- Given a clean repo and valid payload, when POST `/v1/speckit/init` is called, then 201 is returned with `spec_dir` and created files; if scaffolding already exists (same target), a 409 is returned.
- Given a valid path containing SpecKit artifacts, when POST `/v1/speckit/validate` is called, then 200 is returned with `{ valid: true }`; missing path yields 404; malformed structure yields 200 with `{ valid: false, errors: [...] }`.
- Given a valid path, when POST `/v1/speckit/render` is called, then 200 returns a list of pages and an optional `manifest_uri`.
- Given a valid path, when POST `/v1/speckit/diagram` is called, then 201 returns generated diagram file paths.
- All responses include structured logs with `run_id` and correlate to traces; no secrets or file system paths beyond what is required are emitted.
- Feature remains behind `flag.speckit`; enabling the flag for internal users does not violate SLO budgets or error budgets.
- Negative cases (derived from STRIDE): invalid input → 400; path traversal/SSRF attempts blocked; repeated `init` with same target → 409; insufficient permissions → 403 (if authn/authz enforced); transient errors retried with backoff.

## Contracts (Source of Truth)

- OpenAPI: `packages/contracts/openapi.yaml` (component "SpecKit").
- JSON Schema: `packages/contracts/schemas/spec-frontmatter.schema.json`.
- Optional Pact tests if a distinct consumer/provider is introduced.

## Test Plan

- Unit tests: adapter argument validation; service orchestration; error mapping to Harmony envelopes.
- Contract tests: exercise each `/v1/speckit/*` route against OpenAPI (schemathesis); verify 400/404/409 semantics and response shapes.
- E2E smoke (Preview): call happy paths using example payloads; verify artifacts exist and SLOs are within budgets.
- Negative tests from STRIDE: invalid/missing paths; large repos (timeout budget respected); idempotency checks; log redaction.

## Rollout & Observability

- Flag: `flag.speckit`; audience: internal only initially; ramp based on preview stability.
- Monitors: availability 99.9%, validate p95 ≤ 300ms, render p95 ≤ 1000ms; error rate ≤ 0.5%.
- Observability: traces/logs with `run_id`, `idempotency_key`, and budget; capture file counts/size for capacity planning.

## Pilot Plan & Gates (optional)

- Objective: reduce time‑to‑spec creation and validation by ≥30% with fewer drift incidents.
- Dataset slice: internal repos (5–10 representative specs).
- Metrics: time‑to‑spec, validation pass rate, preview smoke pass rate, p95 latency, error budget burn.
- Acceptance gates: improvements achieved without exceeding latency/error budgets.

## Definition of Done (Gates)

- Lint, typecheck, unit, contract diff, static analysis, dependencies/license, secret scan, SBOM, and perf/bundle budgets are green.
- Preview smoke passes; docs updated (spec/ADR/plan/guide/runbook); feature remains behind flag until rollout criteria met.

## Notes for AI IDE (optional prompt)

```plaintext
Given the Spec, ADR, and Feature Story above, propose a minimal file-by-file diff to implement the thin SpecKit wrapper with tests and contracts. Highlight security/privacy/licensing concerns. Avoid new deps unless justified. Propose negative tests from STRIDE and summarize risks + rollback plan.
```
