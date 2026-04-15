# Acceptance Criteria

The proposal is ready to promote when all of the following are true.

## Authored Contract

- A prompt-set manifest exists under the pack-local prompt root.
- The manifest fully describes stage prompts, companion prompts, anchor refs,
  and invalidation conditions.

## Effective Publication

- The extension effective family publishes a first-class prompt bundle view or
  equivalent structured prompt publication metadata.
- Effective prompt publication is covered by generation-lock and retained
  publication receipt linkage.

## Fail-Closed Behavior

- `alignment_mode=auto` is runtime-enforced, not only conventional.
- Stale or invalid prompt bundles fail closed when re-alignment cannot repair
  them.
- `alignment_mode=skip` is explicit, retained, and visibly degraded.

## Run Provenance

- Every concept-integration run records the prompt bundle id and alignment
  receipt it consumed.
- Prompt provenance lives in retained evidence, not only in generated state.

## Service Reuse

- The final design reuses the native prompt modeling service where it materially
  improves deterministic bundle publication and hashing, or explicitly justifies
  why equivalent deterministic behavior is achieved without extending that
  service.

## Regression Safety

- Extension command and skill publication remain valid.
- Capability routing remains valid.
- Host projections remain valid.

## Closure Gate

- Two consecutive clean runs prove fresh-bundle success.
- At least one stale-bundle failure proves fail-closed behavior.
- At least one successful auto-realignment proves recovery.
- At least one explicit skip-mode run proves degraded disclosure handling.
