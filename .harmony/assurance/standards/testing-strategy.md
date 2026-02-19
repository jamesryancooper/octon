---
title: Testing Strategy
description: Repository-wide test strategy and gates — unit/property, integration, contract, and e2e — with coverage targets, flake policy, and data/fixtures guidance.
---

# Testing Strategy

Status: Draft stub (set team thresholds)

## Two‑Dev Scope

- Focus: unit tests required on every push; contract tests for externally consumed APIs or shared boundaries; E2E limited to a small preview smoke (happy path).
- Adoption: property‑based tests optional for high‑value pure logic; Pact/Schemathesis added when boundaries stabilize (not day‑one).
- Coverage: start pragmatic; tighten later. Optimize for test determinism over breadth; zero‑flake policy on main, quarantine else.
- Infra: use emulators where available; avoid bespoke containers and local orchestration unless justified.

## Pillars Alignment

- Speed with Safety: Fast feedback via unit tests on every push and preview E2E smoke before promotion enables frequent, safe releases.
- Simplicity over Complexity: Emphasize a lean test pyramid; avoid over‑reliance on brittle E2E in favor of deterministic unit/contract tests.
- Quality through Determinism: Contract tests (Pact/Schemathesis), JSON‑Schema validations, and zero‑flake policy make results reproducible and auditable.
- Guided Agentic Autonomy: Agents can propose tests and golden checks; humans approve. Pin AI configs and capture ObservaKit traces for agent‑assisted changes.
- Evolvable Modularity: Stable contracts and slice‑aligned test suites make it safe to swap databases, services, models, and providers behind tests without breaking consumers.

See `.harmony/cognition/methodology/README.md` for Harmony’s five pillars.

## Goals

- Fast feedback, high determinism, and clear ownership per slice.
- Contract‑first verification to prevent consumer breakage.
- Evidence for gates in CI and the Knowledge Plane.

## Test Pyramid (Harmony flavor)

- Unit (majority): deterministic, in‑memory; property‑based where valuable.
- Integration: adapters to DB/HTTP/queues with emulators/containers.
- Contract: Pact (consumer/provider) and Schemathesis (fuzz/negative) for OpenAPI/JSON Schema.
- E2E/Smoke: thin happy‑path checks; preview environments mandatory for user-facing runtimes.

## Gates and Minimums

- Coverage: define repo‑wide thresholds (e.g., lines/branches) and per‑critical slice deltas. TODO: set numbers.
- Contract checks: no new breaking diffs without explicit waiver. See `architecture/governance-model.md`.
- Flake budget: zero tolerance on main; quarantine + fix policy for intermittents.
- Performance smoke: budget checks for hot paths where applicable.

## Test Data and Fixtures

- Prefer factory helpers over brittle fixtures; keep seeds deterministic (see SeedKit).
- Isolate state per test; clean DB/emulators between cases; use idempotency keys for retries.

## CI Integration

- Run unit on every push; integration/contract on PR; e2e smoke on previews; extended suites on schedule.
- Publish reports to KP; annotate PRs with failures and contract diffs.

## Ownership

- Slices own their unit/integration/contract tests under their local scope (for example `<scope>/<slice>/tests/`).
- Cross‑cutting E2E lives beside the owning runtime under `<runtime-root>/tests/`.

## Related Docs

- Governance gates: `.harmony/cognition/_meta/architecture/governance-model.md`
- Monorepo layout (tests): `.harmony/cognition/_meta/architecture/monorepo-layout.md`
- Tooling integration: `.harmony/cognition/_meta/architecture/tooling-integration.md`
- Methodology overview: `.harmony/cognition/methodology/README.md`
- Implementation guide: `.harmony/cognition/methodology/implementation-guide.md`
- Layers model: `.harmony/cognition/methodology/layers.md`
- Improve layer: `.harmony/cognition/methodology/improve-layer.md`
- Architecture overview: `.harmony/cognition/_meta/architecture/overview.md`
- Observability requirements: `.harmony/cognition/_meta/architecture/observability-requirements.md`
