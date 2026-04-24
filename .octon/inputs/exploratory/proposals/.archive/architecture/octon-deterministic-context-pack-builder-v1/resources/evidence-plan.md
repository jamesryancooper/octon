# Evidence Plan

## Objective

Retain enough evidence to prove that deterministic Context Pack Builder v1 has landed as durable runtime behavior rather than proposal-local intent.

## Promotion evidence classes

1. **Schema evidence**
   - updated `context-pack-v1`
   - updated instruction-layer manifest
   - new builder and receipt contracts

2. **Runtime evidence**
   - emitted context pack fixture
   - emitted context pack receipt fixture
   - emitted retained model-visible serialization fixture
   - emitted model-visible hash fixture over the exact retained bytes
   - canonical Run Journal fixture showing hyphenated pack lifecycle events

3. **Authorization evidence**
   - grant fixture carrying pack receipt/hash
   - receipt fixture carrying same
   - negative authorization fixtures for stale, invalidated, missing receipt, missing hash sidecar, hash mismatch, request mismatch, policy mismatch, missing source manifest, retained source-manifest mismatch, missing replay hash ref, source digest mismatch, missing source, raw authority, generated authority, and replay mismatch

4. **Validator evidence**
   - passing validator output
   - passing regression test output
   - negative-control coverage from the validator and fixture contract
   - conformance run evidence when retained by the active workflow

## Recommended retained roots

- packet closure evidence:
  - `/.octon/state/evidence/validation/architecture/10of10-target-transition/context-pack-builder-v1/**`
- run-level reference fixtures:
  - `/.octon/state/evidence/runs/<run-id>/context/**`

## Minimum evidence retained before archive

- one packet-level change summary
- one durable fixture set with pack/receipt/model-visible serialization/hash
- one negative-path fixture
- retained-manifest and replay-ref negative fixtures that prove supplied bindings are fully validated before authorization
- current validation evidence for the durable validator and regression test entrypoints
