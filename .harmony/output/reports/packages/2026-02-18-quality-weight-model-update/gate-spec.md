# gate-spec.md

## Gate Inputs

- Resolver artifact: `scorecard.yml`
- Current policy: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/weights/weights.yml`
- Current scores: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/scores/scores.yml`
- Optional baseline policy/scores from base commit

## Hard-Fail Checks

1. Weight change governance (policy changed vs baseline)
- Missing policy version bump.
- Missing changelog entry for current version.
- Missing/empty changelog rationale.
- Missing/invalid ADR reference.

2. Mandatory assurance checks (non-local modes)
- Missing acceptance criteria for effective weight 5 attributes.
- Missing evidence for effective weight 5 attributes in `ci/release/prod-runtime`.
- High-weight regressions beyond threshold:
  - `weight >= 5` and `delta <= -0.5`
  - `weight >= 4` and `delta <= -1.0`
- Missing ADR for unresolved `5 vs 5` conflicts.

3. Score evidence requirements
- Any score `<= 2` without evidence pointer(s) in `ci/release/prod-runtime`.
- Any high-weight (`>=4`) regression without evidence pointer(s) in `ci/release/prod-runtime`.

## Soft-Warn Checks

- Baseline policy missing (cannot verify silent weight nudges).
- Baseline scores missing (limited drift detection).
- Missing evidence for weight 5 in local mode.
- Missing criteria/evidence for weight 4 in less strict contexts.
- Medium regressions (`weight >=4` and `-1.0 < delta <= -0.5`).
- Score `<= 2` without evidence in local mode.
- High-weight regression without evidence in local mode.

## Why Hard vs Warn

- `Hard fail` is used when governance integrity or high-assurance quality posture would be compromised in CI/release contexts.
- `Soft warn` is used for local iteration speed or when baseline comparison data is unavailable.

## Check List (Implementation)

- `weights-version-bump-missing`
- `weights-changelog-entry-missing`
- `weights-rationale-missing`
- `weights-adr-missing`
- `missing-criteria-w5`
- `missing-evidence-w5`
- `regression-w5`
- `regression-w4-hard`
- `missing-adr-5v5`
- `missing-evidence-low-score`
- `missing-evidence-regression-high-weight`
- `baseline-weights-missing` (warn)
- `baseline-scores-missing` (warn)
