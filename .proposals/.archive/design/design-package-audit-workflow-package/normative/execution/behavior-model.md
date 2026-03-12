# Behavior Model

## Mode Selection

- default mode: `rigorous`
- optional mode: `short`
- the selected mode must be recorded before stage execution begins
- the selected mode fixes the allowed stage set for the run

## Stage Execution Rules

- stages execute in documented order only
- each selected stage must persist exactly one report
- downstream stages consume prior reports and the current package state
- downstream stages consume only persisted predecessor outputs
- a stage reaches success only after its required report is durable

## Run And Stage Lifecycle Rules

- run states and stage states are defined in
  `normative/execution/run-lifecycle.md`
- file-writing stages are forward-only and recover through idempotent rerun, not
  automatic rollback
- cancellation is safe at stage boundaries only
- package mutation requires exclusive ownership of the target package during the
  write window

## File-Writing Rules

For stages `02`, `04`, `05`, and `07`:

- mutate the target package directly when file access is available
- otherwise emit exact file bodies or exact patches
- always include `CHANGE MANIFEST`
- recommendation-only output is non-compliant
- do not expose partial package changes to downstream stages without a persisted
  receipt

## Validation Rules

- missing stage reports fail the run
- missing mutation receipts fail the run
- if `design-package.yml` exists, the standard design-package validator must
  pass before the run can finish cleanly
- bundle validation must reconcile per-stage receipts with `package-delta.md`

## Output Rules

- write one top-level summary report
- write one bounded workflow bundle
- persist prompt packets, stage logs, stage reports, and bundle metadata
- render executor prompt packets and parse executor responses according to
  `normative/execution/executor-interface.md`
