# Target Architecture

A local branch retirement route inventories current branch state, worktrees,
local and remote refs, upstream configuration, locally knowable PR references,
protected naming/status, and commit uniqueness. If the stale branch has no
unique commits and no unresolved ownership, deletion is authorized after the
worktree is no longer branch-dependent.

If the stale branch is checked out in a dirty worktree, the route first runs a
local-worktree retirement pass: classify residue, preserve or promote required
evidence, discard only route-authorized disposable residue, switch to the
correct surviving branch, and delete the stale branch.
