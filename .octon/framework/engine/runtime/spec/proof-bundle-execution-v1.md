# Proof Bundle Execution v1

This contract defines the executable or replayable proof requirement for
support-target proof bundles.

## Requirement

A proof bundle is closure-grade only when it declares how its proof can be
executed or replayed. Metadata-only bundles are insufficient for live support
claims.

## Supported execution modes

- `command`
- `replay`
- `hybrid`

## Required fields

- `execution.mode`
- `execution.command_ref` for command-backed proof
- `execution.replay_ref` for replay-backed proof
- evaluator identity
- pass/fail criteria
- negative-control refs
- input and output digests
- receipt refs

## Replay rule

When `execution.mode: replay`, the referenced replay artifact must be retained
under `state/evidence/**` and correspond to the tuple or scenario claimed by
the bundle.
