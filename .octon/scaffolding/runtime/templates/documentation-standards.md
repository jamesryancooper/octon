# Documentation Standards Guide

This is the canonical guidance for docs-as-code in Octon. Use it with:

- Policy: `.octon/cognition/governance/principles/documentation-is-code.md`
- Template bundle: `.octon/scaffolding/runtime/templates/docs/documentation-standards/`
- Operational tooling: `.octon/capabilities/runtime/services/authoring/doc/guide.md`
- Enforcement gate: `audit-documentation-standards` skill and
  `audit-documentation` workflow

## Minimum Documentation Set

1. Spec one-pager (`spec.md`)
2. ADR (`adr-XXXX.md`)
3. Feature story or execution plan (`bmad-story.md`)
4. Component or developer guide (`guide.md`)
5. Operations runbook (`runbook.md`)
6. Contracts (`openapi.yaml`, JSON schemas)

## Why This Standard Exists

- Keeps implementation intent explicit and reviewable
- Prevents contract drift and undocumented behavior changes
- Preserves operational knowledge needed for rollout and incident response
- Enables consistent quality-gate automation across teams and stacks

## Canonical Template Location

Use:

- `.octon/scaffolding/runtime/templates/docs/documentation-standards/`

Template structure:

```text
.octon/scaffolding/runtime/templates/docs/documentation-standards/
  README.md
  docs/
    specs/feature-name/
      spec.md
      adr-0001.md
      bmad-story.md
    components/component-name/
      guide.md
    runbooks/
      feature-name.md
  packages/contracts/
    openapi.yaml
    README.md
    schemas/feature-name.schema.json
```

## How to Use the Template

1. Copy the template bundle into your target workspace docs path.
2. Rename `feature-name` and `component-name` placeholders.
3. Fill `spec.md` first, then ADR, then execution plan.
4. Define and validate contracts before implementation is complete.
5. Complete component guide and runbook before rollout.
6. Keep doc and code updates in the same PR when behavior/contracts/operations
   change.

## Required Review Expectations

- Every behavior or contract change has linked doc updates.
- All links resolve and examples are runnable or clearly marked as examples.
- Runbook rollback steps are explicit and testable.
- Docs use stable terminology and heading structure.

## Enforcement

Run either:

- Skill: `/audit-documentation-standards docs_root="docs"`
- Workflow: `/audit-documentation docs_root="docs"`

The quality gate should be run before release or when introducing significant
scope changes.

## Suggested Repo Locations

- `docs/specs/<feature>/`
- `docs/components/<component>/`
- `docs/runbooks/`
- `packages/contracts/`

Adapt locations if needed, but keep one canonical home per artifact type.
