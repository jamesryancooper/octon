---
title: Execution Profile Governance Cutover Plan
description: Atomic cutover to profile-governed migration policy with hard-gate enforcement across contracts, validators, skills, workflows, and PR controls.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-04
- Version source(s): `version.txt`, `.release-please-manifest.json`
- Current version: `0.4.1`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Atomic mode applied: Clean Break + Big Bang Implementation + Big Bang Rollout
- Selection facts:
  - downtime tolerance: no runtime cutover required
  - external consumer coordination ability: internal consumers coordinated via one PR and CI gates
  - data migration/backfill needs: none
  - rollback mechanism: full commit-range revert
  - blast radius and uncertainty: medium (governance/validator surfaces)
  - compliance/policy constraints: high
- Hard-gate outcomes: no transitional hard gate triggered
- Tie-break status: not triggered
- `transitional_exception_note`: n/a (not required; profile is atomic)

## Implementation Plan

1. Codify profile governance in top-level and agency contracts.
2. Replace clean-break-only doctrine with profile doctrine on active methodology surfaces.
3. Update migration instructions/prompts/templates to required output sections and machine keys.
4. Disambiguate workflow `execution_profile` from governance `change_profile`.
5. Enforce hard gates in agency/harness/skills/alignment validators.
6. Enforce PR-level receipt sections in canonical and kaizen templates.
7. Record ADR 046 and runtime migration/evidence records for this cutover.
8. Update engine governance and release/local validation practices to include profile-governance gates.

## Impact Map (code, tests, docs, contracts)

- Code/validators:
  - `/.octon/agency/_ops/scripts/validate/validate-agency.sh`
  - `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh`
  - `/.octon/assurance/runtime/_ops/scripts/alignment-check.sh`
- Contracts:
  - `/AGENTS.md`
  - `/.octon/agency/governance/{CONSTITUTION.md,DELEGATION.md,MEMORY.md,delegation-boundaries-v1.yml}`
  - `/.octon/agency/runtime/agents/architect/{AGENT.md,SOUL.md}`
  - `/.octon/agency/runtime/agents/registry.yml`
- Skills/workflows:
  - `/.octon/capabilities/runtime/skills/{manifest.yml,registry.yml}`
  - `/.octon/capabilities/runtime/skills/synthesis/spec-to-implementation/*`
  - `/.octon/orchestration/runtime/workflows/README.md`
- Templates/docs:
  - `/.octon/scaffolding/practices/prompts/clean-break-migration.prompt.md`
  - `/.octon/scaffolding/runtime/templates/migrations/template.clean-break-migration.md`
  - `/.octon/agency/practices/clean-break-migration.instructions.md`
  - `/.github/PULL_REQUEST_TEMPLATE.md`
  - `/.github/PULL_REQUEST_TEMPLATE/kaizen.md`
  - `/.octon/agency/practices/pull-request-standards.md`
  - `/.octon/engine/governance/{compatibility-policy.md,protocol-versioning.md,release-gates.md}`
  - `/.octon/engine/practices/{release-runbook.md,local-dev-validation.md}`
- Runtime records:
  - `/.octon/cognition/runtime/decisions/046-execution-profile-governance-cutover-contract.md`
  - `/.octon/cognition/runtime/decisions/index.yml`
  - `/.octon/cognition/runtime/migrations/index.yml`
  - `/.octon/output/reports/migrations/2026-03-04-execution-profile-governance-cutover/*`

## Compliance Receipt

- [x] Selected exactly one execution profile before implementation (`atomic`).
- [x] Applied semver release-maturity gate (`0.4.1` => `pre-1.0`).
- [x] Respected pre-1.0 default (`atomic`).
- [x] Added pre-1.0 transitional exception-note requirement to doctrine/templates/validators.
- [x] Added tie-break escalation contract and boundary rule checks.
- [x] Propagated contract changes across required governance surfaces.
- [x] Replaced active clean-break-only doctrine with profile doctrine.
- [x] Honored charter-control constraint (no direct principles charter edits).

## Exceptions/Escalations

- Current exceptions: none.
- Escalate immediately if encountered:
  - profile tie-break ambiguity (`atomic` and `transitional` both required),
  - semantic version source disagreement,
  - direct charter edit request without explicit human override and ledger evidence,
  - requests to rewrite historical ADR/migration artifacts outside active-surface scope.

## Verification Evidence

- Commands: `/.octon/output/reports/migrations/2026-03-04-execution-profile-governance-cutover/commands.md`
- Validation summary: `/.octon/output/reports/migrations/2026-03-04-execution-profile-governance-cutover/validation.md`
- Inventory: `/.octon/output/reports/migrations/2026-03-04-execution-profile-governance-cutover/inventory.md`
- Evidence narrative: `/.octon/output/reports/migrations/2026-03-04-execution-profile-governance-cutover/evidence.md`

## Rollback

Rollback strategy is full commit-range revert of this cutover. Partial rollback that leaves mixed profile-governance state is prohibited.
