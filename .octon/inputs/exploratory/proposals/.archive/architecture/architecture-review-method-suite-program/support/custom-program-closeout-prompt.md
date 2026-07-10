prompt_id: architecture-review-method-suite-program-closeout-20260710T211500Z
generated_at: 2026-07-10T21:15:00Z
generated_by: octon-proposal-lifecycle-generate-program-closeout-prompt
generator_route_id: generate-program-closeout-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program
artifact_class: operational-aid
authority: non-authoritative
run_id: 20260709-arms-program-clean-delivery-04
parent_status_at_generation: implemented
child_receipt_summary_count: 30
child_authority_preserved: yes
closeout_execution_authorized: yes

# Custom Program Closeout Prompt

Close the Architecture Review Method Suite program through the canonical
`closeout-program` route for run `20260709-arms-program-clean-delivery-04`.

## Required Gates

- Preserve the declared child closeout order and verify all six required
  children are archived with complete child-owned implementation, conformance,
  drift, closeout, terminal, validation, promotion, and archive evidence.
- Record the absent optional `architecture-review-command-facades` child as the
  allowed no-action disposition with its documented re-trigger condition.
- Require both parent aggregate verification receipts to record `verdict: pass`,
  `unresolved_items_count: 0`, and `child_authority_preserved: yes`.
- Require the program readiness projection and aggregate terminal blocker
  evidence to show no blocked required child.
- Verify the generated proposal registry is synchronized through the canonical
  generator and that durable promotion targets contain no active parent or
  child proposal-path dependency.
- Use the validated default parent closeout-worktree return only to clear the
  parent hygiene blocker. It must remain bound to the cleanup receipt,
  classifier digest and foreign fingerprint, exact retained path set, and the
  non-mutating disposition
  `preserve-and-exclude-from-lifecycle-closeout-blocking`.

## Required Parent Receipt

Write `support/proposal-closeout.md` with at least:

- `verdict`
- `closed_at`
- `archive_authorized`
- `child_authority_preserved`
- `selected_git_route`
- `worktree_hygiene_verdict`
- `worktree_hygiene_blocker_class`
- `worktree_hygiene_owned_path_count`
- `worktree_hygiene_in_scope_path_count`
- `worktree_hygiene_foreign_path_count`
- `worktree_hygiene_foreign_fingerprint`
- `worktree_hygiene_evidence`
- `cleanup_summary`
- `next_route_condition`

Use `verdict: pass`, `archive_authorized: yes`, and
`child_authority_preserved: yes` only if every gate above passes. Otherwise fail
closed with `verdict: blocked`, `archive_authorized: no`,
`selected_git_route: stage-only-escalate`, classifier-backed blocker/count
fields, and a nonterminal next route.

## Authority Boundary

Parent evidence may summarize but never replace child-owned authority. Delegate
PR, CI, review, merge, branch cleanup, and synchronization to the shared
Git/worktree closeout contract. The parent handoff grants no deletion, cleanup,
archive, Git mutation, publication, promotion, or terminal `cleaned` authority.
Program delivery, Change closeout, archival, cleanup, final sync, and terminal
proof remain later canonical routes.
