---
title: Promotable Slice Decomposition
description: Canonical pattern for splitting governance-complete delivery into ACP-promotable slices.
status: Active
---

# Promotable Slice Decomposition

Use this pattern when one mission would otherwise violate small-diff flow.

## Promotable Slice Definition

A promotable slice is a receipt-linked unit evaluated independently at ACP
promote gate, containing:

- code/config change scoped to one concern
- minimal required docs for that concern (`docs.spec`, `docs.adr`, `docs.runbook`)
- required tests/evidence for that concern
- rollback handle and receipt linkage

Completeness is per-slice, not per-epic.

## Canonical Three-Slice Pattern

1. Slice A: contract/spec scaffolding (stage then promote)
- artifacts: contract/schema, spec/ADR skeleton, initial tests
- goal: establish compatibility and guardrails before behavior rollout

2. Slice B: implementation promote
- artifacts: behavior change, contract-conformant tests, rollback handle
- goal: ship bounded runtime behavior with required evidence

3. Slice C: observability and hardening promote
- artifacts: telemetry profile evidence, operational runbook updates, cleanup
- goal: finalize operational readiness and remove temporary scaffolding

## Waiver Use

If a slice exceeds default small-diff guidance, use a receipted waiver only when:

- decomposition plan exists and is linked in receipt evidence
- waiver is time-boxed, reason-coded, and owner-bound
- non-waivable controls remain enforced

Waiver taxonomy is canonical at [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md).
