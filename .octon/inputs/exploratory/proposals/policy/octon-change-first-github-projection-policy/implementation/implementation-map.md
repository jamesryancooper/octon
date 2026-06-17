# Implementation Map

Target families:

- Route-aware main and closeout projection:
  `.github/workflows/main-change-route-guard.yml` validates main updates as
  route-specific Change outcomes, and `.github/workflows/change-route-projection.yml`
  projects route-neutral closeout, branch naming, and hosted no-PR validation
  on push, pull request, and dispatch events.
- Direct-main push validation: `.github/workflows/main-push-safety.yml`,
  `.github/workflows/commit-and-branch-standards.yml`,
  `.github/workflows/alignment-check.yml`, and
  `.github/workflows/harness-self-containment.yml`.
- PR-backed review and publication: `.github/workflows/pr-quality.yml`,
  `.github/workflows/pr-autonomy-policy.yml`,
  `.github/workflows/pr-auto-merge.yml`,
  `.github/workflows/pr-triage.yml`,
  `.github/workflows/pr-clean-state-enforcer.yml`,
  `.github/workflows/pr-stale-close.yml`,
  `.github/workflows/ai-review-gate.yml`, and
  `.github/workflows/codex-pr-review.yml`.
- Templates: `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/PULL_REQUEST_TEMPLATE/kaizen.md`, and
  `.github/PULL_REQUEST_TEMPLATE/orchestration-domain-implementation.md`.

No `.github/**` edits are claimed by this packet until this repo-local proposal
is accepted or otherwise explicitly authorized.
