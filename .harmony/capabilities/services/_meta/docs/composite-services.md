# Composite Services (Canonical)

Composite Services are a **harness-only composition concept** in Harmony.
They define higher-level capabilities by orchestrating multiple services through
typed contracts, policies, idempotency rules, and observability requirements.

This concept replaces legacy "engine" naming for harness documentation.

## Scope

- Composite Services live in:
  - `.harmony/capabilities/services/**`
- Composite Services are:
  - Declarative capability contracts and orchestration definitions.
- Composite Services are not:
  - Runtime roots.
  - External package-layer engine modules.
  - A separate code architecture layer outside the harness.

## How Composite Services Work

1. Define a service identity and path in:
   - `.harmony/capabilities/services/manifest.yml`
2. Define behavior metadata in:
   - `.harmony/capabilities/services/registry.yml`
3. Model typed inputs/outputs in service-local schemas:
   - `schema/input.schema.json`
   - `schema/output.schema.json`
4. Declare composition via dependencies:
   - `orchestrates`: downstream services this service coordinates.
   - `integratesWith`: peer services used for cross-cutting concerns.
5. Enforce runtime invariants:
   - policy enforcement mode
   - idempotency keys
   - required spans/run records
6. Expose guidance and examples:
   - `guide.md`, `runbook.md`, and `references/**`

## Composition Levels

- Atomic service:
  - Focused capability with a narrow contract (for example `guard`, `prompt`).
- Composite service:
  - Coordinates multiple services to deliver a larger capability.
- Workflow:
  - Multi-step execution procedure that invokes one or more services.

Workflows orchestrate execution over time. Composite Services define capability
boundaries and composition contracts.

Related composition primitives:

- Composite Skills:
  - `.harmony/capabilities/skills/composite-skills.md`
- Workflows:
  - `.harmony/orchestration/workflows/README.md`
- Teams:
  - `.harmony/agency/teams/README.md`

## Legacy Mapping (Engine -> Composite Service)

- PlanEngine -> planning composites:
  - `planning/spec`, `planning/plan`, `planning/playbook`
- WorkEngine -> execution composites:
  - `planning/agent`, `planning/flow`, `operations/tool`
- ContextEngine -> retrieval composites:
  - `retrieval/ingest`, `retrieval/index`, `retrieval/parse`,
    `retrieval/query`, `retrieval/search`
- GovernanceEngine -> governance and quality composites:
  - `governance/policy`, `governance/compliance`, `governance/guard`,
    `quality/eval`, `quality/test`
- ReleaseEngine -> delivery composites:
  - `delivery/patch`, `delivery/release`, `delivery/flag`,
    `delivery/notify`
- KaizenEngine -> orchestration-level improvement loops:
  - quality-gate and improvement workflows that compose planning,
    governance, quality, and delivery services

## Authoring Rules

- Use "service" and "composite service" as canonical terms.
- Treat "engine" as a deprecated alias in older notes only.
- Keep composition definitions in `.harmony`; do not introduce external
  package-layer engine references in harness docs.
