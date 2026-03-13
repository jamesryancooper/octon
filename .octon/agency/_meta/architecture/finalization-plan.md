---
title: Agency Subsystem Finalization Plan
description: Phased plan to finalize the .octon/agency specification and architecture and integrate it across the harness.
---

# Agency Subsystem Finalization Plan

## Selected Context

archetype=platform/infra + developer tooling; risk_tier=B (cross-module contracts and routing); mode=full-implementation planning

## Objective

Deliver a finalized agency subsystem for `.octon/agency` that:

- has unambiguous actor taxonomy,
- has validated config contracts,
- interoperates cleanly with skills/workflows/missions,
- replaces legacy/ambiguous `subagents` artifact usage.

## Deliverables

Required documentation deliverables (this cycle):

- `.octon/agency/_meta/architecture/specification.md`
- `.octon/agency/_meta/architecture/architecture.md`
- `.octon/agency/_meta/architecture/finalization-plan.md`

Required implementation deliverables (execution cycles):

- `.octon/agency/manifest.yml`
- `.octon/agency/runtime/agents/registry.yml` (normalized)
- `.octon/agency/runtime/assistants/registry.yml` (normalized)
- `.octon/agency/runtime/teams/registry.yml` + team template/spec files
- migration/deprecation treatment for `.octon/agency/subagents/`
- validation scripts and CI checks for agency contracts

## Artifact Inventory (Target State)

```text
.octon/agency/
├── README.md
├── governance/
│   ├── CONSTITUTION.md
│   ├── DELEGATION.md
│   └── MEMORY.md
├── manifest.yml
├── runtime/
│   ├── agents/
│   │   ├── registry.yml
│   │   ├── _scaffold/template/AGENT.md
│   │   ├── _scaffold/template/SOUL.md
│   │   └── <id>/
│   │       ├── AGENT.md
│   │       └── SOUL.md
│   ├── assistants/
│   │   ├── registry.yml
│   │   ├── _scaffold/template/assistant.md
│   │   └── <id>/assistant.md
│   └── teams/
│       ├── registry.yml
│       ├── _scaffold/template/team.md
│       └── <id>/team.md
└── practices/
    └── *.md
```

## Execution Phases

### Phase 0: Baseline and Decision Lock

Goals:

- confirm architectural decisions,
- establish migration scope and fallback.

Tasks:

1. Create ADR capturing actor taxonomy decision (remove `subagents` as first-class type).
2. Catalog all references to `subagents` across `.octon/`, docs, scripts.
3. Define migration cutoff date and clean-break merge threshold.

Exit criteria:

- signed-off ADR,
- complete reference inventory,
- approved clean-break cutoff date.

### Phase 1: Spec and Schema Stabilization

Goals:

- make actor contracts machine-verifiable.

Tasks:

1. Add `.octon/agency/manifest.yml`.
2. Normalize `runtime/agents/registry.yml` fields.
3. Normalize `runtime/assistants/registry.yml` fields.
4. Add `runtime/teams/registry.yml` schema and template.
5. Define schema validation rules (YAML shape + referential integrity).

Exit criteria:

- registries parse with no schema errors,
- all referenced paths exist,
- alias and id uniqueness passes.

### Phase 2: Content Migration

Goals:

- eliminate ambiguous and duplicated actor definitions.

Tasks:

1. Classify each `subagents/` artifact as agent-equivalent, assistant-equivalent, or obsolete.
2. Move reusable content to canonical locations.
3. Update links/references to canonical files.
4. Remove `subagents/` from active topology in the same migration change set.

Exit criteria:

- no functional dependency on `subagents/`,
- no unresolved references to migrated files,
- deprecation notice present.

### Phase 3: Router and Invocation Integration

Goals:

- enforce canonical invocation model.

Tasks:

1. Update routing logic/docs to resolve actors from `agency/manifest.yml` + registries.
2. Enforce invocation policy:
   - human -> assistants/workflows/skills,
   - agent -> assistants/workflows/skills,
   - no implicit skill -> actor orchestration.
3. Add explicit policy gate for any delegator-skill exception.

Exit criteria:

- routing tests pass,
- policy violations rejected with clear messages,
- invocation docs updated.

### Phase 4: Cross-Subsystem Alignment

Goals:

- ensure agency contracts align with skills/workflows/missions.

Tasks:

1. Update workflow docs/spec where actor routing is referenced.
2. Add mission ownership rules to prevent assistant-owned durable mission state.
3. Ensure quality gates include delegated output verification.
4. Align catalog and START docs with canonical actor taxonomy.

Exit criteria:

- no taxonomy drift across docs,
- mission ownership constraints validated,
- cross-subsystem references consistent.

### Phase 5: Validation and CI Enforcement

Goals:

- prevent regression after migration.

Tasks:

1. Add automated checks:
   - schema conformance,
   - path existence and referential integrity,
   - alias uniqueness,
   - no new `subagents/` artifacts.
2. Add lint for forbidden legacy references.
3. Add integration tests for representative invocation flows.

Exit criteria:

- CI blocks invalid agency changes,
- baseline integration tests green,
- legacy guardrails active.

### Phase 6: Decommission Legacy Path

Goals:

- complete removal of deprecated artifact class.

Tasks:

1. Remove `.octon/agency/subagents/` from active topology.
2. Keep an archive note or migration log (if needed) outside active routing.

Exit criteria:

- zero runtime/doc dependency on `subagents/`,
- final topology matches specification.

## Verification Plan

### Functional Verification

- direct assistant invocation works (`@alias`),
- delegated assistant invocation works,
- agent workflow/skill invocation works,
- team composition routing works when configured.

### Contract Verification

- all registries validate,
- each id resolves to existing contract file,
- alias collisions fail validation,
- deprecation checks catch legacy references.

### Regression Verification

- representative current flows still succeed,
- migration did not break existing assistant behavior,
- documentation references remain valid.

## Rollout and Rollback

Rollout strategy:

1. Ship schema + docs first.
2. Ship migration in small PRs (registry first, content second, router third).
3. Enable strict CI checks after migration reaches parity.

Rollback strategy:

- if routing breaks, revert the full migration commit set,
- keep migration map so moved content can be re-resolved quickly,
- defer hard deletion until two green release cycles.

## Risks and Guardrails

| Risk | Guardrail |
|---|---|
| Incomplete migration causes missing routes | Build migration inventory and enforce reference checks |
| Actor sprawl reappears | Enforce canonical taxonomy and ADR-based change gate |
| Skill/actor orchestration loops | Keep no skill -> actor default policy |
| Team definitions become ad hoc | Require team schema + validation + owner |

## Open Questions to Resolve Before Full Implementation

1. Should `use team: <id>` be exposed as first-class user syntax now or deferred?
2. Do we need explicit per-actor skill allowlists in v1, or rely on skill/tool policy only?
3. Should workflows include an explicit optional `actor` step field in this cycle?
4. Are there any active references to removed legacy paths that still need clean-break remediation?
5. Which team definitions are necessary for initial rollout (if any)?

## Definition of Done

Agency subsystem is finalized when:

- canonical actor set is `agents`, `assistants`, `teams`,
- `subagents` is removed from active artifact model,
- registries and actor contracts are validated in CI,
- invocation and delegation behavior is deterministic and documented,
- cross-subsystem references are consistent and tested.
