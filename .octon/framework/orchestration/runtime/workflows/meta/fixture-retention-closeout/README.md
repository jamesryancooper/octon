---
name: "fixture-retention-closeout"
description: "Retain a temporary proposal fixture as evidence-only validation residue without granting archive, cleanup, Git, or packet evidence authority."
steps:
  - id: "resolve-fixture-identity"
    file: "stages/01-resolve-fixture-identity.md"
    description: "resolve-fixture-identity"
  - id: "bind-retention-scope"
    file: "stages/02-bind-retention-scope.md"
    description: "bind-retention-scope"
  - id: "verify-retained-evidence"
    file: "stages/03-verify-retained-evidence.md"
    description: "verify-retained-evidence"
  - id: "classify-retained-path-set"
    file: "stages/04-classify-retained-path-set.md"
    description: "classify-retained-path-set"
  - id: "emit-retention-receipt"
    file: "stages/05-emit-retention-receipt.md"
    description: "emit-retention-receipt"
---

# Fixture Retention Closeout

_Generated README from canonical workflow `fixture-retention-closeout`._

## Usage

```text
/fixture-retention-closeout
```

## Purpose

Retain a temporary proposal fixture as evidence-only validation residue without granting archive, cleanup, Git, or packet evidence authority.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/fixture-retention-closeout`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/fixture-retention-closeout/workflow.yml`.

## Parameters

- `fixture_path` (folder, required=true): Temporary implemented proposal fixture to retain as validation evidence.
- `purpose` (text, required=false): Validation purpose for retaining the fixture residue.
- `owner_scope` (text, required=true): Owning repair or Change scope that created or uses the fixture.
- `evidence_refs` (text, required=true): Comma-separated source evidence refs proving the fixture was used.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `retention_closeout_bundle` -> `/.octon/state/evidence/runs/workflows/{{date}}-fixture-retention-closeout-{{slug}}/`: Workflow-owned evidence bundle with stage inputs, reports, logs, outcomes, and retained path-set receipt.
- `retention_receipt` -> `/.octon/state/evidence/runs/workflows/{{date}}-fixture-retention-closeout-{{slug}}/retention-receipt.yml`: fixture-retention-closeout-receipt-v1 retained fixture evidence contract.
- `retention_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-fixture-retention-closeout.md`: Human-readable fixture retention closeout summary.

## Steps

1. [resolve-fixture-identity](./stages/01-resolve-fixture-identity.md)
2. [bind-retention-scope](./stages/02-bind-retention-scope.md)
3. [verify-retained-evidence](./stages/03-verify-retained-evidence.md)
4. [classify-retained-path-set](./stages/04-classify-retained-path-set.md)
5. [emit-retention-receipt](./stages/05-emit-retention-receipt.md)

## Verification Gate

- [ ] fixture identity is derived from proposal.yml proposal_id, proposal_kind, path, status, promotion_targets, and lifecycle.temporary
- [ ] retained path set exactly matches current scoped git status
- [ ] retained_path_set_digest and git_status_digest are current
- [ ] evidence_refs are source evidence and are not generated outputs, generated prompts, proposal-local prose, or parent summaries
- [ ] generated artifact refs are derived-only non-authority
- [ ] stage reports and stage outcomes exist for every route stage
- [ ] fixture-retention-closeout-receipt-v1 validates
- [ ] receipt states that retention is nonblocking only for unrelated packet terminal readiness under exact receipt checks
- [ ] receipt states that it does not authorize archive-ready or cleaned claims

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/fixture-retention-closeout/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/fixture-retention-closeout/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `fixture-retention-closeout` |
