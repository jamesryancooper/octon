# Validation Plan

## Validation Goals

Prove that the landed prompt publication and freshness model is:

1. structurally valid as an authored prompt-set contract
2. publishable through the extension effective publication path
3. retained as evidence-backed prompt alignment and publication receipts
4. fail-closed when the prompt bundle is stale or invalid
5. observable through run-level prompt provenance

## Required Validation Layers

### 1. Prompt-set contract validation

Validate the authored prompt-set manifest and confirm:

- all referenced prompt files exist
- stage and companion classifications are legal
- required repo anchor references exist
- invalidation conditions are structurally valid

### 2. Effective prompt publication validation

After extension publication:

- confirm the effective extension family publishes prompt bundle metadata
- confirm prompt asset projections are present where the design requires them
- confirm generation lock and receipt linkage include the prompt publication
  surfaces

### 3. Alignment receipt validation

Run a forced alignment cycle and confirm:

- a retained alignment receipt is produced
- bundle and anchor digests are recorded
- drift and decision status are captured explicitly

### 4. Fail-closed execution validation

Validate four cases:

1. fresh published bundle -> run allowed
2. stale bundle + successful re-alignment -> run allowed with new bundle
3. stale bundle + failed re-alignment -> run blocked
4. explicit `alignment_mode=skip` -> run allowed only with degraded retained
   disclosure

### 5. Run provenance validation

For a real concept-integration run, confirm retained run evidence records:

- prompt bundle id
- prompt bundle digest
- alignment receipt id
- effective alignment mode and execution state

### 6. Regression validation

Confirm:

- existing extension command and skill publication continues to work
- host projections remain clean
- capability routing does not regress

## Minimum Evidence For Closure

- one clean contract validation run
- one clean extension publication run including prompt bundle outputs
- one clean fail-closed stale-bundle rejection test
- one clean successful auto-realignment test
- one clean degraded skip-mode test with retained disclosure
- two consecutive clean real concept-integration runs with prompt provenance

## Explicit Non-Goals For Validation

- No support-target widening proof is required.
- No new runtime authority or policy truth is introduced.
- No separate workflow-classification proof is required.
