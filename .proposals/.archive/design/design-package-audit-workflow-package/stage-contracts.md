# Stage Contracts

This document defines the documented stage contract for the
`audit-design-package` workflow package.

## Mode Selection

- `rigorous` is the default and preferred mode.
- `short` is allowed when speed matters more than separated hardening passes.
- The selected mode must be recorded in the workflow bundle metadata before
  stage execution begins.

## Stage Matrix

| Stage | Prompt | Modes | Class | Primary Input | Must Write Package | Required Output |
|---|---|---|---|---|---|---|
| `01` | `prompts/01-design-package-audit.md` | rigorous, short | evaluative | target package | no | `Design Audit Report` |
| `02` | `prompts/02-design-package-remediation.md` | short | file-writing | target package + audit report | yes | `Design Package Remediation Report` + change manifest |
| `03` | `prompts/03-design-red-team.md` | rigorous | evaluative | target package | no | `Design Red-Team Report` |
| `04` | `prompts/04-design-hardening.md` | rigorous | file-writing | target package + red-team report | yes | `Design Hardening Report` + change manifest |
| `05` | `prompts/05-design-integration.md` | rigorous | file-writing | target package + hardening report | yes | `Design Integration Report` + change manifest |
| `06` | `prompts/06-implementation-simulation.md` | rigorous, short | evaluative | current package state | no | `Implementation Simulation Report` |
| `07` | `prompts/07-specification-closure.md` | rigorous, short | file-writing | current package state + implementation simulation report | yes, unless no blockers remain | `Specification Closure Report` or explicit zero-change receipt |
| `08` | `prompts/08-minimal-implementation-architecture-extraction.md` | rigorous, short | implementation-guidance | stabilized package | no | `Minimal Implementation Architecture Blueprint` |
| `09` | `prompts/09-first-implementation-plan.md` | rigorous, short | implementation-guidance | stabilized package + blueprint | no | `First Implementation Plan` |

## Handoff Rules

- Stage `01` feeds stage `02` in `short` mode.
- Stage `01` feeds stage `03` in `rigorous` mode.
- Stage `03` feeds stage `04`.
- Stage `04` feeds stage `05`.
- The package state after the selected file-writing stages becomes the input to
  stage `06`.
- Stage `06` feeds stage `07`.
- The package state after stage `07` becomes the input to stages `08` and `09`.
- Stage `09` must not reopen design questions already closed by earlier stages
  unless a sequencing blocker remains.
- Only persisted stage reports are valid handoff artifacts. In-memory or partial
  executor output must not be used as downstream input.

## Durable Workflow Mapping

The package stages above describe the intended audit semantics. The durable
runtime workflow currently implements them through these live workflow stages:

| Package Stage | Durable Workflow Surface | Target Behavior |
|---|---|---|
| `01` | `design-audit` | persist `01-design-package-audit.md` |
| `02` | `remediation-track` (`short`) | persist `02-design-package-remediation.md` |
| `03`, `04`, `05` | `remediation-track` (`rigorous`) | persist `03-design-red-team.md`, `04-design-hardening.md`, and `05-design-integration.md` in sequence |
| `06` | `implementation-simulation` | persist `06-implementation-simulation.md` |
| `07` | `specification-closure` | persist `07-specification-closure.md` |
| `08` | `extract-blueprint` | persist `08-minimal-implementation-architecture-blueprint.md` |
| `09` | `first-implementation-plan` | persist `09-first-implementation-plan.md` |
| bundle synthesis | `report` | write `summary.md`, `commands.md`, `package-delta.md`, and `bundle.yml` |
| done gate | `verify` | validate mode coverage, receipts, summary, and package validator results |

Implementation-ready target state:

- the live workflow contract, workflow registry, and runner behavior must all
  describe this same mapping
- `remediation-track` may remain a wrapper stage, but its fan-out behavior must
  be documented identically in the package, workflow docs, and runner tests

## Package Mutation Contract

For stages `02`, `04`, `05`, and `07`:

- if file access is available, mutate the target package directly
- otherwise emit exact file bodies or exact patch sets
- always emit a change manifest
- if no file changes are necessary, emit an explicit zero-change receipt with:
  - rationale
  - files reviewed
  - reason no package mutation was required
- treat the stage as incomplete until both the package change and the report
  receipt are persisted

See `artifact-contract.md` for the required manifest fields and
`normative/execution/run-lifecycle.md` for partial-mutation and rerun behavior.

Recommendation-only output is non-compliant for these stages.

## Lifecycle Guarantees

- stage execution order is fixed by the selected mode
- downstream stages must not start from `failed` or `cancelled` predecessors
- a file-writing stage must be rerunnable against the current package state
- cancellation is safe only at stage boundaries; in-flight file-writing work may
  require idempotent recovery rather than rollback

## Stop Conditions

Stop the run and mark the bundle invalid when:

- the target package path cannot be resolved
- the selected prompt file is missing
- a selected stage fails to emit its required report
- a file-writing stage neither changes the package nor emits a zero-change
  receipt
- the selected mode and produced stage set disagree
- a downstream stage consumes a predecessor that did not reach `succeeded`

## Completion Contract

The pipeline is complete only when:

- every selected stage has a persisted report
- the target package reflects required file-writing changes or explicit no-op
  receipts
- the blueprint and first implementation plan are both produced
- workflow validation metadata records the selected mode, stage coverage, and
  final readiness verdict
