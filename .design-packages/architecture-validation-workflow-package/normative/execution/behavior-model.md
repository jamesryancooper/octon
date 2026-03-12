# Behavior Model

## Mode Selection

- default mode: `rigorous`
- optional mode: `short`
- the selected mode must be recorded before stage execution begins

## Stage Execution Rules

- stages execute in documented order only
- each selected stage must persist exactly one report
- downstream stages consume prior reports and the current package state

## File-Writing Rules

For stages `02`, `04`, `05`, and `07`:

- mutate the target package directly when file access is available
- otherwise emit exact file bodies or exact patches
- always include `CHANGE MANIFEST`
- recommendation-only output is non-compliant

## Validation Rules

- missing stage reports fail the run
- missing mutation receipts fail the run
- if `design-package.yml` exists, the standard design-package validator must
  pass before the run can finish cleanly

## Output Rules

- write one top-level summary report
- write one bounded workflow bundle
- persist prompt packets, stage logs, stage reports, and bundle metadata
