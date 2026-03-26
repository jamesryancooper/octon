# Validation Plan

## Goal

Prove that the closeout is complete, not merely described.
The validator set below is the proof obligation for closing the [implementation audit](../resources/implementation-audit.md).

## Proof strategy

Validation must prove the cutover in the same order the implementation is integrated:

1. authoritative contracts and versioning are aligned
2. lifecycle seeding and activation are fail-closed
3. runtime admission consumes fresh intent, slice, and route state
4. control mutations and reducer transitions are fully receipted
5. generated awareness is universal and non-authoritative
6. scenario fixtures prove the final operating model under realistic mission classes
7. CI blocks merge unless the full proof set is green

No single validator is sufficient.
The closeout is considered proven only by the combined result of structural validation, lifecycle activation tests, scenario tests, generated-output checks, and evidence checks.

## Validation execution order

### 1. Static architecture and contract checks
- `validate-version-parity.sh`
- `validate-architecture-conformance.sh`
- `alignment-check.sh --profile harness,mission-autonomy`

Purpose:
- prove release parity
- prove doc/runtime/root-manifest agreement
- prove contract registry and architecture surfaces describe one model

### 2. Lifecycle activation checks
- `validate-mission-lifecycle-cutover.sh`
- `validate-mission-source-of-truth.sh`
- `test-mission-lifecycle-activation.sh`

Purpose:
- prove scaffold remains authority-only
- prove seed-before-active is canonical
- prove active/paused missions cannot exist without seed-complete control truth
- prove continuity stubs, route linkage, summaries, mission view, and seed receipt exist after activation

### 3. Runtime admission and route checks
- `validate-mission-runtime-contracts.sh`
- `validate-mission-intent-invariants.sh`
- `validate-runtime-effective-state.sh`
- `validate-route-normalization.sh`

Purpose:
- prove current lease, mode, intent, slice, and route requirements
- prove observe-only is the only empty-intent carveout
- prove route precedence and provenance fields are populated
- prove no material route degrades to generic recovery fallback

### 4. Evidence and reducer checks
- `validate-mission-control-evidence.sh`
- `test-autonomy-burn-reducer.sh`

Purpose:
- prove every required control mutation emits a receipt
- prove burn and breaker transitions are evidence-derived
- prove safing and break-glass transitions are recorded and consumed consistently

### 5. Generated awareness checks
- `validate-mission-generated-summaries.sh`
- `validate-mission-view-generation.sh`

Purpose:
- prove every active autonomous mission has required summaries and mission view
- prove generated outputs cite their source roots
- prove generated outputs do not substitute for missing control or evidence truth

### 6. End-to-end scenario conformance
- `test-mission-autonomy-scenarios.sh`

Purpose:
- prove the final route, reducer, evidence, and generated-awareness model behaves correctly across the full scenario family

## Blocking validator set

### 1. Version and architecture
- `validate-version-parity.sh`
- `validate-architecture-conformance.sh`
- `alignment-check.sh --profile harness,mission-autonomy`

### 2. Lifecycle and source of truth
- `validate-mission-lifecycle-cutover.sh`
- `validate-mission-source-of-truth.sh`

### 3. Runtime contract family
- `validate-mission-runtime-contracts.sh`
- `validate-mission-intent-invariants.sh`
- `validate-runtime-effective-state.sh`
- `validate-route-normalization.sh`

### 4. Generated outputs and evidence
- `validate-mission-generated-summaries.sh`
- `validate-mission-view-generation.sh`
- `validate-mission-control-evidence.sh`

### 5. Scenario conformance
- `test-mission-autonomy-scenarios.sh`
- `test-mission-lifecycle-activation.sh`
- `test-autonomy-burn-reducer.sh`

## Required scenario fixtures

The scenario suite must prove at least:

1. routine low-risk housekeeping
2. long-running campaign/refactor
3. dependency/security patching
4. release-sensitive work
5. infrastructure drift correction
6. migration/backfill
7. external API sync
8. observe-only mission
9. incident containment
10. destructive work
11. absent human
12. late feedback
13. conflicting human input
14. breaker trip and safing
15. break-glass activation
16. reversible vs compensable vs irreversible action handling

Each fixture must exercise the same core proof contract:

- seeded activation
- route generation
- runtime admission
- control mutation receipts
- burn/breaker effects where applicable
- summary and mission-view generation
- fail-closed behavior when invariants are violated

## Lifecycle-specific checks

The lifecycle validator must prove:

- authority-only mission scaffold is intact
- seed-before-active path creates the full control family
- seed-before-active path creates continuity stubs
- route generation happens as part of seed or immediate post-seed sync
- summaries and mission view are generated for active autonomous missions
- active missions without seeded state fail validation

## Intent-specific checks

The intent validator must prove:

- empty intent is legal only for observe-only missions with no material operate slice
- material autonomous work without a current intent entry fails closed
- material autonomous work without a referenced action slice fails closed
- stale route or stale intent causes runtime tightening
- preview, proceed-on-silence, and promote eligibility all consume the same intent and slice

## Evidence-specific checks

The evidence validator must prove receipts exist for:

- mission seed
- directive add
- directive apply
- authorize-update add
- authorize-update apply
- schedule mutation
- lease mutation
- autonomy-budget transition
- breaker transition
- safing enter / exit
- break-glass enter / exit
- finalize block / unblock

It must also prove:

- each receipt points to a canonical mission control mutation or transition
- run evidence and control evidence remain separate
- summaries and digests render from canonical truth plus receipts rather than inventing missing state

## Generated-output-specific checks

The generated-output validators must prove:

- every active autonomous mission has `now.md`, `next.md`, `recent.md`, and `recover.md`
- every active autonomous mission has `mission-view.yml`
- operator digests are routed from subscriptions plus ownership policy
- every generated artifact cites its source roots
- root-manifest commit/rebuild policy is obeyed for each generated surface

## Required evidence bundle

The cutover is not proven until the branch can show:

- seed receipts for every active or paused autonomous mission
- fresh scenario-resolution artifacts linked from mode state
- required summaries and mission views for every active autonomous mission
- control receipts for every required mutation class
- run receipts that exercise reducer inputs where applicable
- migration evidence
- completion decision evidence

## CI posture

The architecture-conformance workflow must fail on any validator failure.
No MSRAOM-touching merge is allowed to bypass the full suite.

## Exit signal

MSRAOM closeout is validated only when:

- all validators pass locally and in CI
- scenario fixtures pass
- docs and root manifest align
- migration and evidence bundles are present
- the completion decision and migration evidence are present
- no acceptance criterion remains unmet
