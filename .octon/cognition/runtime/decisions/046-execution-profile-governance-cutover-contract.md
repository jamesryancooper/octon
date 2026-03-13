# ADR 046: Execution-Profile Governance Cutover Contract

- Date: 2026-03-04
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: Clean-break-only migration doctrine as active governance default
- Related:
  - `/.octon/cognition/practices/methodology/migrations/README.md`
  - `/.octon/cognition/practices/methodology/migrations/doctrine.md`
  - `/.octon/cognition/practices/methodology/migrations/invariants.md`
  - `/.octon/cognition/practices/methodology/migrations/exceptions.md`
  - `/.octon/cognition/practices/methodology/migrations/ci-gates.md`
  - `/.octon/agency/governance/CONSTITUTION.md`
  - `/.octon/agency/governance/DELEGATION.md`
  - `/.octon/agency/governance/MEMORY.md`

## Context

Migration governance previously emphasized clean-break behavior but did not model
all valid execution strategies as first-class profile contracts. Governance and
planning surfaces needed a unified model that:

1. preserves pre-1.0 bias toward atomic cutovers,
2. permits transitional execution only when hard gates require staged coexistence,
3. enforces a consistent receipt shape and machine keys across contracts,
4. fails closed in CI and PR quality checks when required governance evidence is missing.

## Decision

Adopt a profile-based governance contract with immediate enforcement:

1. Require one selected `change_profile` before planning or implementation:
   - `atomic`
   - `transitional`
2. Require release-maturity gate from semantic version with `release_state`:
   - `pre-1.0`
   - `stable`
3. In pre-1.0 mode, default to `atomic`; permit `transitional` only when hard
   gates require it and `transitional_exception_note` is complete.
4. Require standardized planning output sections:
   - `Profile Selection Receipt`
   - `Implementation Plan`
   - `Impact Map (code, tests, docs, contracts)`
   - `Compliance Receipt`
   - `Exceptions/Escalations`
5. Require tie-break escalation when atomic and transitional conditions both
   appear required.

## Consequences

### Benefits

- Deterministic, auditable profile selection before implementation.
- Explicit pre-1.0 safety default with narrow, documented transitional exceptions.
- Uniform receipt shape across contracts, templates, skills, and PR workflow.
- Hard-gate validator enforcement across agency, harness, skills, and alignment checks.

### Costs

- Additional planning and documentation burden for governance-heavy changes.
- Validator maintenance overhead as contract surfaces evolve.

### Rollback

- Revert this cutover as one change set; partial rollback that leaves mixed
  profile-governance semantics is prohibited.
