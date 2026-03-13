---
title: Profile-Governed Migration Plan Template
description: Template for planning and verifying migration changes under atomic/transitional profile governance with explicit receipt and enforcement controls.
---

# Migration Plan (Template)

Copy this into `/.octon/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/plan.md`.

## Profile Selection Receipt

- Date:
- Version source(s):
- Current version:
- Release state (`pre-1.0` or `stable`):
- `release_state` (`pre-1.0` or `stable`):
- `change_profile` (`atomic` or `transitional`):
- Selection facts:
  - downtime tolerance:
  - external consumer coordination ability:
  - data migration/backfill needs:
  - rollback mechanism:
  - blast radius and uncertainty:
  - compliance/policy constraints:
- Hard-gate outcomes:
- Tie-break status:
- Transitional Exception Note (required when `change_profile=transitional` in pre-1.0):
- `transitional_exception_note` (required when `change_profile=transitional` in pre-1.0):
  - rationale:
  - risks:
  - owner:
  - target_removal_date:

## Implementation Plan

- Name:
- Owner:
- Motivation:
- Scope:

### Atomic Profile Execution

- Clean-break approach:
- Big-bang implementation steps:
- Big-bang rollout steps:

### Transitional Profile Execution (if selected)

- Phases:
- Phase exit criteria:
- Final decommission/removal date:

## Impact Map (code, tests, docs, contracts)

### Code

- Files changed:
- Legacy removals:

### Tests

- Final-state tests:
- Phase-behavior tests (if transitional):

### Docs

- Updated docs/runbooks:

### Contracts

- Schemas/manifests/contracts changed:

## Compliance Receipt

- [ ] Exactly one profile selected before implementation
- [ ] Release-state gate applied
- [ ] Pre-1.0 atomic default respected (or transitional exception documented)
- [ ] Hard-gate fact collection recorded
- [ ] Tie-break rule enforced
- [ ] Obsolete/legacy surfaces removed at final state
- [ ] Required validations executed and linked

## Exceptions/Escalations

- Current exceptions:
- Escalations raised:
- Risk acceptance owner:

## Verification Evidence

### Static Verification

- [ ] No prohibited legacy/profile drift patterns remain
- [ ] Required sections and keys present

### Runtime Verification

- [ ] Selected profile behavior exercised
- [ ] Final state converges to single intended authority

### CI Verification

- [ ] Profile-governance validation gates pass

Required evidence bundle location:

- `/.octon/output/reports/migrations/<YYYY-MM-DD>-<slug>/`
- bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

## Rollback

- Rollback strategy:
- Rollback trigger conditions:
- Rollback evidence references:
