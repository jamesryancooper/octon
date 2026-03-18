# Proposed `.octon/` File Layout for Weighted Assurance Governance

## Authoritative Weight Sources
- `.octon/framework/assurance/governance/weights/weights.yml`
  - Machine-readable source of truth for profiles, overrides, and deprecation.
- `.octon/framework/assurance/governance/weights/weights.md`
  - Human-readable rationale and governance contract.

## Weight Governance and Decisions
- `.octon/framework/cognition/decisions/ADR-0xxx-weighted-quality-governance.md`
  - Records major weighting strategy shifts.
- `.octon/framework/cognition/decisions/ADR-0xxx-5v5-conflict-<topic>.md`
  - Required for unresolved `5 vs 5` attribute trade-offs.

## Inputs for Scoring Runs
- `.octon/framework/assurance/governance/scores/scores.yml`
  - Subsystem-by-attribute measured scores and evidence pointers.
- `.octon/framework/assurance/governance/weights/inputs/context.yml`
  - Active context (`repo`, `maturity`, `run_mode`, selected profile).

## Runtime State for Gates
- `.octon/framework/assurance/runtime/_ops/state/active-weight-context.lock.yml`
  - Resolved context used by current run.
- `.octon/framework/assurance/runtime/_ops/state/effective-weights.lock.yml`
  - Effective weights snapshot after overrides.

## Scripts / Services Consuming Weights
- `.octon/framework/assurance/runtime/_ops/scripts/compute-assurance-score.sh`
  - Deterministic score computation and delta generation.
- `.octon/framework/assurance/runtime/_ops/scripts/assurance-gate.sh`
  - Hard-fail/soft-warn enforcement.
- `.octon/runtime/crates/*` or equivalent WASM service
  - Optional runtime implementation of same algorithm.

## Published Outputs
- `.octon/generated/assurance/scorecards/<YYYY-MM-DD>/<run-id>/scorecard.md`
- `.octon/generated/assurance/scorecards/<YYYY-MM-DD>/<run-id>/scorecard.yml`
- `.octon/generated/assurance/scorecards/<YYYY-MM-DD>/<run-id>/effective-weights.yml`
- `.octon/generated/assurance/scorecards/<YYYY-MM-DD>/<run-id>/regressions.md`

## CI/Local Integration Points
- CI workflow step calls `compute-assurance-score.sh` then `assurance-gate.sh`.
- Local command mirrors CI behavior for deterministic preflight checks.
- Both must read `weights.yml` and never hardcode weights in scripts.
