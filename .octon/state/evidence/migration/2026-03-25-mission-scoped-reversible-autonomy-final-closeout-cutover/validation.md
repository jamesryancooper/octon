# Validation

- [x] `validate-version-parity.sh` passes at `0.6.3`.
- [x] `validate-mission-lifecycle-cutover.sh` passes.
- [x] `validate-mission-intent-invariants.sh` passes.
- [x] `validate-route-normalization.sh` passes.
- [x] `validate-mission-view-generation.sh` passes.
- [x] `validate-mission-generated-summaries.sh` passes.
- [x] `validate-mission-control-evidence.sh` passes with `lease_mutation`
      coverage included.
- [x] `test-mission-lifecycle-activation.sh` passes.
- [x] `test-autonomy-burn-reducer.sh` passes.
- [x] `validate-mission-runtime-contracts.sh` passes.
- [x] `validate-mission-effective-routes.sh` passes.
- [x] `validate-mission-source-of-truth.sh` passes.
- [x] `test-mission-autonomy-scenarios.sh` passes.
- [x] `validate-extension-publication-state.sh` passes after republishing
      extension effective outputs for the `0.6.3` manifest change.
- [x] `validate-capability-publication-state.sh` passes after republishing
      capability routing for the `0.6.3` manifest change.
- [x] `validate-runtime-effective-state.sh` passes.
- [x] `alignment-check.sh --profile mission-autonomy` passes.

## Notes

- The broader `harness` alignment profile was not rerun as part of this
  closeout bundle; the mission-autonomy profile and umbrella runtime-effective
  gate passed cleanly.
