# Migration and Cutover Plan

## Cutover posture

Use staged cutover. Do not flip support claims or runtime-effectiveness before
validators and proof artifacts are in place.

## Branching model

- Work on a dedicated architecture hardening branch.
- Keep proposal packet changes separate from durable promotion commits where
  practical.
- Each phase should be independently reviewable and revertible.

## Pre-cutover checks

1. Confirm no runtime or policy path depends on proposal-local files.
2. Snapshot current support-target refs and generated/effective publication state.
3. Capture current architecture conformance output.
4. Identify live support tuple set and stage-only/non-live surfaces.
5. Confirm current run lifecycle fixtures.

## Cutover sequence

### Step 1 — Add validators in non-blocking report mode

Add validators and tests with report-only mode first. This exposes failures
without mutating support claims.

### Step 2 — Partition support artifacts

Move admissions/dossiers into claim-state directories and update refs. Keep
claim effects unchanged during the move.

### Step 3 — Wire generated/effective freshness gates

Add freshness checks and receipts. Run in stage-only mode before hard deny.

### Step 4 — Enforce authorization coverage

Make missing material-side-effect coverage a blocking failure.

### Step 5 — Promote health gate to blocking CI

Add health validator to architecture conformance workflow as a required gate.

### Step 6 — Close proof bundles

Produce proof-plane artifacts for live tuples and retain evidence.

### Step 7 — Retire compatibility surfaces

Retire or isolate compatibility shims only after successors are proven.

## Rollback plan

Rollback must preserve:

- original support-target refs;
- original admission/dossier paths;
- old generated/effective outputs and receipts;
- previous CI conformance config;
- previous runtime coverage map.

Rollback must not re-enable unsupported live claims. If a rollback would widen
support claims, deny the rollback and stage a manual governance review.

## No-go conditions

Cutover must stop if:

- any material path bypasses authorization;
- generated/effective runtime output lacks freshness receipts;
- support claims widen beyond admitted tuples;
- active missions route through non-live support without stage-only posture;
- proof bundle generation fails for a live tuple;
- operator boot validator fails.
