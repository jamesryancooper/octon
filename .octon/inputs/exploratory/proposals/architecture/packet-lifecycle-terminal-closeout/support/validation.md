# Validation

## Proposal Validation Commands

Run these after packet creation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
```

## Future Implementation Validation

- Validate packet terminal closeout profile schema.
- Validate packet terminal closeout receipt schema.
- Validate workflow shape and workflow registry entries.
- Validate command and skill manifest entries.
- Validate proposal lifecycle hook changes.
- Validate implementation conformance and post-implementation drift/churn gates.
- Validate publication freshness and publisher refresh behavior.
- Validate generated/input non-authority coverage.
- Validate run-health and capability/extension publication coverage.
- Validate repo-hygiene and worktree hygiene handling.
- Validate Git/GitHub exact-SHA hosted check handling.
- Validate branch landing and branch cleanup authorization gates.
- Validate post-integration architecture review evidence-only boundary.
- Validate packet terminal evaluator evidence-only boundary.
- Validate archive-proposal ownership of archive relocation.
- Run `git diff --check`.

## Negative Controls

- Missing implementation conformance receipt fails.
- Missing post-implementation drift/churn receipt fails.
- Publication freshness repair without canonical publisher fails.
- Direct generated output authority fails.
- Proposal input authority fails.
- Worktree hygiene blocked by non-packet residue fails archive-ready verdict.
- Repo hygiene deletion without authorization fails.
- Hosted branch-no-pr landing without exact-SHA checks fails.
- Branch cleanup without cleanup authorization fails.
- Lifecycle-postmortem output used as authority fails.
- Post-integration architecture review output used as authority fails.
- Terminal receipt that moves the packet to archive fails.

## Run Log

- 2026-06-12: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout`
  initially found the generated proposal registry projection stale for the new
  packet.
- 2026-06-12: `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`
  refreshed `.octon/generated/proposals/registry.yml` through the canonical
  publisher. Result: `Registry generation summary: errors=0`.
- 2026-06-12: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout`
  passed after the canonical registry refresh. Result: `Validation summary:
  errors=0 warnings=12`.
- 2026-06-12: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout`
  passed. Result: `Validation summary: errors=0 warnings=0`; final aggregate
  result: `Validation summary: errors=0`.
- 2026-06-12: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout`
  passed. Result: `Validation summary: errors=0 warnings=0`.
