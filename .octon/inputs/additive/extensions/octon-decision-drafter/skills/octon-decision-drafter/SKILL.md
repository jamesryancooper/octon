---
name: octon-decision-drafter
description: >
  Composite extension-pack skill that routes to the appropriate
  octon-decision-drafter prompt bundle.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Decision Drafter

Resolve the appropriate `octon-decision-drafter` route and dispatch to the
matching leaf bundle. The default diff-plus-grounding route remains
`change-receipt`.

## Bundle Matrix

- `adr-update` - draft a non-authoritative ADR addendum or ADR patch
  suggestion
- `migration-rationale` - draft a migration-rationale section
- `rollback-notes` - draft rollback notes from rollback posture or run context
- `change-receipt` - draft a concise non-authoritative markdown receipt

## Core Workflow

1. Normalize diff, changed-path, grounding, target-ref, and output-mode inputs.
2. Resolve the published route with `resolve-extension-route.sh`.
3. Return the route receipt immediately when `dry_run_route=true`.
4. Stop on any non-`resolved` routing outcome.
5. Resolve prompt freshness only after a route is selected.
6. Execute the selected leaf bundle using its own manifest, stages,
   companions, and shared drafting contracts.
7. Materialize scratch artifacts only under the generic skill checkpoint and
   run-evidence roots.

The skill owns intermediate artifacts for the drafting flow. Diff summaries,
grounding notes, route receipts, and draft output should be materialized under
the generic skill surfaces rather than treated as durable canonical truth.

## Inputs

- optional bundle override
- exactly one diff source: `diff_range` or `diff_source`
- optional `changed_paths`
- retained evidence refs and contextual target refs such as `adr_ref`,
  `migration_plan_ref`, `proposal_packet_ref`, `run_contract_ref`, or
  `rollback_posture_ref`
- optional output controls such as `output_mode`, `draft_target_path`,
  `alignment_mode`, and `dry_run_route`

## Outputs

- route receipt when routing is previewed or blocked
- one non-authoritative draft in `inline`, `patch-suggestion`, or
  `scratch-md` mode
- retained run evidence under `/.octon/state/evidence/runs/skills/`
- optional checkpoints under `/.octon/state/control/skills/checkpoints/`

Prompt inventory lives in `prompts/<bundle>/manifest.yml` per bundle. Shared
drafting contracts live under `prompts/shared/`. `alignment_mode` behavior is
owned by `resolve-extension-prompt-bundle.sh`. Route policy lives under
`context/routing.contract.yml` and is published into the effective extension
catalog as `route_dispatchers`.

## Boundaries

- Additive only. Do not mint authority from raw pack paths.
- Draft outputs remain `Draft / Non-Authoritative` even when they target an
  ADR or migration plan.
- Do not auto-edit ADR indexes, migration indexes, rollback control files,
  retained receipt files, or generated surfaces.
- Patch suggestions require an explicit target path and remain suggestions
  only.
- Scratch output may live under generic skill checkpoint and run-evidence
  surfaces only.

## When To Escalate

- The diff source is missing or ambiguous.
- The prompt set is materially drifted and the alignment pass cannot resolve
  the conflict.
- Conflicting target refs are supplied without an explicit bundle override.
- The requested patch suggestion targets a blocked surface.
- Grounding evidence is too weak to support a non-speculative draft.

## References

- `references/phases.md`
- `references/io-contract.md`
- `references/validation.md`
- `references/decisions.md`
