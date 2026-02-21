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

## Implementation Options (Non-Prescriptive)

- Grep-based checks for banned tokens and paths
- Schema validation tests
- Registry or manifest validation
- Compile-time denial lists where applicable

## Required Repository Artifact

Maintain the SSOT banlist at:

- `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`

