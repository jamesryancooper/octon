---
title: Service Run Records
scope: harness
applies_to: services
---

# Service Run Records

Run records are canonical execution artifacts for reproducibility, auditability, and idempotency replay.

## Canonical Record Shape

Core fields:

- Identity: `runId`, `service name`, `version`
- Inputs: sanitized `inputs` (sensitive keys redacted)
- Outcome: `status`, `summary`, `durationMs`
- Methodology: `stage`, `risk`, optional `acp`
- Telemetry: `telemetry.trace_id`, optional `telemetry.spans`
- Determinism: optional `determinism.prompt_hash`, `idempotencyKey`, `inputsHash`, `cacheKey`
- Replay: optional `outputs`
- Time: `createdAt`

Required context-governance telemetry:

- `instruction_layers`: array with at least `provider`, `system`, `developer`, `user` layer entries.
- `context_acquisition.file_reads`: integer `>= 0`
- `context_acquisition.search_queries`: integer `>= 0`
- `context_acquisition.commands`: integer `>= 0`
- `context_acquisition.subagent_spawns`: integer `>= 0`
- `context_acquisition.duration_ms`: integer `>= 0`
- `context_overhead_ratio`: number `>= 0`

These fields are required for material runs that emit ACP receipts/digests.

## Lifecycle

1. Create run context at service entry.
2. Execute operation and capture output/failure.
3. Persist record to runs directory (`runs/<service>/<runId>.json`) using best-effort safety for non-critical write paths.
4. Index/query by trace ID or idempotency key when needed.
5. Apply retention cleanup separately.

## Enumerations

- `status`: `success | failure`
- `stage`: `spec | plan | implement | verify | ship | operate | learn`
- `risk`: `trivial | low | medium | high`

## Redaction Rules

Sensitive input key patterns include (case-insensitive):

- `api_key`, `secret`, `password`, `token`, `auth`, `credential`, `private_key`, `access_key`

Matched values must be replaced with `"<REDACTED>"` in persisted records.

## Context Overhead Classification

- `context_overhead_ratio < 0.20`: within target budget
- `0.20 <= context_overhead_ratio < 0.35`: warning tier
- `0.35 <= context_overhead_ratio < 0.50`: soft-fail tier
- `context_overhead_ratio >= 0.50`: hard-fail tier
