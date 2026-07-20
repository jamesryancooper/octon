# External Tool Integrity Amendment PR Publication

## Verdict

`published`

Draft PR 632 publishes the exact isolated external-tool-integrity candidate
from current `origin/main`. The PR is open, draft, and mergeable; its merge
state is blocked while hosted checks run.

## Identity

- Branch: `chore/external-tool-integrity`
- Candidate head: `95ab341cc6917d20b9cc450c34f2a2000151408c`
- Candidate tree: `1e50feec026b744918a392eaacaf7d0f8471e32e`
- Base: `origin/main@72391b18d9341bce4e7ba109ec8db11ef2389f92`
- PR: `https://github.com/jamesryancooper/octon/pull/632`

## Gate State

Local amendment, architecture, proposal-fixture, syntax, YAML, and Git diff
checks pass. The independent charter audit reports zero direct contradictions
and zero high-severity gaps. Hosted checks are pending; no readiness or landing
claim is made.

## Scope And Authority

The branch contains the constitutional amendment and fresh task-owned evidence
only. The dirty canonical-main checkout, proposal inputs, generated output,
provider state, credentials, runtime implementation, and architecture-
migration implementation are excluded. PR and generated evidence do not mint
runtime authority.

## Rollback And Cleanup

Retain or close the branch before landing. Revert a future protected-main
squash commit through a new PR after landing. Branch/worktree deletion and
local-main synchronization remain deferred under SI-00.

## Next Owner

PR 632 monitoring and review remediation under `closeout-pr`.
