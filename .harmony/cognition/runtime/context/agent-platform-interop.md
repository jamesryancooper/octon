---
title: Agent Platform Interop Contract
description: Native-first, provider-agnostic interop semantics for optional platform adapters.
---

# Agent Platform Interop Contract

## Purpose

Define the canonical Harmony-owned semantics for optional platform interoperability.
Harmony remains fully operational with zero adapters installed.

## Contract Version

- `interop_contract_version`: `1.0.0`
- Effective date: `2026-02-14`
- Compatibility policy:
  - Major: breaking behavior or schema changes.
  - Minor: backward-compatible additive changes.
  - Patch: clarifications and corrections without behavioral break.

## Native-First Invariants

1. Native mode is mandatory and must run with zero adapters.
2. Adapters are optional extensions only.
3. Core semantics are provider-agnostic and owned by Harmony.
4. Provider-specific names, keys, and API terminology are adapter-only.
5. Failures in critical governance paths are fail-closed by default.

## Ownership Boundary (Normative)

| Capability | Harmony Core Owns | Adapter Owns |
|---|---|---|
| Session policy semantics | Scope/reset/send classes and policy invariants | Mapping to provider/session APIs |
| Context budget semantics | Budget model, thresholds, deterministic report shape | Provider token/character accounting |
| Pruning semantics | Policy classes and safety guardrails | Provider-specific pruning calls and storage internals |
| Memory and compaction semantics | Memory classes, retention, flush-before-compaction policy | Provider memory APIs and persistence backend |
| Multi-agent routing | Routing precedence and delegation rules | Session spawning/transport implementation |
| Presence contract | Heartbeat field requirements and evidence shape | Runtime signal emission |
| Governance controls | ACP gates, no-silent-apply, deny-by-default, fail-closed policy | Provider approval plumbing |

## Canonical Semantics

### Session Policy

- `scope_class`: `session | run | task`
- `reset_class`: `none | soft | hard`
- `send_class`: `append | replace | branch`

Invariants:

1. `hard` reset clears transient execution state before new send operations.
2. `replace` send must keep durable decision memory intact.
3. Policy validation is required before execution.

### Context Budget

- `warning_threshold_percent`: `80`
- `flush_threshold_percent`: `90`
- Reporting must be deterministic and include:
  - `budget_limit`
  - `budget_used`
  - `budget_used_percent`
  - `threshold_state` (`ok | warning | flush-required`)

### Pruning Policy

- `pruning_class`: `none | conservative | aggressive`
- Guardrails:
  - Never prune approved decisions.
  - Never prune unresolved blockers.
  - Preserve current task state.

### Memory and Compaction

Mandatory flush triggers:

1. Budget usage `>= 90%`.
2. Explicit compaction request.

Flush sequence:

1. Classify session artifacts.
2. Redact sensitive values.
3. Persist durable summary only.
4. Emit flush evidence artifact.

On flush failure:

- Compaction is blocked by default.
- Continue only with explicit ACP waiver and waiver evidence.

### Routing Precedence

Execution precedence order:

1. Human safety/compliance directives
2. Harness governance policy
3. Agent execution policy
4. Adapter implementation detail

### Presence Contract

Required evidence fields:

- `run_id`
- `session_id`
- `heartbeat_at`
- `mode` (`native | adapter`)
- `active_capabilities`
- `degraded_capabilities`

## Fail-Closed Fallback Rules

1. Missing or invalid session policy: block execution.
2. Missing budget telemetry in required mode: block execution.
3. Flush required but flush evidence missing: block compaction.
4. Unsupported critical capability in adapter mode: degrade deterministically and emit evidence.
5. Any adapter load failure: continue in native mode if core requirements remain satisfiable.

## Versioning Scope

1. `interop_contract_version`
  - Location: `.harmony/cognition/runtime/context/agent-platform-interop.md`
  - Scope: governance semantics and boundaries
2. `adapter_schema_version`
  - Location: `.harmony/capabilities/runtime/services/interfaces/agent-platform/schema/*.json`
  - Scope: machine-readable interop schema
3. `adapter_version`
  - Location: `.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/<id>/adapter.yml`
  - Scope: provider adapter implementation release

## Required Evidence Artifacts

- Memory flush evidence:
  - `.harmony/output/reports/analysis/<date>-memory-flush-evidence.md`
- Platform coupling baseline:
  - `.harmony/output/reports/analysis/2026-02-14-platform-coupling-baseline.md`
