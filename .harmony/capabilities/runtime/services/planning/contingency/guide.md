# Contingency Guide

## Purpose

Given a plan and one or more failed or blocked step IDs, this service builds
alternative execution paths with deterministic ordering.

## Default Outputs

- The original plan as-is when no failed steps are provided.
- A list of alternatives when there are failures, each with:
  - `removedStepIds`
  - `delta` (`removedCount`, `keptCount`)
  - `plan` (`steps`, `order`)

## Inputs

- `command`: `generate` or `validate`
- `plan` or `planPath`
- `failedSteps` array
- `allowDescendants` (default `true`)
- `maxAlternatives` (default `3`)

## Behavior

- `generate` returns `status=success` or `status=partial` if only degraded fallback
  paths are possible.
- `validate` fail-closes when every generated alternative is impossible.
