---
title: Audit Findings Contract
description: Stable identity, lifecycle, and acceptance criteria contract for bounded audit findings.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/authority-crosswalk.md"
---

# Audit Findings Contract

## Finding ID Rule

Finding IDs must be deterministic.

Recommended format:

`AUD-<taxonomy>-<location_hash>-<predicate_hash>`

Where:

- `taxonomy` is a declared taxonomy key,
- `location_hash` is hash of normalized file path + line predicate,
- `predicate_hash` is hash of normalized violation predicate.

## Required Finding Fields

Each finding in `findings.yml` must include:

- `id`
- `taxonomy`
- `severity`
- `status` (`open`, `resolved`, `accepted-backlog`, `invalidated`)
- `location` (path and line predicate)
- `predicate` (exact machine-checkable rule that failed)
- `acceptance_criteria` (objective checks required for resolution)
- `evidence_refs` (bundle-local pointers)
- `introduced_in` (first run id)
- `last_seen_in` (latest run id)

## Lifecycle Rules

1. New evidence of same predicate/location reuses existing `id`.
2. `status=resolved` requires all acceptance criteria passing.
3. `status=accepted-backlog` requires explicit rationale and non-blocking severity.
4. `status=invalidated` requires disproval evidence and run reference.

## Acceptance Criteria Requirements

Acceptance criteria must be objective, verifiable, and preferably automated.

Examples:

- unit/integration test name,
- static rule identifier,
- schema validation command,
- CI gate ID.

Narrative-only acceptance criteria are non-compliant for blocking findings.

## Run Receipt Contract

Each run contributing to findings state must emit receipt metadata in `convergence.yml` or `validation.md`:

- `run_id`
- `commit_sha`
- `scope_hash`
- `prompt_hash`
- `seed` or `seed_unsupported: true`
- `params_hash`
- `system_fingerprint` or `fingerprint_unsupported: true`
- `findings_hash`
