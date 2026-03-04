---
behavior:
  phases:
    - name: "Parse"
      steps:
        - "Read the spec document (file path or inline text)"
        - "Extract explicit requirements, constraints, and acceptance criteria"
        - "List ambiguities and assumptions explicitly"
    - name: "Profile Gate"
      steps:
        - "Read semantic version sources (`version.txt`, `.release-please-manifest.json`)"
        - "Determine release_state (`pre-1.0` or `stable`)"
        - "Collect hard-gate facts: downtime, coordination, migration/backfill, rollback, blast radius, compliance constraints"
    - name: "Profile Selection"
      steps:
        - "Choose exactly one `change_profile` (`atomic` or `transitional`)"
        - "Apply hard-gate rules: transitional only when hard gates require coexistence/staging"
        - "If pre-1.0 + transitional, require `transitional_exception_note` (rationale, risks, owner, target_removal_date)"
        - "If tie-break ambiguity exists, stop and escalate"
    - name: "Map and Decompose"
      steps:
        - "Map requirements to existing and new code areas"
        - "Break work into independently deliverable tasks"
        - "Capture dependencies, milestones, and risks"
    - name: "Plan"
      steps:
        - "Generate plan with mandatory top-level sections"
        - "Write plan to output/plans/ with deterministic naming"
    - name: "Review"
      steps:
        - "Present profile selection rationale, implementation plan, and compliance receipt"
        - "Capture final approval, revisions, or escalations"
  goals:
    - "Every plan has a valid Profile Selection Receipt before implementation details"
    - "Profile selection obeys semver release-state gates"
    - "Required output sections are always present and ordered"
    - "Tie-break ambiguity fails closed and escalates"
---

# Behavior Reference

Phase-by-phase behavior for the `spec-to-implementation` skill.

## Phase 1: Parse

Extract structured requirements from the source spec.

### Parse Output

```markdown
## Requirements
- R01: ...

## Constraints
- C01: ...

## Acceptance Criteria
- AC01: ...

## Ambiguities
- [ASSUMPTION] ...
- [QUESTION] ...
```

## Phase 2: Profile Gate

Determine release maturity and gather profile hard-gate facts.

### Required Facts

- Downtime tolerance
- External consumer coordination ability
- Data migration/backfill needs
- Rollback mechanism
- Blast radius and uncertainty
- Compliance/policy constraints

## Phase 3: Profile Selection

Select one governance profile using hard gates.

### Selection Logic

1. Determine `release_state`:
   - `pre-1.0`: semantic version `< 1.0.0` or prerelease (`alpha`, `beta`, `rc`)
   - `stable`: semantic version `>= 1.0.0` and not prerelease
2. Apply hard gates:
   - Use `transitional` when zero-downtime, external migration coordination, live migration/backfill coexistence, or staged risk exposure is required.
   - Otherwise use `atomic`.
3. Tie-break rule:
   - If both appear required, stop and escalate.
4. Pre-1.0 exception rule:
   - `transitional` requires `transitional_exception_note` with `rationale`, `risks`, `owner`, `target_removal_date`.

## Phase 4: Map and Decompose

Build an actionable task model:

- map requirements to touched surfaces,
- decompose into testable tasks,
- order by dependencies and risk,
- define milestones and exit criteria.

## Phase 5: Plan

Generated output MUST contain these top-level sections:

1. `Profile Selection Receipt`
2. `Implementation Plan`
3. `Impact Map (code, tests, docs, contracts)`
4. `Compliance Receipt`
5. `Exceptions/Escalations`

## Phase 6: Review

Human review focuses on:

- profile selection correctness,
- migration and rollout safety,
- contract propagation coverage,
- explicit exceptions/escalations.
