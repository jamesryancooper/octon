# Repository Baseline Audit

## Baseline judgment

Octon already contains the architectural vocabulary and most prerequisite contracts required for Run Lifecycle v1 enforcement. The missing work is not conceptual invention; it is executable binding, transition validation, deterministic reconstruction, and proof.

## Current repo findings

### 1. Octon is already class-root disciplined

The umbrella architecture specification distinguishes:

- authored authority: `framework/**`, `instance/**`
- mutable control: `state/control/**`
- retained evidence: `state/evidence/**`
- continuity state: `state/continuity/**`
- generated runtime-effective handles: `generated/effective/**`
- generated operator read models: `generated/cognition/**`
- proposal inputs: `inputs/exploratory/proposals/**`

This directly constrains lifecycle enforcement placement.

### 2. Run Journal is already the canonical execution history

`run-journal-v1.md` states that `runtime_bus` is the only canonical append path for `events.ndjson` and `events.manifest.yml`, and that `runtime-state.yml` is derived from the journal plus bounded side artifacts.

### 3. Run Lifecycle v1 already defines the normative states

`run-lifecycle-v1.md` defines the states, entry requirements, required retained facts, allowed exits, and closeout rules. It already says `events.ndjson` and `events.manifest.yml` are the canonical transition record and `runtime-state.yml` is a mutable derived view.

### 4. Authorized Effect Tokens already define mutation authority

`authorized-effect-token-v1.md` requires material side-effect APIs to consume typed tokens derived from `authorize_execution(...)` and verify them into `VerifiedEffect` before mutation.

### 5. Context Pack Builder v1 already defines context preauthorization proof

`context-pack-builder-v1.md` makes deterministic Working Context evidence a prerequisite for consequential or boundary-sensitive authorization.

### 6. Evidence Store v1 already defines closeout requirements

`evidence-store-v1.md` requires run journal control truth, lifecycle control artifacts, authority evidence, effect-token evidence, replay/trace evidence, assurance evidence, observability evidence, disclosure evidence, and evidence classification.

### 7. Support targets already demand lifecycle-style proof

`support-targets.yml` says supported repo-consequential tuples require valid Run Journal conformance and deterministic state reconstruction through canonical run roots.

### 8. Assurance already has proof-plane locations

Assurance defines structural, functional, behavioral, maintainability, governance, recovery, and evaluator proof planes and writes retained evidence under `state/evidence/validation/assurance/**`.

## Baseline conclusion

The highest-leverage next improvement is to convert the existing lifecycle contract from normative text into enforced runtime behavior and retained validation proof.
