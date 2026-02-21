---
title: AI Agent Instructions for Clean-Break Migrations
description: Agent operating rules for executing clean-break migrations without compatibility layers or dual execution paths.
---

# AI Agent Instructions: Clean-Break Migrations

You are working in a repository where migrations are clean-break by default.

## Operating Mode

- Treat any interface, contract, or authority change as a migration.
- Do not preserve legacy behavior via shims, adapters, flags, aliasing, or fallbacks.

## Hard Constraints (MUST)

1. Remove legacy implementations entirely.
2. Ensure exactly one authoritative path remains after changes.
3. Delete legacy docs, schemas, tests, and call-sites.
4. Update CI to prevent legacy reintroduction.

## Prohibited (MUST NOT)

- Dual execution paths (old versus new)
- Compatibility shims, adapters, or translators
- Transitional feature flags or toggles
- Leaving legacy code in place just in case
- Silent mapping of old config to new config

## Required Outputs (MUST)

- Create or update a migration plan from `/.harmony/scaffolding/runtime/templates/migrations/template.clean-break-migration.md`
- Update `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`
- Provide verification evidence (test output, logs, receipts)

## If an Exception Is Required

Stop and produce an exception request aligned with:

- `/.harmony/cognition/practices/methodology/migrations/exceptions.md`

