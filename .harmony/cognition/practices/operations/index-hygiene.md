---
title: Index Hygiene Runbook
description: Procedure for keeping cognition discovery indexes accurate and fail-closed.
---

# Index Hygiene Runbook

## Purpose

Maintain index integrity across cognition runtime, governance, and practices surfaces.

## Scope

- `/.harmony/cognition/runtime/**/index.yml`
- `/.harmony/cognition/governance/**/index.yml`
- `/.harmony/cognition/practices/**/index.yml`
- sidecar indexes (`*.index.yml`) where applicable

## Procedure

1. Update the closest local `index.yml` whenever adding, moving, or removing canonical docs.
2. Keep index paths relative and resolvable from the index directory.
3. Keep `id`, `summary`, and `when` fields precise and non-duplicative.
4. For sidecar indexes, verify headings exist in the source markdown.
5. Run:
   - `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
6. Fix all index/path integrity failures before merge.

## Guardrails

- Do not rely on implicit directory walking for discovery.
- Do not keep duplicate index entries for the same canonical artifact.
