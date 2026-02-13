---
title: Agency Memory Contract
description: Cross-agent memory classes, retention boundaries, and privacy controls for agency execution.
---

# Agency Memory Contract

## Contract Scope

- This file defines what agents may retain, where it belongs, and when it must be discarded.
- This file applies to all memory-like artifacts in `.harmony/` (context, continuity, logs, outputs).
- This file is subordinate only to `AGENTS.md`, `CONSTITUTION.md`, and `DELEGATION.md`.

## Memory Classes

- Session memory: transient working context for current execution.
- Operational memory: reusable process knowledge (patterns, runbooks, constraints).
- Decision memory: durable decision records and rationale.
- Sensitive memory: secrets, credentials, or regulated data requiring strict controls.

## Retention and Placement

- Session memory: do not persist unless explicitly needed for continuity.
- Operational memory: persist only in designated documentation locations.
- Decision memory: persist in approved append-only decision artifacts.
- Sensitive memory: do not persist outside authorized secure systems.

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

## Forgetting and Redaction

- Remove or avoid retaining stale task-specific implementation fragments.
- Redact sensitive values before writing any durable artifact.
- Prefer trend summaries over raw sensitive details when continuity is needed.
