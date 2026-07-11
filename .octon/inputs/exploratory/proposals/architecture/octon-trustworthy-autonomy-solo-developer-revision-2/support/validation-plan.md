# Validation Plan

## Packet Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-trustworthy-autonomy-solo-developer-revision-2 --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-trustworthy-autonomy-solo-developer-revision-2`
- `python3 .octon/inputs/exploratory/proposals/architecture/octon-trustworthy-autonomy-solo-developer-revision-2/support/validate-evidence-appendix.py`
  applies Draft 2020-12 plus `FormatChecker`, unique finding IDs, exact
  top-level commit/environment/host agreement, and the prohibition on
  dynamic/adversarial proof labels for architectural inferences.
- `python3 .octon/inputs/exploratory/proposals/architecture/octon-trustworthy-autonomy-solo-developer-revision-2/support/validate-packet-coverage.py`
  checks artifact-catalog parity, required architecture files, all twelve
  decision field contracts, and all eight representative workflows.

The registry check is intentionally separated because
`.octon/generated/proposals/registry.yml` had pre-existing unrelated edits.
The canonical generator must be run by the owning proposal lifecycle route
after those changes are reconciled.

## Pre-Implementation Gate

Before acceptance or implementation authorization:

- run the strict pre-integration architecture review;
- approve, reject, or revise each of the twelve decisions;
- create a separate repo-local provider-projection Change for `.github/**`;
- confirm promotion-target and implementation-map coverage;
- confirm no constitutional challenge is required.

## Runtime Validation

The target state is not proven by packet validators. Runtime completion
requires the behavioral, concurrency, crash, provider, security, recovery, and
usability evidence enumerated in the acceptance criteria and evidence plan.
