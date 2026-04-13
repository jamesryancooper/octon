# Task: Repo-Consequential Preflight

## Context

Use this before broad verification in repo-consequential workflows. It is the
canonical place to classify branch freshness and repo-shell verification
readiness before tests or large repo-wide validation runs.

## Failure Conditions

- The repo-owned branch freshness policy is missing.
- Upstream branch freshness cannot be determined and policy does not permit a
  warn-only path.
- Repo-shell execution classes identify the intended verification command as
  blocked or escalated.

## Flow

1. Load policy posture
   - Read `/.octon/instance/governance/policies/branch-freshness.yml`.
   - Read `/.octon/instance/governance/policies/repo-shell-execution-classes.yml`.
2. Classify freshness
   - Compare the current branch against its upstream tracking ref.
   - Classify one of: `fresh`, `ahead-no-upstream`, `behind`, `diverged`,
     `unknown`.
3. Gate broad verification
   - If the selected verification command is in a `broad-verification` class,
     block or stage-only according to branch freshness policy.
   - Record the resulting decision so downstream task workflows do not confuse
     stale branch state with a new regression.
4. Record retained evidence
   - Emit a retained preflight result that can back
     `checkpoints/repo-consequential-preflight.yml`.
   - Emit a short operator summary that cites `branch-freshness`,
     `repo-shell-classification`, or `repo-consequential-preflight` when
     blocking or warning.

## Required Outcome

- One canonical branch freshness result retained before broad
  repo-consequential verification proceeds.
