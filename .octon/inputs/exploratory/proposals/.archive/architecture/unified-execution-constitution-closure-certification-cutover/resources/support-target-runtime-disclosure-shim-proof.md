# Support-Target, Runtime, Disclosure, and Shim Proof

This note groups the remaining proof disciplines that must become release
blocking for closure.

## 1. Support-target execution

The support matrix already distinguishes:

- supported
- reduced
- experimental
- unsupported

Closure requires the matrix to become executable through:

- one positive supported-envelope run
- one reduced tuple that stages
- one unsupported tuple that denies
- one missing-evidence run that fails closed

## 2. Consequential run bundle

The run-control root already states the expected shape of a consequential run.
Closure requires that shape to become a release-blocking contract.

The minimal bundle is:

- `run-contract.yml`
- `run-manifest.yml`
- `runtime-state.yml`
- `rollback-posture.yml`
- stage-attempt root
- checkpoint root
- decision artifact
- approval grant bundle
- evidence classification
- replay pointers
- external replay index
- intervention log
- measurement summary
- RunCard

## 3. Disclosure parity

A RunCard or HarnessCard is not enough by itself. Closure requires:

- every RunCard proof-plane ref resolves
- every HarnessCard proof-bundle ref resolves
- release wording matches the closure manifest
- benchmark/support/release claims point to retained evidence, not just repo
  structure

## 4. Shim independence

Historical and active shim surfaces may remain only if they are proven
non-authoritative.

The shim audit must scan:

- launchers
- workflows
- validators
- ingress entrypoints
- bootstrap entrypoints

The audit fails if any historical shim is read as authority rather than as a
projection, compatibility, or historical surface.

## 5. Build-to-delete evidence

The registry already points toward a retirement discipline. Closure requires
live retained evidence that the discipline is operating.

At minimum, retain one publication artifact that records:

- what was deleted or demoted
- why it was safe to remove
- who owned the compensating mechanism
- what trigger caused the retirement
- what state replaced it after removal

## Closure result

The release passes only if all four proof classes above are green at the same
time. Partial proof does not certify the claim.
