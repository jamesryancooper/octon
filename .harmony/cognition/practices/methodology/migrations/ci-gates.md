---
title: CI Gates for Clean-Break Migrations
description: Required CI controls that prevent reintroduction of legacy systems after clean-break migrations.
---

# CI Gates for Clean-Break Migrations

## Purpose

Prevent reintroduction of legacy systems after clean-break migrations.

## Required Gates (MUST)

1. Legacy identifier banlist
   - CI must fail if banned legacy identifiers or paths reappear.
   - The banlist must be updated as part of each migration.
2. Legacy entrypoint removal
   - CI must fail if legacy commands, APIs, or routes remain registered.
3. Contract enforcement
   - CI must fail if schemas or manifests accept legacy keys or legacy enum variants.
4. No dual-mode logic
   - CI should detect old or new branching patterns through targeted checks.
5. Migration record surface split
   - CI must fail if dated migration records appear under:
     - `/.harmony/cognition/practices/methodology/migrations/`
   - CI must require runtime migration discovery index at:
     - `/.harmony/cognition/runtime/migrations/index.yml`
6. Migration evidence bundle contract
   - CI must fail if flat migration evidence files appear at:
     - `/.harmony/output/reports/migrations/*.md` (date-prefixed evidence file form)
   - CI must fail if any migration evidence bundle directory is missing required files:
     - `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, `inventory.md`
7. Context governance clean-break enforcement
   - CI must fail if deprecated compatibility aliases reappear:
     - `operation.target.instruction_layers`
     - `operation.target.context_acquisition`
     - `operation.target.context_overhead_ratio`
   - CI must fail if policy wrapper logic restores legacy receipt/digest fallback expressions:
     - `latest_receipt // .receipt`
     - `latest_digest // .digest`
   - CI must run harness checks that enforce instruction-layer and context-acquisition gates:
     - `validate-developer-context-policy.sh`
     - `validate-context-overhead-budget.sh`

## Implementation Options (Non-Prescriptive)

- Grep-based checks for banned tokens and paths
- Schema validation tests
- Registry or manifest validation
- Compile-time denial lists where applicable

## Required Repository Artifact

Maintain the SSOT banlist at:

- `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`

Maintain the canonical runtime migration index at:

- `/.harmony/cognition/runtime/migrations/index.yml`
