# Proposed `.harmony/` File Layout for Weighted Assurance Governance

## Authoritative Weight Sources
- `.harmony/assurance/governance/weights/weights.yml`
  - Machine-readable source of truth for profiles, overrides, and deprecation.
- `.harmony/assurance/governance/weights/weights.md`
  - Human-readable rationale and governance contract.

## Weight Governance and Decisions
- `.harmony/cognition/decisions/ADR-0xxx-weighted-quality-governance.md`
  - Records major weighting strategy shifts.
- `.harmony/cognition/decisions/ADR-0xxx-5v5-conflict-<topic>.md`
  - Required for unresolved `5 vs 5` attribute trade-offs.

## Inputs for Scoring Runs
- `.harmony/assurance/governance/scores/scores.yml`
  - Subsystem-by-attribute measured scores and evidence pointers.
- `.harmony/assurance/governance/weights/inputs/context.yml`
  - Active context (`repo`, `maturity`, `run_mode`, selected profile).

## Runtime State for Gates
- `.harmony/assurance/runtime/_ops/state/active-weight-context.lock.yml`
  - Resolved context used by current run.
- `.harmony/assurance/runtime/_ops/state/effective-weights.lock.yml`
  - Effective weights snapshot after overrides.

## Scripts / Services Consuming Weights
- `.harmony/assurance/runtime/_ops/scripts/compute-assurance-score.sh`
  - Deterministic score computation and delta generation.
- `.harmony/assurance/runtime/_ops/scripts/assurance-gate.sh`
  - Hard-fail/soft-warn enforcement.
- `.harmony/runtime/crates/*` or equivalent WASM service
  - Optional runtime implementation of same algorithm.

## Published Outputs
- `.harmony/output/assurance/scorecards/<YYYY-MM-DD>/<run-id>/scorecard.md`
- `.harmony/output/assurance/scorecards/<YYYY-MM-DD>/<run-id>/scorecard.yml`
- `.harmony/output/assurance/scorecards/<YYYY-MM-DD>/<run-id>/effective-weights.yml`
- `.harmony/output/assurance/scorecards/<YYYY-MM-DD>/<run-id>/regressions.md`

## CI/Local Integration Points
- CI workflow step calls `compute-assurance-score.sh` then `assurance-gate.sh`.
- Local command mirrors CI behavior for deterministic preflight checks.
- Both must read `weights.yml` and never hardcode weights in scripts.
