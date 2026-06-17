# Implementation Run

implementation_prompt_id: octon-change-first-github-projection-policy-implementation-prompt-20260617T171851Z
route_id: run-packet-implementation
packet: `.octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy`
implemented_at: 2026-06-17T18:06:50Z
evidence_dir: `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T174935Z`
verdict: pass
unresolved_items_count: 0

## Scope

This implementation applied the accepted packet only to approved repo-local
`.github/**` projection targets and packet-local support receipts. It did not
change `proposal.yml#status`, durable Change-first authority contracts,
generated effective outputs, or out-of-scope support-target policy surfaces.

## Profile

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- transitional exception: none

## Durable Edits

- Main route guard: converted route logging to projection terminology and made
  associated-PR and hosted no-PR provider lookups best-effort so direct-main and
  branch-no-pr receipt evidence can still be evaluated without PR metadata.
- AI review gate: replaced GitHub-side approval materialization with
  branch-pr projection evidence artifacts.
- PR auto-merge: replaced GitHub-minted merge approval artifacts with
  branch-pr merge-readiness projection evidence and a required repo-local
  canonical Change authorization JSON before the protected merge boundary.
- PR clean-state enforcer: changed closed head-ref cleanup from deletion to
  cleanup-candidate reporting that cites canonical cleanup receipts.
- PR stale-draft workflow: changed stale draft handling from closure to
  abandonment-review projection labels/comments.
- PR templates: added Change receipt projection sections and removed package
  wording that implied PR bodies replace durable Change receipts.
- Harness self-containment workflow: removed archived exploratory proposal path
  triggers from the live GitHub projection target.

## Subagent Findings Used

- Main/direct-main route inspection found PR API and hosted provider lookups
  could block route-neutral evidence checks; the main guard now continues to
  receipt validation when those lookups fail.
- PR workflow/template inspection found AI gate, auto-merge, stale-close, and
  clean-state flows could imply GitHub-side authority; those flows now emit
  projection evidence or candidate reports.
- Validator/evidence inspection identified exact receipt section requirements,
  proposal-path backreference risks, and stale PR-first naming checks; the
  receipts and `.github/**` scans follow those constraints.

Subagents supplied read-only inspection only. The primary implementer made all
edits, wrote all receipts, ran validators, and owns this route result.

## Rollback

Rollback is a single revert of the `.github/**` target edits from this route
and the packet-local support receipts added by this route, followed by rerunning
the proposal lifecycle, GitHub projection, Change-first, and workflow YAML
validators listed in `support/validation.md`.

## Closeout Posture

This receipt records implementation work only. It makes no archive claim and no
final lifecycle closeout claim.
