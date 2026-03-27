---
title: Authority Engine Normalization Cutover
description: Transitional migration plan for Wave 2 authority engine normalization.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-27
- Version source(s): `/.octon/octon.yml`
- Current version before cutover: `0.6.3`
- Target version after cutover: `0.6.3`
- `release_state`: `pre-1.0`
- `change_profile`: `transitional`
- Selection facts:
  - downtime tolerance: runtime-facing authority routing can tolerate staged
    coexistence, but not a one-shot replacement of all host-shaped approval
    flows
  - external consumer coordination ability: low external dependency pressure,
    but live repo-local coordination is required across runtime, governance,
    control state, assurance, and host projections
  - data migration and backfill needs: medium-to-high; approval, exception,
    revocation, and retained decision evidence need canonical roots without
    breaking existing callers
  - rollback mechanism: revert the Wave 2 cutover, restore prior runtime path
    references, and treat the new authority roots as unused transitional
    scaffolds
  - blast radius and uncertainty: high; the cutover changes runtime
    authorization flow, control-plane paths, and governance evidence
  - compliance and policy constraints: labels, comments, and checks may not
    become steady-state authority during the coexistence window
- Hard-gate outcomes:
  - host-shaped approval signals still exist and must be projected into
    canonical approval artifacts before execution
  - support-tier routing must become explicit before run-only autonomy widens
  - ownership, reversibility, budget, and egress posture need one normalized
    route summary instead of split ad hoc checks
  - decision and grant artifacts need retained evidence roots outside host or
    chat context
- Tie-break status: `transitional` selected because a hard gate requires
  coexistence between current host projections and canonical authority
  artifacts
- `transitional_exception_note`:
  - rationale: normalize authority artifacts and routing while preserving
    compatible entrypoints for existing host and runtime callers
  - risks:
    - host projections and canonical authority artifacts could drift during
      the coexistence window
    - missing support-target declarations could incorrectly narrow or widen
      current runtime behavior
    - runtime and validator updates could land without complete doc alignment
  - owner: `Octon governance`
  - target_removal_date: `2026-06-30`

## Implementation Summary

- Name: Authority engine normalization
- Owner: Octon maintainers
- Motivation: centralize approvals, grants, exceptions, revocations, decision
  artifacts, and grant bundles under one authority model and make runtime
  routing consume ownership, support tier, reversibility, budget, and egress
  posture together
- Scope:
  - publish the constitutional authority contract family under
    `/.octon/framework/constitution/contracts/authority/**`
  - add canonical live control roots under
    `/.octon/state/control/execution/{approvals,exceptions,revocations}/`
  - normalize retained authority evidence under
    `/.octon/state/evidence/control/execution/**`
  - route host-shaped approval signals through canonical approval artifacts
  - extend runtime policy requests, grant handling, and receipts with
    ownership, support-tier, reversibility, budget, and egress posture

## Transitional Execution

1. Publish canonical authority contracts and control roots before runtime
   writers switch to them.
2. Keep host labels, comments, checks, and env flags projection-only; runtime
   must materialize canonical grants before they affect execution.
3. Preserve mission-backed runtime behavior while moving approval, exception,
   revocation, and decision handling to generic artifacts.
4. Update live docs and validators in the same branch as the runtime cutover.

## Impact Map

### Constitutional and governance authority

- `/.octon/framework/constitution/contracts/authority/**`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/{CHARTER.md,charter.yml,precedence/*.yml,obligations/*.yml}`
- `/.octon/instance/governance/{support-targets.yml,ownership/registry.yml}`

### Runtime and live control roots

- `/.octon/framework/engine/runtime/config/policy-interface.yml`
- `/.octon/framework/engine/runtime/spec/*.md`
- `/.octon/framework/engine/runtime/crates/{core,kernel}/**`
- `/.octon/state/control/execution/{approvals,exceptions,revocations}/**`
- `/.octon/state/evidence/control/execution/**`

### Architecture and assurance

- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/_meta/architecture/{specification.md,contract-registry.yml,runtime-vs-ops-contract.md}`
- `/.octon/framework/engine/README.md`
- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-harness-structure.sh,validate-architecture-conformance.sh,validate-mission-runtime-contracts.sh,validate-execution-governance.sh}`

## Verification Evidence

- Validation receipts:
  `/.octon/state/evidence/migration/2026-03-27-authority-engine-normalization-cutover/validation.md`
- Command log:
  `/.octon/state/evidence/migration/2026-03-27-authority-engine-normalization-cutover/commands.md`
- Change inventory:
  `/.octon/state/evidence/migration/2026-03-27-authority-engine-normalization-cutover/inventory.md`

## Rollback

- revert the Wave 2 authority-normalization change set
- restore the prior runtime references to root-level approval and exception
  artifacts
- remove the published support-target declaration and new authority roots if
  the branch is reverted
- do not leave live docs or validators referencing canonical authority roots
  that runtime no longer uses
