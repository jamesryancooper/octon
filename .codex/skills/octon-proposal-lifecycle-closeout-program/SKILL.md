---
name: octon-proposal-lifecycle-closeout-program
description: Run the closeout-program bundle.
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

# Program - Closeout

Program closeout must refuse final or implementation-ready claims unless every
required packet-level completeness receipt passes or the program records an
explicit blocked/deferred report outcome or rejected/superseded/historical
archive disposition.

For implemented child packets, program closeout must also require passing
implementation conformance and post-implementation drift/churn receipts. A
program may aggregate child receipts, but it may not replace the packet-level
post-implementation evidence.

Program closeout also requires parent-local aggregate
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` receipts with
`child_authority_preserved: yes`. It then writes only parent-local
`support/proposal-closeout.md`; that receipt never satisfies child receipts,
child promotion targets, child validation verdicts, child archive metadata, or
child terminal outcomes.

Before claiming parent archive readiness, run the read-only worktree hygiene
classifier:

```sh
.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target <program-path> --lifecycle proposal-program --format yaml
```

Pass `--run-id <run-id>` when the lifecycle run id is available. If the
classifier reports any `foreign-or-ambiguous` paths, write or refresh the
parent-local `support/proposal-closeout.md` with `verdict: blocked`,
`archive_authorized: no`, `selected_git_route: stage-only-escalate`,
`worktree_hygiene_verdict: blocked`,
`worktree_hygiene_blocker_class: worktree-hygiene-blocked`, the three hygiene
path counts, a `worktree_hygiene_evidence` reference to the classifier output,
and `next_route_condition: closeout-change or operator scope resolution`. Do
not stage, commit, push, delete, reset, archive, or otherwise clean worktree
paths from this route.

Execute gated program closeout after required child lifecycle states are
implemented, archived, rejected, superseded, or covered by an explicitly
deferred report outcome.
