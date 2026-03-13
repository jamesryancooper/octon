---
title: Validation Reference
description: Acceptance criteria for the spec-to-implementation skill.
---

# Validation Reference

## Required Contract Checks

1. `Profile Selection Receipt` exists before implementation details.
2. Exactly one `change_profile` is selected.
3. `release_state` is derived from semantic version inputs.
4. Hard-gate fact collection is explicit (downtime, coordination, migration/backfill, rollback, blast radius, compliance).
5. Pre-1.0 transitional selection includes complete `transitional_exception_note`.
6. Tie-break ambiguity is escalated (not silently resolved).

## Required Output Sections

Plans must include all top-level sections:

- `Profile Selection Receipt`
- `Implementation Plan`
- `Impact Map (code, tests, docs, contracts)`
- `Compliance Receipt`
- `Exceptions/Escalations`

## Requirements Coverage

- Every requirement from the spec maps to at least one implementation task.
- Every task maps back to at least one requirement.
- No orphan tasks and no orphan requirements.

## Task Quality

- Tasks are independently deliverable and testable.
- Task dependencies are explicit and acyclic.
- Risks and mitigations are documented.

## Verification Checklist

1. Plan exists at `.octon/output/plans/YYYY-MM-DD-*-implementation-plan.md`.
2. Profile receipt contains `change_profile`, `release_state`, and hard-gate facts.
3. If `pre-1.0` + `transitional`, exception note contains: `rationale`, `risks`, `owner`, `target_removal_date`.
4. Required five top-level sections are present.
5. Log exists at `_ops/state/logs/spec-to-implementation/{{run_id}}.md`.
