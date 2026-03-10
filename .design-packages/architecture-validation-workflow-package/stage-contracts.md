# Stage Contracts

This document defines the documented stage contract for the Architecture
Validation Pipeline.

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

## Package Mutation Contract

For stages `02`, `04`, `05`, and `07`:

- if file access is available, mutate the target package directly
- otherwise emit exact file bodies or exact patch sets
- always emit a change manifest
- if no file changes are necessary, emit an explicit zero-change receipt with:
  - rationale
  - files reviewed
  - reason no package mutation was required

Recommendation-only output is non-compliant for these stages.

## Stop Conditions

Stop the run and mark the bundle invalid when:

- the target package path cannot be resolved
- the selected prompt file is missing
- a selected stage fails to emit its required report
- a file-writing stage neither changes the package nor emits a zero-change
  receipt
- the selected mode and produced stage set disagree

## Completion Contract

The pipeline is complete only when:

- every selected stage has a persisted report
- the target package reflects required file-writing changes or explicit no-op
  receipts
- the blueprint and first implementation plan are both produced
- workflow validation metadata records the selected mode, stage coverage, and
  final readiness verdict
