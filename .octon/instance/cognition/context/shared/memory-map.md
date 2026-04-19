---
title: Memory Map
description: Routing map for memory classes across policy, continuity state, and cognition knowledge surfaces.
---

# Memory Map

This document prevents duplicated memory surfaces by clarifying canonical ownership and storage paths.

## Canonical Memory Routing

| Memory Concern | Canonical Location | Notes |
|---|---|---|
| Memory policy (classes, retention, redaction) | `.octon/framework/execution-roles/governance/MEMORY.md` | Governs what may be retained and how. |
| Repo continuity and cross-scope active work state | `.octon/state/continuity/repo/{log.md,tasks.json,entities.json,next.md}` | Operational handoff state for repo-wide and cross-scope work. |
| Scope continuity and scope-local active work state | `.octon/state/continuity/scopes/<scope-id>/{log.md,tasks.json,entities.json,next.md}` | Operational handoff state for stable single-scope work. |
| Run evidence memory lifecycle | `.octon/state/evidence/runs/retention.json` and `.octon/framework/cognition/_meta/architecture/state/continuity/runs-retention.md` | Retention classes and lifecycle actions for run receipts and digests. |
| Operational decision evidence lifecycle | `.octon/state/evidence/decisions/repo/retention.json` and `.octon/framework/cognition/_meta/architecture/state/continuity/decisions-retention.md` | Retention classes and lifecycle actions for operational allow/block/escalate records. |
| Mutable publication and quarantine control state | `.octon/state/control/**` | Actual extension activation and quarantine state plus locality quarantine truth. |
| Shared context and operational guidance | `.octon/instance/cognition/context/shared/*.md` | Durable reference material and guardrails. |
| Durable architecture decisions (ADRs) | `.octon/instance/cognition/decisions/*.md` | ADR files are append-only and remain the only durable decision authority. |
| Generated ADR summary | `.octon/generated/cognition/summaries/decisions.md` | Derived, non-authoritative readable summary generated from ADR metadata. |
| System knowledge graph contracts | `.octon/instance/cognition/context/shared/knowledge/*` | System behavior/traceability knowledge, not task state. |
| Compaction evidence artifacts | `.octon/state/evidence/validation/analysis/<date>-memory-flush-evidence.md` | Required when flush/compaction occurs. |

## Boundary Rules

- Do not create a parallel source-of-truth memory surface under `cognition/` without an ADR.
- Keep active execution state in `state/continuity/**`, not in ad hoc cognition files.
- Keep retained run and operational decision evidence in `state/evidence/**`, not in continuity ledgers or cognition notes.
- Keep mutable actual/quarantine publication state in `state/control/**`, not in authored configuration files.
- Keep memory policy in Agency governance, not runtime context notes.
- Use `instance/cognition/context/shared/` for discoverability and routing,
  not as a duplicate state ledger or generated summary surface.

## When To Read

Read this file before:

- proposing any new "memory" directory or artifact type,
- deciding where new durable context should be persisted,
- updating memory retention or compaction behavior.
