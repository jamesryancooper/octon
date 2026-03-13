---
title: Foundational Planes Integration
description: Canonical integration contract for Octon foundational planes, retained at a legacy path for compatibility.
---

# Foundational Planes Integration

This file is retained at `three-planes-integration.md` for link compatibility.
The canonical model is now a **foundational nine-plane model**.

Octon separates concerns into nine foundational planes while keeping explicit
integration and ownership boundaries.

## Plane Roles

| Plane | Core Question | Primary Surface |
|---|---|---|
| Execution Kernel Plane | How is executable work dispatched? | `.octon/engine/runtime/` |
| Service Plane | What typed runtime operations exist? | `.octon/capabilities/runtime/services/` |
| Ingress Plane | How does human intent enter the system? | `.octon/capabilities/runtime/commands/` |
| Capability Plane | What atomic execution units are available? | `.octon/capabilities/runtime/skills/` |
| Orchestration Plane | How are multi-step missions sequenced? | `.octon/orchestration/runtime/workflows/` |
| Assurance Plane | What must pass before completion? | `.octon/assurance/{runtime,practices}/` |
| Continuity Plane | What happened, why did it happen, and what is next? | `.octon/continuity/{log.md,tasks.json,entities.json,next.md,decisions/,runs/}` |
| Knowledge Plane | What durable system context and decisions exist? | `.octon/cognition/runtime/{context,decisions,evidence,evaluations,projections,knowledge-plane}/` |
| Artifact Plane | What durable deliverables/evidence are produced? | `.octon/output/` (with optional artifact compilation architecture under `/.octon/cognition/_meta/architecture/artifact-surface/`) |

## Plane Boundaries

- Execution Kernel owns runtime dispatch and execution shims. It does not own workflow intent, policy, or knowledge contracts.
- Service owns operation contracts and typed runtime interfaces. It does not own human command semantics or task continuity.
- Ingress owns slash-command intake and routing. It does not own execution internals.
- Capability owns reusable atomic skills and their execution contracts. It does not own mission sequencing.
- Orchestration owns workflow sequencing and coordination. It does not own low-level interface execution.
- Assurance owns gates, validation profiles, and completion criteria. It does not own product/runtime behavior itself.
- Continuity owns active operational memory and handoff state.
- Knowledge owns durable context, architectural decisions, evidence indexes, and cross-reference contracts.
- Artifact owns durable outputs and evidence bundles consumed by audits, decision records, and downstream consumers.

## Artifact Surface Note

`/.octon/cognition/_meta/architecture/artifact-surface/` defines the artifact compiler architecture used by the Artifact Plane. Runtime overlays in that surface are optional implementation layers; Artifact Plane ownership remains foundational.

## Integration Contract

### Ingress -> Orchestration -> Capability

- Commands MUST resolve deterministically to workflow and/or capability contracts.
- Workflow steps SHOULD be expressed as composition over capabilities, not ad hoc shell behavior.

### Capability -> Service -> Execution Kernel

- Capabilities SHOULD call typed service interfaces for deterministic behavior.
- Services MUST route executable work through the execution kernel.

### Execution + Orchestration -> Artifact

- Material runs MUST emit durable artifacts/evidence when required by workflow/assurance contracts.
- Artifact outputs SHOULD be discoverable by stable paths for audits and replay.

### Execution + Orchestration -> Continuity

- Material outcomes SHOULD be appended to `log.md`.
- Active and blocked work MUST be represented in `tasks.json` and reflected in `next.md`.
- Material routing and authority decisions SHOULD be stored in
  `continuity/decisions/` following retention policy.
- Run receipts/digests SHOULD be stored in `continuity/runs/` following retention policy.

### Knowledge <-> Continuity

- Continuity SHOULD link to relevant knowledge artifacts (specs, decisions, evidence indexes) for active work.
- Knowledge SHOULD preserve durable context/decision artifacts referenced by continuity state transitions.

### Assurance Across All Planes

- Assurance checks MUST validate structural coherence across ingress, orchestration, capabilities, services, continuity, knowledge, and artifacts.
- Completion MUST be gated on declared assurance criteria, not inferred from partial evidence.

## Data Flow

```text
Ingress -> Orchestration -> Capability -> Service -> Execution Kernel
                                         |                 |
                                         v                 v
                                    Artifact outputs   Runtime outcomes
                                         |                 |
                                         v                 v
                                      Assurance <------ Continuity
                                         |
                                         v
                                      Knowledge
```

## Consistency Requirements

- Command/workflow/skill/service registries must stay route-consistent.
- Artifact outputs required by assurance gates must exist and remain discoverable.
- `next.md` must only reference active, unblocked tasks from `tasks.json`.
- `entities.json` ownership should align with task ownership when work is entity-specific.
- `log.md` entries should provide enough context to understand why task/entity state changed.
- `decisions/` artifacts should remain append-oriented and must not replace task
  or workflow state.
- `runs/` artifacts should map to retention classes and must not replace active task-state tracking surfaces.
- Knowledge decision/evidence indexes and artifact outputs must remain cross-referenceable from continuity and assurance artifacts.

## Anti-Patterns

- Treating foundational planes as interchangeable folders instead of ownership contracts.
- Bypassing typed service/capability/orchestration contracts with ad hoc execution paths.
- Treating continuity files as optional notes instead of operational state.
- Allowing task progression without corresponding continuity and assurance evidence.
- Treating artifact runtime overlays as a replacement for canonical artifact evidence.

## Related Docs

- `.octon/continuity/_meta/architecture/continuity-plane.md`
- `.octon/cognition/runtime/knowledge/knowledge.md`
- `.octon/cognition/_meta/architecture/artifact-surface/README.md`
- `.octon/START.md`
