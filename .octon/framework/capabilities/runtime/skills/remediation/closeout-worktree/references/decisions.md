---
title: Closeout Worktree Decisions
---

# Decisions

Use the wrapper only when the worktree may contain multiple candidate Changes
or when the operator asks for worktree-level closeout.

Candidate grouping is valid only when all of these are true:

- the candidate has a coherent operator intent or branch/receipt identity;
- the candidate's paths can be isolated without overwriting or deleting
  ambiguous work;
- route and target lifecycle outcome can be resolved or honestly blocked; a
  generic worktree closeout request defaults each candidate target to `cleaned`
  unless the operator explicitly requested a narrower target;
- validation and rollback posture can be stated for that candidate;
- unrelated residue can be retained, deferred, or escalated without being
  staged into the candidate.

Choose `closeout-change` directly instead of this wrapper when inventory shows
one coherent Change and no unrelated residue.

Stop or ask the operator when:

- two candidate Changes touch the same path in incompatible ways;
- staged and unstaged changes cannot be safely separated;
- untracked or ignored files may be user-owned;
- generated, evidence, host-projection, release, or input-surface residue has
  unclear authority or freshness;
- a candidate needs destructive cleanup before it can be routed;
- the operator's requested target outcome applies to the whole dirty worktree
  rather than one candidate Change.

Do not stop only because multiple coherent candidates exist. Multiple
candidates are the wrapper's normal operating condition: select one safely
separable candidate, route it through singular `closeout-change`, re-inventory,
and then decide the next candidate.

After a delegated closeout, if the generic worktree target is `cleaned` and the
only new non-ignored residue is unambiguous closeout evidence under retained
evidence roots, route that evidence as the next singular `closeout-change`
candidate. If fresh repo-local evidence residue remains after the final
delegated candidate, report
`worktree_terminal_state: disposition_complete_with_retained_residue` rather
than `git_clean_terminal`.

When candidate boundaries are unambiguous, do not ask the operator to approve
the partition before delegation. Ask only when ownership, overlap,
destructive action, target outcome, route, validation, rollback, or cleanup
authority is genuinely unclear.

Eligible local Octon run/artifact residue is not a Change candidate and is not
wrapper-owned cleanup. Classify it, record repo-hygiene routing evidence, and
delegate cleanup to `repo-hygiene-cleanup` when the helper scope and receipt
route can prove deletion safety. Generated run-health projections route to the
run-health generator. Stale detached Git worktrees route through Git worktree
cleanup safety proof. Anything outside those routes is retained or blocked.

If the operator uses the phrase "closeout changes", reinterpret it as
`Closeout Worktree` only for routing convenience. Do not introduce a canonical
`Closeout Changes` model.
