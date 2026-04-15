# Implementation Plan

## Change Profile

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- implementation posture: additive pack hardening plus generated-effective and
  retained-evidence extension

## Workstream 1: Define the authored prompt contract

Create the pack-local prompt-set manifest.

Responsibilities:

- declare prompt inventory
- classify stages and companions
- define required repo anchors
- define invalidation conditions
- define alignment policy defaults

## Workstream 2: Publish effective prompt bundle state

Extend extension publication so prompt bundles become runtime-facing generated
state rather than implicit raw file reads.

Responsibilities:

- publish prompt bundle metadata
- publish any required prompt asset projections
- extend generation-lock and receipt linkage

## Workstream 3: Add alignment receipt retention

Create a retained evidence family for prompt alignment and drift.

Responsibilities:

- record bundle and anchor digests
- record reuse versus recompute
- record pass/fail/blocked/degraded status

## Workstream 4: Harden skill execution

Update the concept-integration skill so it consumes the effective prompt bundle
and enforces fail-closed behavior for `alignment_mode=auto`.

Responsibilities:

- fresh bundle path
- stale bundle re-alignment path
- stale bundle failure path
- explicit degraded skip path

## Workstream 5: Add run-level provenance

Extend retained run evidence so each concept-integration run records:

- prompt bundle id
- prompt bundle digest
- alignment receipt id
- effective alignment mode

## Workstream 6: Reuse or extend the native prompt service

Prefer a deterministic integration with the existing prompt modeling service for
bundle compilation, hashing, and output normalization where doing so reduces
custom logic and improves contract clarity.

## Workstream 7: Prove behavior with real runs

Run the concept-integration capability under:

- fresh bundle
- stale bundle with re-alignment
- stale bundle with forced failure
- explicit skip mode

Capture all resulting retained evidence and publication receipts.
