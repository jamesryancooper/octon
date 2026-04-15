---
name: octon-concept-integration
description: >
  Composite extension-pack skill that routes to the appropriate
  octon-concept-integration prompt bundle.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-13"
  updated: "2026-04-15"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Concept Integration

Resolve the appropriate `octon-concept-integration` route and dispatch to the
matching leaf bundle. The default single-source route remains
`source-to-architecture-packet`.

## Bundle Matrix

- `source-to-architecture-packet` — default external-source architecture flow
- `architecture-revision-packet` — revise ordinary architecture before
  integration
- `constitutional-challenge-packet` — governed kernel-level challenge flow
- `source-to-policy-packet` — external-source policy packet flow
- `source-to-migration-packet` — external-source migration packet flow
- `multi-source-synthesis-packet` — multi-source architecture packet flow
- `packet-refresh-and-supersession` — refresh or supersede an existing packet
- `packet-to-implementation` — execute an existing packet
- `subsystem-targeted-integration` — source-driven flow with explicit subsystem scope
- `repo-internal-concept-mining` — repo-native source mining flow

## Core Workflow

1. Normalize composite dispatcher inputs into one routing payload.
2. Resolve the published route with `resolve-extension-route.sh`.
3. Return the route receipt immediately when `dry_run_route=true`.
4. Stop on any non-`resolved` routing outcome.
5. Resolve prompt freshness only after a route is selected.
6. Execute the selected leaf bundle using its own manifest, stages,
   companions, and shared prompt-family contracts.

The skill owns the intermediate artifacts for this flow. Extraction and
verification outputs should be materialized by the capability into pack-managed
artifacts rather than treated as user-supplied thread context.
The skill should also retain which prompt bundle and alignment receipt each run
used, plus the resolved route receipt.

## Inputs

- optional bundle override
- bundle-specific inputs such as `source_artifact`, `source_artifacts`,
  `proposal_packet`, `repo_paths`, `subsystem_scope`, or
  `conflicting_kernel_rules`
- optional route disambiguators such as `source_target_kind`, `packet_action`,
  `refresh_mode`, and `dry_run_route`

## Outputs

- route receipt when routing is previewed or blocked
- bundle-specific proposal packet or execution result
- retained run evidence under `/.octon/state/evidence/runs/skills/`
- optional checkpoints under `/.octon/state/control/skills/checkpoints/`

Prompt inventory now lives in `prompts/<bundle>/manifest.yml` per bundle.
Shared family contracts live under `prompts/shared/`. `alignment_mode`
behavior is owned by `resolve-extension-prompt-bundle.sh`. Route policy lives
under `context/routing.contract.yml` and is published into the effective
extension catalog as `route_dispatchers`.

## Boundaries

- Additive only. Do not mint authority from raw pack paths.
- Proposal packets remain non-canonical.
- The landed capability must use the published prompt bundle and retained
  alignment receipts rather than raw prompt rereads as the default runtime
  path.
- Do not auto-implement the proposal packet as part of this skill.
- Do not auto-execute a constitutional challenge packet.
- Allow at most one reroute, and only from a non-constitutional route into
  `constitutional-challenge-packet` when verify-stage logic raises a structured
  kernel-conflict signal before packet emission or implementation starts.

## When To Escalate

- The source artifact is missing or unreadable.
- The prompt set is materially drifted and the alignment pass cannot resolve
  the conflict.
- The requested packet scope would require support-target widening or a new
  governed capability-pack family.
- The generated proposal packet fails validators for reasons not attributable
  to the source or user scope.

## References

- `references/phases.md`
- `references/io-contract.md`
- `references/validation.md`
- `references/decisions.md`
