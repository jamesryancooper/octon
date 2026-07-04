# Acceptance Criteria

- Final reports include rows for delivered branch, delivery branch, retained
  branches, retained worktrees, retained evidence, local-private evidence,
  generated diagnostics, deleted residue, excluded residue, and manual-review
  residue.
- Every final cleanup section includes at least the four required rows:
  delivered branch, retained branches, retained worktrees, and retained
  evidence.
- Each row is backed by current evidence or explicitly says `none`.
- Branch cleanup claims fail validation when a matching retained local branch
  exists but is not named and dispositioned.
- `cleaned`, `git_clean_terminal`, archive authorization, and generated
  freshness claims require current route-owned verification.
