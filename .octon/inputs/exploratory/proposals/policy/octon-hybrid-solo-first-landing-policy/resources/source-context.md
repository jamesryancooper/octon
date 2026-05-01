# Source Context

## Problem

Octon now has Change-first route vocabulary, but the current live GitHub
default-branch ruleset requires pull requests for `main`. That makes hosted
`branch-no-pr` landing impossible even though the policy intends
`branch-no-pr` to support more than local checkpointing.

The mismatch caused a recent closeout to begin as no-PR branch landing, fail
when publishing to protected `main`, and then convert to PR-backed landing. The
final repository evidence was corrected, but the model should prevent that
route mismatch before landing.

## Current GitHub Main Ruleset Facts

Live ruleset: `Main Branch Guardrails (PR + CI + Codex)`.

Observed rules:

- default branch target
- deletion protection
- required status checks with strict required status policy
- universal pull request requirement
- allowed merge method limited to squash for PRs
- non-fast-forward protection
- required linear history
- no bypass actors
- current user cannot bypass

Implication: under current provider rules, hosted `branch-no-pr landed` must
fail preflight. It may remain local evidence or `published-branch`, but it
cannot honestly claim hosted `main` landing.

## Target User

Primary target: solo maintainer shipping quickly while retaining validation,
rollback, durable receipts, hosted enforcement, and clear failure modes.

Compatibility target: very small trusted team where no-PR landing authority can
be restricted to maintainers or a narrow app while collaborative or high-risk
Changes still route to PR.

## Boundary

This packet owns Octon-internal policy and tooling. It records the GitHub
ruleset target but does not directly mutate live GitHub settings. Live ruleset
and `.github/**` workflow changes require a linked repo-local projection packet.
