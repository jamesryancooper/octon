---
title: Unified Execution Constitution Phase 1 Constitutional Extraction
description: Atomic migration record for singular-kernel constitutional extraction and ingress reduction.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/acceptance-criteria.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/resources/unified-execution-constitution-audit.md`

## Profile Selection Receipt

- Date: 2026-03-28
- Version source(s): `/.octon/octon.yml`, `/version.txt`
- Current version before cutover: `0.6.7`
- Target version after cutover: `0.6.7`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: high; this phase changes authored governance,
    ingress, shims, templates, and validators, but it does not require a live
    dual-authority rollout
  - external consumer coordination ability: not required; the cutover remains
    repo-local and self-contained
  - data migration and backfill needs: low; existing constitutional files stay
    at their current kernel paths and old surfaces are converted in place to
    shims
  - rollback mechanism: revert the Phase 1 change set, restoring the prior
    ingress read path and prior subordinate governance text
  - blast radius and uncertainty: medium; the work changes operator guidance,
    scaffolding, and validator expectations across agency and cognition
  - compliance and policy constraints: the repo must end with one singular
    constitutional kernel, no conflicting constitutional prose in the live
    path, and ingress that reads the kernel first
- Hard-gate outcomes:
  - no zero-downtime or coexistence requirement forces a transitional rollout
    for this phase
  - keeping old constitutional text as a parallel live authority would violate
    the packet's Phase 1 exit criteria
  - target-state correctness favors immediate de-authorization shims over
    preserving broader ingress or competing constitutional prose
- Tie-break status: `atomic` selected because Phase 1 can land as one coherent
  constitutional-authority cutover without a required coexistence window
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 1 constitutional extraction
- Owner: Octon maintainers
- Motivation: complete the singular constitutional-kernel cutover by making
  `framework/constitution/**` the only live repo-local constitutional kernel,
  reducing ingress to the minimum constitution-first read set, and turning old
  constitutional prose into explicit non-conflicting shims
- Scope:
  - align ingress and projected ingress adapters to a constitution-first
    minimal read set
  - convert old constitutional prose under agency, cognition, and assurance
    surfaces into explicit subordinate shims
  - record shim surfaces in the constitutional contract registry
  - update scaffolding and validators so `/init` and repo checks preserve the
    singular-kernel model

## Atomic Execution

1. Update the live and scaffolded ingress adapters so they resolve first to the
   internal ingress source and do not widen the read path themselves.
2. Reduce `instance/ingress/AGENTS.md` to the kernel-first minimal read set.
3. Convert old constitutional surfaces into explicit non-conflicting shims
   while preserving required subordinate domain guidance at the same paths.
4. Update constitutional registry metadata and validators so the Phase 1
   exit criteria stay enforced.

## Impact Map

### Constitutional kernel and ingress

- `/.octon/framework/constitution/{CHARTER.md,charter.yml,contracts/registry.yml}`
- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/AGENTS.md`
- `/AGENTS.md`
- `/CLAUDE.md`

### Shim surfaces and agency/cognition/assurance projections

- `/.octon/framework/agency/governance/{CONSTITUTION.md,README.md}`
- `/.octon/framework/agency/_meta/architecture/specification.md`
- `/.octon/framework/agency/README.md`
- `/.octon/framework/agency/runtime/agents/README.md`
- `/.octon/framework/agency/runtime/agents/{orchestrator,verifier}/AGENT.md`
- `/.octon/framework/agency/runtime/agents/_scaffold/template/AGENT.md`
- `/.octon/framework/cognition/governance/{CHARTER.md,README.md}`
- `/.octon/framework/cognition/governance/principles/{README.md,principles.md}`
- `/.octon/framework/assurance/governance/{CHARTER.md,README.md}`

### Scaffolding and validators

- `/.octon/framework/scaffolding/runtime/bootstrap/AGENTS.md`
- `/.octon/framework/scaffolding/runtime/templates/octon/scaffolding/runtime/bootstrap/AGENTS.md`
- `/.octon/framework/scaffolding/runtime/templates/octon/framework/scaffolding/runtime/bootstrap/AGENTS.md`
- `/.octon/framework/agency/_ops/scripts/validate/validate-agency.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/077-unified-execution-constitution-phase1-constitutional-extraction.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase1-constitutional-extraction/`

## Rollback

- revert the Phase 1 constitutional extraction change set
- restore the prior ingress read path and prior subordinate governance text
- do not leave adapters, validators, and live ingress out of sync
