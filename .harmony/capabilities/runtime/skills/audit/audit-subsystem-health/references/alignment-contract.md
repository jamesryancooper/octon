---
title: Alignment Contract
description: Drift contract between .harmony architecture surfaces and the audit-subsystem-health skill.
---

# Alignment Contract

## Purpose

Keep `audit-subsystem-health` synchronized with `.harmony` architecture evolution.

This contract defines:

1. Which architecture surfaces are considered drift-sensitive
2. Which skill artifacts must be reviewed or updated when those surfaces change
3. How enforcement is automated

## Watched Surfaces

Changes in any of the following paths must trigger an alignment check:

- `.harmony/START.md`
- `.harmony/README.md`
- `.harmony/harmony.yml`
- `.harmony/catalog.md`
- `.harmony/cognition/_meta/architecture/`
- `.harmony/cognition/_meta/architecture/*.index.yml`
- `.harmony/cognition/governance/`
- `.harmony/cognition/practices/`
- `.harmony/cognition/practices/methodology/*.index.yml`
- `.harmony/cognition/runtime/context/`
- `.harmony/continuity/_meta/architecture/`
- `.harmony/continuity/runs/retention.json`
- `.harmony/*/_meta/architecture/`
- `.harmony/orchestration/runtime/workflows/audit/audit-pre-release-workflow/`
- `.harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `.harmony/assurance/runtime/_ops/scripts/validate-contract-governance.sh`
- `.harmony/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- `.harmony/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- `.harmony/assurance/practices/complete.md`
- `.harmony/assurance/practices/session-exit.md`
- `.harmony/cognition/runtime/migrations/`
- `.harmony/cognition/runtime/decisions/`
- `.harmony/output/reports/decisions/`
- `.harmony/engine/governance/protocol-versioning.md`
- `.harmony/engine/governance/rules/`
- `.harmony/orchestration/runtime/workflows/meta/migrate-harness/`
- `.harmony/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh`
- `.harmony/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`

## Required Skill Artifacts

When watched surfaces change, review and update one or more of:

- `.harmony/capabilities/runtime/skills/audit/audit-subsystem-health/SKILL.md`
- `.harmony/capabilities/runtime/skills/audit/audit-subsystem-health/references/phases.md`
- `.harmony/capabilities/runtime/skills/audit/audit-subsystem-health/references/validation.md`
- `.harmony/capabilities/runtime/skills/audit/audit-subsystem-health/references/io-contract.md`
- `.harmony/capabilities/runtime/skills/audit/audit-subsystem-health/references/alignment-contract.md`
- `.harmony/capabilities/runtime/skills/registry.yml` (`audit-subsystem-health` entry)

## Versioning Rule

If skill behavior/check logic changes (for example updates to `SKILL.md` or `references/*.md`), bump the `audit-subsystem-health` version in:

- `.harmony/capabilities/runtime/skills/registry.yml`

## Enforcement

Automated enforcement lives in:

- `.harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`

Expected invocation points:

- Standalone: `bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- Structural gate (static checks): `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- Continuity memory gate: `bash .harmony/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- Framing gate: `bash .harmony/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- Pre-release gate verification (drift checks): pre-release audit workflow verify step
