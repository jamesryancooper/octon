---
name: octon-proposal-lifecycle-closeout-packet
description: Run the closeout-packet bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Bash(git status) Bash(git diff) Bash(gh pr) Bash(.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh *) Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Proposal Lifecycle: Closeout Packet

Execute gated closeout for one proposal packet. Refuse closeout when required
packet receipts, evidence, archive state, final hygiene, or route-required
staging, review, check, PR, merge, branch-cleanup, or sync gates fail. Red
route-required checks require remediation, not status-only waiting.

Closeout must refuse final, accepted, implemented, archive-ready, or
implementation-ready claims unless `support/implementation-grade-completeness-review.md`
passes and the implementation-readiness validator succeeds. For implemented
closeout or implemented archival, also refuse unless
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` pass their validators with
no unresolved items, or the packet records an explicit blocked/deferred report
outcome or a rejected/superseded/historical archive disposition instead of a
successful closeout.

Before claiming archive readiness, run the read-only worktree hygiene
classifier:

```sh
.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target <packet-path> --lifecycle proposal-packet --format yaml
```

Pass `--run-id <run-id>` when the lifecycle run id is available. If the
classifier reports any `foreign-or-ambiguous` paths, write or refresh
`support/proposal-closeout.md` with `verdict: blocked`,
`archive_authorized: no`, `selected_git_route: stage-only-escalate`,
`worktree_hygiene_verdict: blocked`,
`worktree_hygiene_blocker_class: worktree-hygiene-blocked`, the three hygiene
path counts, a `worktree_hygiene_evidence` reference to the classifier output,
and `next_route_condition: closeout-change or operator scope resolution`. Do
not stage, commit, push, delete, reset, archive, or otherwise clean worktree
paths from this route.

Successful closeout writes or refreshes `support/proposal-closeout.md` with at
least `verdict`, `closed_at`, and `archive_authorized`. Use `verdict: pass` and
`archive_authorized: yes` only when the packet is ready for the separate
`archive-proposal` lifecycle route. Closeout must not archive the packet
directly.

When closeout is blocked because follow-on work is owned by another lifecycle,
emit a typed `lifecycle-interaction-request-v1` receipt only as dependency
context. Use the `handoff` profile with `interaction_kind:
follow_on_work_required`, bind the source run, phase, target, include/exclude
scope, evidence refs, required forbidden authority-transfer entries, stop
conditions, and expected return evidence. The request must not authorize Change
Closeout, Worktree Closeout, Repo Hygiene, Git/ref mutation, hosted-provider
actions, promotion, cleanup, or archive. The source packet cannot claim the
dependency is resolved until a validating `lifecycle-interaction-return-v1`
receipt cites fresh target-owned return evidence.
