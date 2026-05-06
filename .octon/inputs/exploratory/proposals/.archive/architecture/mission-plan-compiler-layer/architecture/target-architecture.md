# Target Architecture

## Executive Decision

Adopt an optional **Mission Plan Compiler** layer as a subordinate preparation
surface between mission authority and run-contract/action-slice execution. The
layer may help an orchestrator decompose approved mission work into bounded,
evidence-backed candidates. It must not decide what Octon is allowed to do and
must not authorize material effects.

## Target Flow

```text
Mission authority
-> MissionPlan candidate
-> PlanNode decomposition
-> dependency, risk, assumption, and decision mapping
-> readiness checks
-> action-slice candidates
-> run-contract drafts
-> context-pack request
-> authorization request
-> execution through existing run lifecycle
-> plan revision from retained evidence
```

Forbidden flow:

```text
MissionPlan -> direct execution
```

## Canonical Meaning

The planning layer is a compiler-style preparation layer. Its durable meaning
should be promoted into:

- framework runtime doctrine and schemas for `MissionPlan`, `PlanNode`,
  dependency edges, revision records, compile receipts, and drift records
- a mission workflow that derives and checks plans before action-slice
  candidate compilation
- validator coverage for placement, readiness, stale plans, duplicate work,
  dependency cycles, generated/input authority misuse, and authorization
  non-bypass
- optional instance policy that enables or disables hierarchical planning and
  sets budgets

The layer reuses existing mission, action-slice, run-contract, context-pack,
authorization, evidence, replay, rollback, and support-target surfaces.

## Placement

```text
Durable doctrine and schemas:
  .octon/framework/engine/runtime/spec/**

Mission workflow:
  .octon/framework/orchestration/runtime/workflows/missions/derive-mission-plan/**

Optional instance policy:
  .octon/instance/governance/policies/hierarchical-planning.yml

Mission-bound mutable planning state:
  .octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/**

Plan mutation evidence:
  .octon/state/evidence/control/execution/planning/<plan-id>/**

Run execution evidence:
  .octon/state/evidence/runs/<run-id>/**

Mission continuity:
  .octon/state/continuity/repo/missions/<mission-id>/**

Generated operator planning views:
  .octon/generated/cognition/projections/materialized/planning/**
```

## Non-Goals

- no second orchestrator
- no plan-owned execution queue
- no plan-as-authority semantics
- no generic project-management board
- no free-text `AtomicAction` runtime primitive
- no runtime dependency on proposal paths or raw input paths
- no generated dashboard that satisfies control or evidence requirements

## Required Boundary Properties

The promoted implementation must prove:

- mission binding is digest-backed and stale-plan aware
- PlanNodes compile only to candidates, never direct effects
- leaves reuse `action-slice-v1` rather than inventing executable free text
- high-risk or scope-changing work escalates before compile-to-run
- generated planning projections are derived-only
- run replay reconstructs from Run Journal first
- rollback truth remains in run control and run evidence
