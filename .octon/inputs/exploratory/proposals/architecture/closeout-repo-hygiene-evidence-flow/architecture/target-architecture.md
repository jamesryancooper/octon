# Target Architecture

_Status: Accepted child target architecture_

## Target State

1. Repo-hygiene cleanup writes raw helper output and sensitive path details to `.octon/state/evidence/local/runs/skills/repo-hygiene-cleanup/<run-id>/` when they are local-only.
2. Repo-hygiene cleanup writes concise publishable receipts under `.octon/state/evidence/runs/skills/repo-hygiene-cleanup/<run-id>/` for hosted/shared claims.
3. Closeout-change and branch-no-pr hosted cleanup depend on publishable receipts and disclosure, not raw local logs.
4. The default work unit policy distinguishes local debugging evidence from publishable closeout evidence.

## Authority Boundary

This child may propose durable changes only under its promotion targets. It
must preserve the parent program's rule that local raw evidence, generated read
models, raw inputs, and proposal-local files do not satisfy evidence or closeout
gates.

## Non-Target State

The child does not target a clean-sheet evidence-store redesign, raw transcript
publication, generated-output authority, or parent-owned child receipt truth.
