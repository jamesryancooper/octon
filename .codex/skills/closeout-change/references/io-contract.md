# Closeout Change I/O Contract

## Inputs

- Change identity and exact include/exclude paths
- optional active route hint
- optional target outcome; omission resolves to `preserved`
- branch/worktree observations
- validation and rollback/discard evidence

## Outputs

- selected route: `branch-no-pr`, `branch-pr`, or `stage-only-escalate`
- target and actual lifecycle outcome
- exact candidate, branch, worktree, and rollback refs
- validation evidence and retained residue
- publication denial reason when landing/publication was requested
- cleanup denial reason when cleanup/ref/worktree mutation was requested
- exact next owning route or missing authority

Outputs must never claim `cleaned`, `synced`, direct-main, hosted no-PR
landing, or autonomous publication. Historical receipt fields may be retained
only as evidence-only compatibility data.
