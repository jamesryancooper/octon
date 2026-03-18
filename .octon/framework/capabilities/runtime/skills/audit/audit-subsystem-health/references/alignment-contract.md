---
title: Alignment Contract
description: Drift contract between .octon architecture surfaces and the audit-subsystem-health skill.
---

# Alignment Contract

## Purpose

Keep `audit-subsystem-health` synchronized with `.octon` architecture evolution.

Current bootstrap alignment expectation:

- repo-level `/init` now authors canonical bootstrap governance inside
  `/.octon/`, including `/.octon/AGENTS.md`, `/.octon/instance/bootstrap/OBJECTIVE.md`, and
  the machine-readable intent contract at
  `/.octon/instance/cognition/context/shared/intent.contract.yml`
- repo-root `AGENTS.md` and `CLAUDE.md` are ingress adapters to
  `/.octon/AGENTS.md`, not hand-maintained authority surfaces
- canonical bootstrap assets live under `.octon/framework/scaffolding/runtime/bootstrap/`
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

- `.octon/instance/bootstrap/START.md`
- `.octon/README.md`
- `.octon/octon.yml`
- `.octon/instance/bootstrap/catalog.md`
- `.octon/framework/cognition/_meta/architecture/`
- `.octon/framework/cognition/_meta/architecture/*.index.yml`
- `.octon/framework/cognition/governance/`
- `.octon/framework/cognition/practices/`
- `.octon/framework/cognition/practices/methodology/*.index.yml`
- `.octon/instance/cognition/context/shared/`
- `.octon/framework/cognition/_meta/architecture/state/continuity/`
- `.octon/state/evidence/runs/retention.json`
- `.octon/*/_meta/architecture/`
- `.octon/framework/orchestration/runtime/workflows/audit/audit-pre-release/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-contract-governance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-projections.sh`
- `.octon/framework/assurance/practices/complete.md`
- `.octon/framework/assurance/practices/session-exit.md`
- `.octon/instance/cognition/context/shared/migrations/`
- `.octon/instance/cognition/decisions/`
- `.octon/state/evidence/decisions/repo/reports/`
- `.octon/framework/engine/governance/protocol-versioning.md`
- `.octon/framework/engine/governance/rules/`
- `.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`

## Required Skill Artifacts

When watched surfaces change, review and update one or more of:

- `.octon/framework/capabilities/runtime/skills/audit/audit-subsystem-health/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/audit/audit-subsystem-health/references/phases.md`
- `.octon/framework/capabilities/runtime/skills/audit/audit-subsystem-health/references/validation.md`
- `.octon/framework/capabilities/runtime/skills/audit/audit-subsystem-health/references/io-contract.md`
- `.octon/framework/capabilities/runtime/skills/audit/audit-subsystem-health/references/alignment-contract.md`
- `.octon/framework/capabilities/runtime/skills/registry.yml` (`audit-subsystem-health` entry)

## Versioning Rule

If skill behavior/check logic changes (for example updates to `SKILL.md` or `references/*.md`), bump the `audit-subsystem-health` version in:

- `.octon/framework/capabilities/runtime/skills/registry.yml`

## Enforcement

Automated enforcement lives in:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-projections.sh`

Expected invocation points:

- Standalone: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- Structural gate (static checks): `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- Continuity memory gate: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- Framing gate: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
- Pre-release gate verification (drift checks): pre-release audit workflow verify step
