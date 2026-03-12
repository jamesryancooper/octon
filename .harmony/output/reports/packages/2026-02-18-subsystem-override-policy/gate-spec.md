# Subsystem Override Gate Spec

## Inputs

- Weights: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/weights/weights.yml`
- Scorecard context (`profile`, `repo`, `run_mode`, `maturity`)
- Subsystem classes: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/subsystem-classes.yml`
- Override declarations: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/overrides.yml`
- Optional baseline weights for policy drift checks

## Hard Fail Checks

- `control-plane-override-missing-declaration`
- `control-plane-override-missing-adr`
- `control-plane-override-missing-changelog`
- `control-plane-override-class-violation`
- `control-plane-override-expired`
- `productivity-override-large-change-missing-adr` when `abs(new-old) >= large_change_threshold`
- `override-change-missing-deviation-record` for changed repo overrides when `weights.yml` changed
- Existing governance checks remain hard fail:
  - `weights-version-bump-missing`
  - `weights-changelog-entry-missing`
  - `weights-rationale-missing`
  - `weights-adr-missing`

## Soft Warn Checks

- `control-plane-override-missing-expiry`
- `productivity-override-missing-declaration`
- `productivity-override-missing-expiry`
- `baseline-weights-missing`
- `baseline-scores-missing`

## Severity Rationale

- Control-plane surfaces are delivery/safety governance boundaries; silent override drift can invalidate harness guarantees.
- Productivity surfaces are lower risk; warnings preserve iteration speed while still surfacing drift.
- Large productivity changes can materially affect behavior and require ADR-level review.

## Phase Behavior

- `phase0`: policy override failures downgrade to warnings (grace period).
- `phase1`: control-plane hard enforcement + productivity large-change ADR hard requirement.
- `phase2`: same as phase1 plus teams may opt into strict warnings (`--strict-warnings`) in CI.
- Current repository posture: `phase2`.
