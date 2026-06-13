# Promotion Route Recovery Note

- run_id: `20260613T180325Z`
- target_packet: `.octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts`
- attempted_route: `promote-proposal`
- workflow_evidence_ref: `.octon/state/evidence/runs/workflows/2026-06-13-promote-proposal-octon-inputs-exploratory-proposals-architecture-repo-hygiene-cleanup-authorization-receipts-1/`

## Observed State

The canonical `promote-proposal` workflow accepted the route inputs, completed
the validate-proposal stage, and rewrote `proposal.yml` to
`status: implemented`. The stage executor then stopped advancing after the
promote-proposal execution-start checkpoint and was interrupted after repeated
no-progress polling.

The workflow-owned generator step had not refreshed the generated proposal
registry or packet artifact index/spine before interruption.

## Repair Route

Generated freshness was repaired only through owning generators:

- `generate-proposal-registry.sh --write`
- `generate-proposal-artifact-index.sh --proposal <packet> --write --root <repo>`

The post-repair freshness validator passed:

- `.octon/state/evidence/validation/proposals/repo-hygiene-cleanup-authorization-receipts/20260613T180325Z/validate-lifecycle-terminal-freshness-after-generator-repair.log`

## Non-Authority Boundaries

This note is retained recovery evidence only. It does not replace the
`promote-proposal` workflow contract, authorize archive movement, authorize
cleanup, or substitute for terminal closeout.
