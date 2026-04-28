# Canonical Artifact Placement

## Framework

Portable contracts and standards belong in `framework/**`:

- stewardship schemas under `framework/engine/runtime/spec/`
- stewardship lifecycle standards under `framework/orchestration/practices/`

## Instance

Repo-specific durable stewardship authority belongs in `instance/**`:

- `instance/stewardship/programs/<program-id>/program.yml`
- `policy.yml`
- `trigger-rules.yml`
- `review-cadence.yml`

## State Control

Current mutable operational truth belongs in `state/control/**`:

- program status;
- epochs;
- triggers;
- admission decisions;
- renewal decisions;
- ledger.

## State Evidence

Retained factual proof belongs in `state/evidence/**`.

## State Continuity

Resumable context belongs in `state/continuity/**`, never authority.

## Generated

Derived operator read models belong in `generated/**`. They may summarize but
must never mint authority.

## Inputs

The proposal packet itself belongs in `inputs/exploratory/proposals/**` and is
lineage-only.
