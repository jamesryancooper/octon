# Current-State Gap Map

## Current Usage

The current product feature is named `Lifecycle Autopilot` in:

- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/roadmap/lifecycle-autopilot.md`
- product validators and validator tests that hard-code lifecycle-autopilot
  file and feature ids
- proposal-program invariant prose and active proposal lifecycle pattern docs

The current implementation already uses precise technical nouns such as
Lifecycle Runner, Lifecycle Executor Adapter, and `phase_loop`. The main gap is
the product capability name.

## Architectural Problem

`Autopilot` can imply autonomous authority. That conflicts with the implemented
model, where self-operating execution is allowed only through approved
runner/executor mechanisms and must never become self-authorizing.

## Gap Boundaries

- This is not a request to rename the `octon lifecycle` CLI.
- This is not a request to rename the `phase_loop` contract field.
- This is not a request to add statuses, routes, lifecycle ids, or schemas.
- This is not a request to rewrite archived/historical evidence.

## Expected Resolution

Use `Governed Lifecycle Orchestration` for the product capability and preserve
component-specific names for runtime surfaces. Keep any retained legacy
reference explicitly marked as historical, compatibility, or legacy lineage.
