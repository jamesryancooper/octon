# Packet Closeout Prompt

route_id: generate-packet-closeout-prompt
packet: `.octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy`
generated_at: 2026-06-17T19:10:03Z

## Required Gates

- `proposal.yml#status` is `implemented`.
- `support/implementation-grade-completeness-review.md` records `verdict:
  pass`, `unresolved_questions_count: 0`, and `clarification_required: no`.
- `support/proposal-review.md` preserves accepted review evidence and has a
  current implemented-state packet digest.
- `support/verification-report.md` records `terminal_status: clean`,
  `verdict: pass`, and `unresolved_items_count: 0`.
- `support/implementation-conformance-review.md` passes its validator after
  promotion.
- `support/post-implementation-drift-churn-review.md` passes its validator
  after promotion.
- Generated proposal registry and proposal artifact index are refreshed by
  canonical generators.
- `validate-proposal-lifecycle-terminal-freshness.sh --run-registry-check`
  passes after the final support receipt mutation.
- Worktree hygiene classifier reports zero `foreign_or_ambiguous` paths before
  archive authorization.

## Current Evidence

- Verification summary:
  `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T190000Z-followon/final-verification-summary.tsv`
- Promote-proposal bundle:
  `.octon/state/evidence/runs/workflows/20260617T191003Z-promote-proposal-octon-change-first-github-projection-policy/bundle.yml`
- Final terminal freshness:
  `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T190000Z-followon/final-post-promote-validate-proposal-lifecycle-terminal-freshness.log`
- Final hygiene classifier:
  `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T190000Z-followon/final-closeout-worktree-hygiene-after-interaction.yml`
- Lifecycle interaction request:
  `support/lifecycle-interaction-request-closeout-change.json`

## Current Blocker

Closeout must remain blocked because worktree hygiene reports five
`foreign_or_ambiguous` paths. The classifier requires `closeout-change` or
operator scope resolution before this packet can authorize archive.

The `closeout-packet` route must write `support/proposal-closeout.md` with
`verdict: blocked`, `archive_authorized: no`, and the current hygiene evidence.
It must not archive, stage, commit, push, delete, reset, or clean worktree
paths.
