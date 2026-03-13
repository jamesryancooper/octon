---
title: Continuity Runs Retention
description: Canonical lifecycle, retention classes, and handling rules for continuity run evidence artifacts.
---

# Continuity Runs Retention

`/.octon/continuity/runs/` stores append-oriented operational run evidence.
Retention policy exists so this evidence remains trustworthy, debuggable, and useful as the harness evolves.

## Scope

This contract governs lifecycle handling for:

- run receipt bundles,
- run digests,
- ACP/gate evidence artifacts.

It does not redefine task or handoff state ownership.

## Canonical Policy Source

- `/.octon/continuity/runs/retention.json`

## Retention Classes

| Class | Typical Prefixes | Retention | Action |
|---|---|---|---|
| `governance_evidence` | `audit*`, `runtime-acp*`, `runtime-soft-delete-*`, `runtime-agent-quorum-`, `docs-gate-`, `snippet-emit-` | 365 days | Archive |
| `operational_debug` | `debug-`, `run-` | 30 days | Prune |
| `scratch` | `tmp-` | 7 days | Prune |

## Rules

- Every run directory MUST match a retention class prefix.
- Top-level non-directory files under `runs/` MUST be listed in `always_keep_files`.
- Retention policy changes MUST be reviewed as governance-affecting changes.
- Never store secrets or regulated data in run artifacts.
- Material ACP runs SHOULD retain instruction-layer manifest and context-acquisition telemetry evidence for the retention window.

## Enforcement

Enforced by:

- `/.octon/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`

Recommended during architecture checks:

- `bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`
