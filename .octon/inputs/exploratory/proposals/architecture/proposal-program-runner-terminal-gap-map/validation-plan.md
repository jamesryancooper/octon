# Validation Plan

## Packet Validators

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map --print-digest`

## Downstream Validation Floor

- Workflow retry ids: unit or integration coverage proving retry attempts do
  not reuse an existing workflow run id unless same-input, same-authority,
  same-target replay proof is present.
- Closeout handoff: contract and runner tests proving closeout/worktree
  checkpoints are non-authorizing and route-owned.
- Aggregate blockers: program plan and closeout tests proving parent evidence
  summarizes but does not synthesize child receipts.
- Promotion binding: tests proving selected child identity, receipt digests,
  write-scope digest, authority-zone decision, and route delegation basis are
  present before workflow-owned promotion dispatch.
- Publication freshness: tests proving stale generated/effective projections
  are classified and route to declared publication recovery without treating
  generated output as authority.
- Parent review churn: review-gate tests proving volatile run-control and
  route-created evidence do not stale parent review receipts.
- Archive observation: observer tests proving archive completion is observed
  at the archived target after active-path moves.
- Terminal routing regression: end-to-end fixture covering the original
  duplicate workflow id failure pattern and the fail-closed recovery path.

## Registry And Checksum Posture

This packet does not maintain `SHA256SUMS.txt`. The proposal registry
projection must be refreshed only if `proposal.yml` registry-relevant state
changes; this revision keeps `proposal.yml#status` as `in-review` and does not
change registry-relevant fields.
