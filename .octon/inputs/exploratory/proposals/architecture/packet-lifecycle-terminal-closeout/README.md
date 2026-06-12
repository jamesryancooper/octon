# Proposal Packet Lifecycle Terminal Closeout

## Findings

High: implemented packet closeout has the right component gates but lacks one
packet-local terminal workflow that owns the sequence from implemented packet
to archive-ready or blocked verdict.

High: terminal closeout evidence can dirty the worktree. Publication freshness
repair can add generated outputs and publication receipts. GitHub protected
main rules can require exact source-SHA checks before main moves. Today those
steps are manually chained, which makes archive readiness dependent on operator
memory instead of deterministic receipt validation.

High: proposal program lifecycle has the better pattern: parent-local aggregate
receipts summarize child state while preserving child authority. Packet
lifecycle needs an analogous packet-local terminal receipt at the implemented
packet boundary.

Medium: lifecycle-postmortem and post-integration architecture review are
valuable evidence-only hooks, but neither can authorize closeout, archive
readiness, publication, promotion, cleanup, or Git mutation.

## Recommendation

Implement a native `proposal-packet-terminal-closeout` workflow. It should
verify durable implementation state, run implementation conformance and
post-implementation drift/churn gates, validate or refresh publication
freshness through canonical publishers, classify repo and worktree hygiene,
route Git/GitHub exact-SHA requirements through existing closeout mechanics,
run evidence-only review hooks, and emit one packet-local aggregate terminal
receipt.

The receipt may authorize an archive-ready verdict. It must not move the packet
to the archive. Archive relocation remains owned by the separate
`archive-proposal` lifecycle route.

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- rationale: The future implementation is a cross-domain workflow, schema,
  validator, evaluator, command, skill, and lifecycle hook surface. It should
  land atomically so packet terminalization does not become another partial
  lifecycle layer.
- proposal_authority: non-authoritative input packet only

## Current-State Problem

The implemented packet closeout path currently requires manual coordination of:

- durable implementation state checks;
- `support/implementation-conformance-review.md`;
- `support/post-implementation-drift-churn-review.md`;
- publication freshness and generated projection validators;
- canonical publisher refreshes when freshness fails;
- generated/input non-authority checks;
- run-health and capability or extension publication checks;
- repo-hygiene and worktree hygiene classification;
- evidence-only post-integration architecture review;
- optional lifecycle-postmortem evidence;
- Change closeout, worktree closeout, and repo hygiene cleanup routes;
- GitHub exact source-SHA checks and hosted check waiting;
- final closeout receipt, branch cleanup, main sync, and archive readiness.

The absence of a packet terminal aggregate receipt leaves agents and operators
stitching those steps together by hand.

## Target Architecture

Packet terminal closeout is a packet lifecycle workflow with a strict profile
and terminal receipt. It delegates material effects to existing owners, then
validates their returned evidence.

The workflow may:

- choose the next required terminalization step from current repository state;
- run read-only validators;
- invoke canonical publishers when freshness validators say publication is
  stale;
- invoke repo-hygiene, closeout-worktree, closeout-change, or Git/GitHub helper
  routes only when their own policy authorizes mutation;
- run evidence-only review hooks;
- emit an aggregate terminal receipt.

The workflow may not:

- archive the packet;
- directly edit generated outputs as source truth;
- delete local residue without repo-hygiene authority;
- stage, commit, push, land, or delete branches outside the selected closeout
  route;
- make lifecycle-postmortem or architecture review authoritative;
- let proposal inputs, generated outputs, host state, dashboards, chat, tool
  state, or model memory authorize anything.

## Packet Contents

This packet defines the architecture, implementation plan, acceptance criteria,
source findings, reconnaissance, readiness receipt, validation plan, source of
truth map, and post-implementation receipt scaffolds. It does not implement the
workflow or authorize terminal closeout.
