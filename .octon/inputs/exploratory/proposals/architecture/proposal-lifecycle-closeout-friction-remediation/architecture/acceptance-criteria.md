# Acceptance Criteria

The implementation is acceptable only when all applicable criteria pass.

## Lifecycle Sequencing

- Proposal acceptance still requires proposal review, strict pre-integration
  architecture review, and implementation-grade completeness.
- Implementation prompt generation or refresh has a validator-backed route to
  refresh proposal review digest before implementation authorization.
- Terminal closeout refuses archive-ready claims when publication freshness is
  stale or generated projections require hand edits.

## Publication Freshness

- Capability, extension, runtime route, host projection, proposal registry,
  proposal artifact, and runtime-effective handle checks have a clear
  pre-terminal validation bundle.
- Generated output refresh remains owned by publication or registry scripts.
- Negative controls prove stale generated projections fail closed.

## Archive And Cleanup

- Archive workflow residue is classified deterministically.
- Eligible untracked local run residue can be authorized for cleanup without
  touching active control state or durable evidence.
- Manual-review archive control/evidence residue remains retained or escalated
  with rationale.
- Negative controls prove cleanup detection is not deletion authority.

## Branch-No-PR

- Empty hosted check sets require explicit retained rationale or fail
  validation.
- Hosted no-PR landing still requires exact source SHA, landing authorization,
  fast-forward proof, and final `origin/main == landed_ref`.
- Branch cleanup still requires containment, no open PR, rollback posture, and
  governed cleanup authorization before local or remote branch deletion.

## Operator Guidance

- Git helpers identify likely sandbox/network/ref-write failures and the
  governed rerun path without suggesting an authority bypass.
- Documentation or skill guidance reflects the helper behavior.
- Operator-facing aggregate packet delivery wrapper surfaces remain excluded
  from this packet and are owned by `proposal-packet-delivery-wrapper`.

## Evidence And Closeout

- Implementation conformance and post-implementation drift/churn receipts pass.
- Terminal current-state proof validates after the final mutation.
- Final validation includes `git diff --check`.
- Final worktree is clean.
