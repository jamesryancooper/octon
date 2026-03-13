---
title: Alignment Contract
description: Drift contract between .octon architecture surfaces and the audit-subsystem-health skill.
---

# Alignment Contract

## Purpose

Keep `audit-subsystem-health` synchronized with `.octon` architecture evolution.

Current bootstrap alignment expectation:

- repo-level `/init` now authors canonical bootstrap governance inside
  `/.octon/`, including `/.octon/AGENTS.md`, `/.octon/OBJECTIVE.md`, and
  the machine-readable intent contract at
  `/.octon/cognition/runtime/context/intent.contract.yml`
- repo-root `AGENTS.md` and `CLAUDE.md` are ingress adapters to
  `/.octon/AGENTS.md`, not hand-maintained authority surfaces
- canonical bootstrap assets live under `.octon/scaffolding/runtime/bootstrap/`
  and projected harness copies must stay in sync with that source
- when watched architecture surfaces change bootstrap or onboarding behavior,
  this skill's references must continue to reflect that self-contained bootstrap
  model

This contract defines:

1. Which architecture surfaces are considered drift-sensitive
2. Which skill artifacts must be reviewed or updated when those surfaces change
3. How enforcement is automated

## Watched Surfaces

Changes in any of the following paths must trigger an alignment check:

- `.octon/START.md`
- `.octon/README.md`
- `.octon/octon.yml`
- `.octon/catalog.md`
- `.octon/cognition/_meta/architecture/`
- `.octon/cognition/_meta/architecture/*.index.yml`
- `.octon/cognition/governance/`
- `.octon/cognition/practices/`
- `.octon/cognition/practices/methodology/*.index.yml`
- `.octon/cognition/runtime/context/`
- `.octon/continuity/_meta/architecture/`
- `.octon/continuity/runs/retention.json`
- `.octon/*/_meta/architecture/`
- `.octon/orchestration/runtime/workflows/audit/audit-pre-release/`
- `.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-contract-governance.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-bootstrap-projections.sh`
- `.octon/assurance/practices/complete.md`
- `.octon/assurance/practices/session-exit.md`
- `.octon/cognition/runtime/migrations/`
- `.octon/cognition/runtime/decisions/`
- `.octon/output/reports/decisions/`
- `.octon/engine/governance/protocol-versioning.md`
- `.octon/engine/governance/rules/`
- `.octon/orchestration/runtime/workflows/meta/migrate-harness/`
- `.octon/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`

## Required Skill Artifacts

When watched surfaces change, review and update one or more of:

- `.octon/capabilities/runtime/skills/audit/audit-subsystem-health/SKILL.md`
- `.octon/capabilities/runtime/skills/audit/audit-subsystem-health/references/phases.md`
- `.octon/capabilities/runtime/skills/audit/audit-subsystem-health/references/validation.md`
- `.octon/capabilities/runtime/skills/audit/audit-subsystem-health/references/io-contract.md`
- `.octon/capabilities/runtime/skills/audit/audit-subsystem-health/references/alignment-contract.md`
- `.octon/capabilities/runtime/skills/registry.yml` (`audit-subsystem-health` entry)

## Versioning Rule

If skill behavior/check logic changes (for example updates to `SKILL.md` or `references/*.md`), bump the `audit-subsystem-health` version in:

- `.octon/capabilities/runtime/skills/registry.yml`

## Enforcement

Automated enforcement lives in:

- `.octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `.octon/assurance/runtime/_ops/scripts/validate-bootstrap-projections.sh`

Expected invocation points:

- Standalone: `bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- Structural gate (static checks): `bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- Continuity memory gate: `bash .octon/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- Framing gate: `bash .octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- Pre-release gate verification (drift checks): pre-release audit workflow verify step
