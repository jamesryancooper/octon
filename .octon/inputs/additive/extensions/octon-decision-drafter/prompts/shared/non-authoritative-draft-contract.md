# Non-Authoritative Draft Contract

Every output from this family is a draft only.

## Required Label

Use the label:

- `Draft / Non-Authoritative`

near the top of every returned draft.

## Rules

- Drafts may summarize or suggest edits to a target surface, but they do not
  change authority on their own.
- Drafts must cite the diff basis and the retained evidence basis.
- Patch suggestions remain suggestions only, even when they target an ADR or a
  migration plan.
- The pack must never create or update canonical control or evidence files automatically.

## Forbidden Automatic Targets

- `/.octon/instance/cognition/decisions/index.yml`
- `/.octon/instance/cognition/context/shared/migrations/index.yml`
- any file under `/.octon/state/control/**`
- any file under `/.octon/state/evidence/**`
- any file under `/.octon/generated/**`

When the operator asks for a patch suggestion against a blocked target, stop
and explain the boundary instead of drafting the patch.
