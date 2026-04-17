# Cutover Checklist

## Before implementation

- [ ] Confirm this packet is the accepted current workflow packet
- [ ] Confirm no active sibling proposal already owns the same closeout-gate rewrite
- [ ] Confirm GitHub remains the intended host control plane
- [ ] Confirm worktree-capable Git environments remain in scope

## During implementation

- [ ] Add `branch_closeout_gate` to ingress manifest
- [ ] Update ingress `AGENTS.md`
- [ ] Rewrite workflow docs to remove environment-specific overfit
- [ ] Clarify review-thread semantics in PR standards and remediation skill
- [ ] Align companion PR-template wording in the implementation branch
- [ ] Clarify helper-script readiness and cleanup semantics

## Before closeout

- [ ] Proposal validators pass
- [ ] Proposal registry rebuild succeeds
- [ ] Scenario matrix passes
- [ ] No stale fixed closeout prompt remains in durable workflow docs
- [ ] No stale reviewer-resolution wording remains in aligned surfaces
- [ ] No new blocker is introduced
