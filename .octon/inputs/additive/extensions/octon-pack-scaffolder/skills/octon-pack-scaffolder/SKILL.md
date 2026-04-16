---
name: octon-pack-scaffolder
description: >
  Dispatch explicitly to one additive extension-pack scaffold target rooted
  under `/.octon/inputs/additive/extensions/`.
license: MIT
compatibility: Designed for Octon additive extension-pack authoring.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating, idempotent]
allowed-tools: Read Glob Grep Write(/.octon/inputs/additive/extensions/*)
---

# Octon Pack Scaffolder

Resolve the explicit `target` input and delegate to one leaf scaffold.

## Targets

- `pack`
- `prompt-bundle`
- `skill`
- `command`
- `context-doc`
- `validation-fixture`

## Core Workflow

1. Validate `target` and `pack_id`.
2. Confirm the write scope stays under
   `/.octon/inputs/additive/extensions/<pack-id>/`.
3. Select the matching leaf scaffold with no route inference.
4. Apply the output contract from `context/output-shapes.md` and the
   matching example document.
5. Report created files, reused files, and any conflict that blocked the run.

## Boundaries

- Additive only.
- Do not touch `framework/**`, `instance/**`, `state/**`, or `generated/**`.
- Do not activate, publish, quarantine, or govern the target pack.
- Fail closed on conflicting existing content instead of silently overwriting
  it.

## Outputs

- One scaffolded additive asset family inside the target pack root.
- A concise receipt listing created paths, unchanged paths, and blocked paths.

## References

- `references/phases.md`
- `references/io-contract.md`
- `references/validation.md`
