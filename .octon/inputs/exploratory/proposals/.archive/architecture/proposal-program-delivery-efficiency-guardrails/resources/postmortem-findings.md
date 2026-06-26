# Postmortem Findings

## Summary

The completed operator-free lifecycle delivery run exposed an enforcement gap. Octon had many correct rules, but too many were prompt-level or documentation-level instead of early machine gates. The result was inefficient sequencing, stale evidence, repeated blockers, and expensive dirty-worktree recovery.

## Findings

### Canonical Order Was Not Enforced Strongly Enough

The efficient order should be mandatory by default:

`child implementation -> child validation -> child closeout -> child archive -> parent/program delivery -> landing/sync/cleanup`

An operator-requested alternative order should stop the run, warn about cost and stale-evidence risk, and require an explicit retained override receipt before proceeding.

### Preflight Gates Ran Too Late Or Were Fragmented

The run discovered major blockers after substantial work:

- Git index write access was unavailable in one runtime.
- Parent review digest evidence was stale.
- Readiness projection and child readiness had incompatible validation receipt semantics.
- The delivery source branch was stale and contained unclassified residue.

These should be handled in one early delivery readiness preflight.

### Validator Semantics Drifted

`validate-proposal-program-readiness-projection.sh` rejected archived child validation receipts that `validate-proposal-program-child-readiness.sh` accepted. A later compatibility fix addressed that instance, but the durable lesson is to share receipt semantics instead of duplicating logic across validators.

### Dirty/Stale Worktree Recovery Was Too Expensive

The durable recovery route was a clean route-owned worktree from current `origin/main` plus exact include-path classification. Delivery should select that route immediately when the source branch is stale or dirty.

### Formal Postmortem Closeout Was Not Completed

The lifecycle postmortem validator existed, but the run did not end with a valid formal postmortem. The validator reported missing `evaluation.yml`, `report.md`, `readiness-summary.md`, and stale digest-bound references.

## Required Improvement Theme

The improvement is not more prose. The improvement is moving these requirements into schemas, validators, workflow stops, shared helper libraries, route selection, and retained receipts.
