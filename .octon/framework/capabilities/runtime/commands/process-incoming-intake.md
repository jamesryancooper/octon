---
title: Process Incoming Intake
description: Classify one raw additive intake unit through Governed Incoming Intake Routing.
access: agent
argument-hint: "<intake-id> [--requested-route <route>] [--stop-after-classification] [--execute-handoff]"
---

# Process Incoming Intake `/process-incoming-intake`

Classify one explicitly provided raw additive intake unit staged under
`/.octon/inputs/additive/.incoming/<intake-id>/` through Governed Incoming
Intake Routing.

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
/process-incoming-intake <intake-id> --execute-handoff
/process-incoming-intake <intake-id> --requested-route single-work-unit-handoff
```

## Implementation

Execute the canonical workflow at:

- `/.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`

The workflow must:

1. Validate the intake unit path, `intake.yml` envelope, and `payload/`
   containment.
2. Classify exactly one route: `single-work-unit-handoff`,
   `coordinated-program-handoff`, `target-owned-direct-handoff`, or
   `blocked-rejected-deferred`.
3. Write a `governed-incoming-intake-route-decision-v1` receipt before any
   handoff, target invocation, archive move, closeout, cleanup, or mutation.
4. Create `governed-incoming-intake-handoff-v1` advisory context only for
   target-owned packet/program/direct admission routes whose contracts validate.
5. Execute a target handoff only when `--execute-handoff` is set and the
   target-owned intake admission contract validates; otherwise stop with
   retained handoff or denial evidence.
6. Never claim implementation, Change closeout, worktree closeout, repo hygiene
   cleanup, or proposal archive completion without fresh target-owned return
   evidence.

`--requested-route` is a hint only. The workflow must fail closed when the
requested route disagrees with deterministic classification.

## Boundaries

- Do not accept `inputs/additive/extensions/.incoming/**` as staging.
- Do not treat `.incoming/**` as runtime, policy, publication, generated,
  evidence, or host-projection authority.
- Do not treat `.archive/**` as runtime, policy, publication, generated,
  evidence, or host-projection authority.
- Do not install or normalize raw intake directly as an extension pack or core
  skill under the mature routing model.
- Do not treat proposal handoff context or lifecycle interaction receipts as
  target authorization.
- Do not let parent proposal-program evidence satisfy child packet receipts.
- Do not hand-edit host command or skill projection directories.
- Do not trigger intake processing by silently scanning `.incoming/**`; future
  automation must enter through admitted workflow or run contracts.
- Do not use this command for `inputs/exploratory/proposals/**`,
  `inputs/exploratory/plans/**`, `inputs/exploratory/syntheses/**`, or
  `inputs/exploratory/reports/**`.
