---
title: Index Hygiene Runbook
description: Procedure for keeping cognition discovery indexes accurate and fail-closed.
---

# Index Hygiene Runbook

## Purpose

Maintain index integrity across cognition runtime, governance, and practices surfaces.

## Scope

- `/.octon/cognition/index.yml`
- `/.octon/cognition/runtime/**/index.yml`
- `/.octon/cognition/governance/**/index.yml`
- `/.octon/cognition/practices/**/index.yml`
- `/.octon/cognition/_meta/**/index.yml`
- sidecar indexes (`*.index.yml`) where applicable

## Procedure

1. Update the closest local `index.yml` whenever adding, moving, or removing canonical docs.
2. Keep index paths relative and resolvable from the index directory.
3. Keep `id`, `summary`, and `when` fields precise and non-duplicative.
4. For sidecar indexes, verify headings exist in the source markdown.
5. For generated runtime artifacts, run sync instead of manual edits:
   - `bash .octon/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
6. Run:
   - `bash .octon/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`
   - `bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
7. Fix all index/path integrity failures before merge.

## Guardrails

- Do not rely on implicit directory walking for discovery.
- Do not keep duplicate index entries for the same canonical artifact.
