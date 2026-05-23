---
title: Process Incoming Intake
description: Classify and dispose a raw additive intake unit through the governed intake workflow.
access: agent
argument-hint: "<intake-id> [--requested-route <route>] [--stop-after-classification]"
---

# Process Incoming Intake `/process-incoming-intake`

Classify and dispose a raw additive intake unit staged under
`/.octon/inputs/additive/.incoming/<intake-id>/`.

This command is a human-invoked agent facade over the governed workflow. It is
not an autonomous watcher, scanner, or direct installer.
It processes only additive intake units under `.incoming`; it does not process exploratory proposals, advisory plans, syntheses, or reports.

Current intake units must have a non-authoritative `intake.yml` envelope and a
`payload/` raw payload root. The envelope is only intake bookkeeping. Candidate
extension packs, core skills, generated-looking outputs, evidence-looking
trees, or host-projection-looking trees under `payload/` remain raw intake until
classification and disposition explicitly admit them elsewhere.

## Usage

```text
/process-incoming-intake <intake-id>
/process-incoming-intake <intake-id> --stop-after-classification
/process-incoming-intake <intake-id> --requested-route additive-extension-pack
```

## Implementation

Execute the canonical workflow at:

- `/.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`

The workflow must:

1. Validate the intake unit path, `intake.yml` envelope, and `payload/`
   containment.
2. Classify the route as additive extension pack, core Octon skill, or
   blocked/proposal-required, using validator findings for missing provenance,
   binaries, executables, secrets/private data, redistribution risk, oversized
   payloads, candidate packs, and candidate skills.
3. Write decision evidence before mutation.
4. Execute only the selected disposition route.
5. Validate closeout and cleanup; final disposition must leave no
   `.incoming/<intake-id>/` copy unless the run explicitly stopped after
   classification.

## Boundaries

- Do not accept `inputs/additive/extensions/.incoming/**` as staging.
- Do not treat `.incoming/**` as runtime, policy, publication, generated,
  evidence, or host-projection authority.
- Do not treat `.archive/**` as runtime, policy, publication, generated,
  evidence, or host-projection authority.
- Do not hand-edit host command or skill projection directories.
- Do not trigger intake processing by silently scanning `.incoming/**`; future
  automation must enter through admitted workflow or run contracts.
- Do not use this command for `inputs/exploratory/proposals/**`,
  `inputs/exploratory/plans/**`, `inputs/exploratory/syntheses/**`, or
  `inputs/exploratory/reports/**`.
