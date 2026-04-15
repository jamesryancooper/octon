# Current-State Gap Map

## Observed Current State

- The concept-integration prompt set is now pack-local under the
  `octon-concept-integration` extension pack.
- The skill exposes an `alignment_mode` parameter with default `auto`.
- The pack contains a dedicated prompt-set alignment companion prompt.
- The stage prompts are already repository-grounded and inspect live repo
  anchors before making current-state claims.
- Effective extension publication already exists for command and skill routing
  exports under `generated/effective/extensions/**`.
- The native prompt modeling service already exists as a fail-closed harness
  service for structured prompt compilation.

## What Is Still Missing

### 1. No authored prompt-set contract

The prompt set exists as files and a README, but there is no authored machine-
readable contract describing:

- the prompt-set identity
- the stage/companion inventory
- required anchor digests
- invalidation conditions
- alignment policy defaults

### 2. No first-class generated prompt bundle

The extension effective family currently publishes routing-oriented metadata for
commands and skills, but it does not publish a first-class prompt bundle that
the skill can trust as its runtime-facing prompt source.

### 3. `alignment_mode=auto` is not fail-closed

Today the pack is set up for adaptation, but the skill contract does not yet
bind execution to a retained freshness receipt and alignment result.

### 4. No retained alignment receipt family

There is no canonical retained evidence family for prompt-set alignment runs,
drift notes, or safe-to-run bundle state.

### 5. No run-level prompt provenance

Concept-integration run evidence does not yet record a structured prompt bundle
identity and alignment receipt for each run.

### 6. The native prompt service is not yet integrated

Octon already has a harness-native prompt compilation service, but the
concept-integration pack does not yet reuse it for deterministic prompt bundle
rendering or hashing.

## Resulting Design Pressure

The hardening path should:

- keep authored prompt source in the pack
- publish runtime-facing prompt bundle state under generated effective outputs
- retain prompt freshness evidence under state/evidence
- fail closed when alignment is stale or invalid
- and record bundle provenance in every concept-integration run
