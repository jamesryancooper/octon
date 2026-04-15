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

Route to the appropriate `octon-concept-integration` bundle and default to the
`source-to-architecture-packet` flow.

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

1. Resolve the target bundle from the optional `bundle` selector.
2. Default to `source-to-architecture-packet` when no bundle is provided.
3. Resolve the effective prompt bundle and its retained alignment receipt.
4. Execute the selected bundle using its own manifest, stages, companions, and
   shared prompt-family contracts.

The skill owns the intermediate artifacts for this flow. Extraction and
verification outputs should be materialized by the capability into pack-managed
artifacts rather than treated as user-supplied thread context.
The skill should also retain which prompt bundle and alignment receipt each run
used.

## Inputs

- optional bundle selector
- bundle-specific inputs such as `source_artifact`, `source_artifacts`,
  `proposal_packet`, `repo_paths`, `subsystem_scope`, or
  `conflicting_kernel_rules`

## Outputs

- bundle-specific proposal packet or execution result
- retained run evidence under `/.octon/state/evidence/runs/skills/`
- optional checkpoints under `/.octon/state/control/skills/checkpoints/`

Prompt inventory now lives in `prompts/<bundle>/manifest.yml` per bundle.
Shared family contracts live under `prompts/shared/`. `alignment_mode`
behavior is owned by `resolve-extension-prompt-bundle.sh`.

## Boundaries

- Additive only. Do not mint authority from raw pack paths.
- Proposal packets remain non-canonical.
- The landed capability must use the published prompt bundle and retained
  alignment receipts rather than raw prompt rereads as the default runtime
  path.
- Do not auto-implement the proposal packet as part of this skill.
- Do not auto-execute a constitutional challenge packet.

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
