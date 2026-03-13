---
title: Agency Memory Contract
description: Cross-agent memory classes, retention boundaries, and privacy controls for agency execution.
---

# Agency Memory Contract

## Contract Scope

- This file defines what agents may retain, where it belongs, and when it must be discarded.
- This file applies to all memory-like artifacts in `.octon/` (context, continuity, logs, outputs).
- This file is subordinate only to `AGENTS.md`, `CONSTITUTION.md`, and `DELEGATION.md`.
- Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Memory Classes

- Session memory: transient working context for current execution.
- Operational memory: reusable process knowledge (patterns, runbooks, constraints).
- Decision memory: durable decision records and rationale.
- Run evidence memory: append-oriented execution evidence (receipts, digests, counters).
- Sensitive memory: secrets, credentials, or regulated data requiring strict controls.

## Retention and Placement

- Session memory: do not persist unless explicitly needed for continuity.
- Operational memory: persist only in designated documentation locations.
- Decision memory: persist in approved append-only decision artifacts.
- Run evidence memory: persist in continuity run-evidence paths and follow declared retention classes.
- Sensitive memory: do not persist outside authorized secure systems.

For profile-governed work, run evidence memory MUST include:

- `change_profile`
- `release_state`
- profile-selection facts
- rationale for selected profile
- `transitional_exception_note` when required

## Privacy and Safety Constraints

- Never store secrets in logs, reports, or contract files.
- Minimize retained personal or regulated data.
- Respect human-led autonomy boundaries and scoped-access rules.
- When unsure about sensitivity, treat data as sensitive and escalate.

## Memory Update Rules

- Write durable updates only when they improve future correctness or safety.
- Keep updates factual, concise, and attributable.
- Do not rewrite historical append-only records outside allowed policies.
- Record assumptions when memory is incomplete or uncertain.
- For migration/governance work, store a `Profile Selection Receipt` before implementation evidence.

## Compaction and Flush Policy

- Context usage warning threshold: `>= 80%`.
- Mandatory memory flush threshold: `>= 90%` or explicit compaction request.
- Required flush sequence:
  - classify session artifacts,
  - redact sensitive values,
  - persist durable summary only,
  - emit flush evidence artifact.
- Flush evidence artifact path:
  - `.octon/output/reports/analysis/<date>-memory-flush-evidence.md`.
- Flush failure behavior:
  - default is fail-closed (block compaction),
  - only continue with explicit ACP waiver and waiver evidence.

## Forgetting and Redaction

- Remove or avoid retaining stale task-specific implementation fragments.
- Redact sensitive values before writing any durable artifact.
- Prefer trend summaries over raw sensitive details when continuity is needed.
