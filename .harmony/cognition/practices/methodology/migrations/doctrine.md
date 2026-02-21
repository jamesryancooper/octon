---
title: Clean-Break Migration Doctrine
description: Default migration doctrine requiring single-authority clean-break changes without compatibility layers.
---

# Clean-Break Migration Doctrine

## 0) Terms

- Clean-break migration: a migration where the old system is fully removed and the new system is the only active authority at merge time.
- Compatibility shim: any adapter, translator, or fallback that allows legacy inputs or paths to keep working.
- Dual-mode: any state where both old and new implementations exist and can be exercised at runtime.

## 1) Primary Rule

All migrations are clean-break by default.

## 2) Non-Negotiable Constraints (MUST)

1. Single authority: after merge, there must be exactly one authoritative implementation for the migrated domain or behavior.
2. No dual execution: the codebase must not contain runtime paths that select between old and new behavior.
3. No compatibility shims: the codebase must not include adapters, translators, aliasing layers, or silent fallbacks for the legacy system.
4. No transitional flags: feature flags, env vars, config toggles, or temporary modes used to preserve legacy behavior are prohibited.
5. Removal is part of the migration: old code, docs, schemas, configs, tests, and call-sites must be removed in the same migration.
6. No silent behavior preservation: if behavior must remain similar, it must be reimplemented explicitly in the new system, not bridged.
7. Fail-closed on ambiguity: if migration state is unclear, the system must fail closed with no implicit fallback to legacy.

## 3) Required Verification (MUST)

A migration is incomplete unless it proves:

- No remaining references to legacy identifiers or paths (see `ci-gates.md`)
- No remaining legacy execution paths (tests or routing assertions)
- Docs and contracts reflect only the new model
- CI enforces regression prevention so legacy surfaces cannot reappear

## 4) Merge Rule (MUST)

A migration branch must not merge until:

- The plan definition of done is satisfied
- CI gates pass

## 5) Exception Policy

Exceptions are rare and controlled. See `exceptions.md`.

