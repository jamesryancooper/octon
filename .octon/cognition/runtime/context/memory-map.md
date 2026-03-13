---
title: Memory Map
description: Routing map for memory classes across policy, continuity state, and cognition knowledge surfaces.
---

# Memory Map

This document prevents duplicated memory surfaces by clarifying canonical ownership and storage paths.

## Canonical Memory Routing

| Memory Concern | Canonical Location | Notes |
|---|---|---|
| Memory policy (classes, retention, redaction) | `.octon/agency/governance/MEMORY.md` | Governs what may be retained and how. |
| Session continuity and active work state | `.octon/continuity/{log.md,tasks.json,entities.json,next.md}` | Operational memory for handoff and resumption. |
| Run evidence memory lifecycle | `.octon/continuity/runs/retention.json` and `.octon/continuity/_meta/architecture/runs-retention.md` | Retention classes and lifecycle actions for run receipts/digests. |
| Shared context and operational guidance | `.octon/cognition/runtime/context/*.md` | Durable reference material and guardrails. |
| Durable architecture decisions (ADRs) | `.octon/cognition/runtime/decisions/*.md` and `.octon/cognition/runtime/context/decisions.md` | ADR files are append-only; the context summary is generated from ADR metadata. |
| System knowledge graph contracts | `.octon/cognition/runtime/knowledge/*` | System behavior/traceability knowledge, not task state. |
| Compaction evidence artifacts | `.octon/output/reports/analysis/<date>-memory-flush-evidence.md` | Required when flush/compaction occurs. |

## Boundary Rules

- Do not create a parallel source-of-truth memory surface under `cognition/` without an ADR.
- Keep active execution state in `continuity/`, not in ad hoc cognition files.
- Keep memory policy in Agency governance, not runtime context notes.
- Use cognition runtime context for discoverability and routing, not as a duplicate state ledger.

## When To Read

Read this file before:

- proposing any new "memory" directory or artifact type,
- deciding where new durable context should be persisted,
- updating memory retention or compaction behavior.
