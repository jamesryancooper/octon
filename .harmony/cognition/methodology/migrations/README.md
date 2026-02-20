---
title: Clean-Break Migrations
description: SSOT hub for clean-break migration doctrine, invariants, exceptions, CI gates, and banlist governance.
---

# Clean-Break Migrations

This directory defines how migrations are designed, executed, and verified in this repository.

## Purpose

Establish clean-break migrations by default: no transitional modes, no compatibility shims, and no dual systems unless an explicit exception is approved.

## Scope

A change is a migration when it changes any of the following in a way that can affect consumers (humans, tools, or internal subsystems):

- Interfaces (APIs, CLIs, file formats, schemas, manifests)
- Runtime authority or decisioning (policy engines, evaluators, routing)
- Persistence or data shape
- Configuration keys or semantics
- Directory or domain ownership (SSOT moves)

## Default Policy

All migrations are CLEAN-BREAK unless an exception is approved under `exceptions.md`.

## Required Artifacts

Every migration must include:

- A plan based on `/.harmony/scaffolding/runtime/templates/migrations/template.clean-break-migration.md`
- Verification evidence (tests, logs, receipts) linked from the plan
- Banlist updates in `legacy-banlist.md` when legacy identifiers, paths, or keys are removed

## Companion Documents

- `doctrine.md`
- `invariants.md`
- `exceptions.md`
- `ci-gates.md`
- `legacy-banlist.md`

## Active Migration Records

- `2026-02-20-agency-bounded-surfaces/plan.md`
- `2026-02-20-orchestration-bounded-surfaces/plan.md`
- `2026-02-20-capabilities-bounded-surfaces/plan.md`
- `2026-02-20-assurance-bounded-surfaces/plan.md`
- `2026-02-20-scaffolding-bounded-surfaces/plan.md`
- `2026-02-20-engine-bounded-surfaces/plan.md`
