# Packet Closeout

## Target Kind

`generate-closeout-prompt` and `closeout-proposal-packet`

## Expected Behavior

The route covers proposal archival, registry regeneration when safe,
housekeeping, intended staging, commit, PR, CI, review resolution, merge,
branch cleanup, sync, and evidence.

The route must delegate repository-wide PR, CI, review, merge, branch cleanup,
and sync behavior to the Git/worktree autonomy contract. It must not claim
closeout complete while required checks are red, review conversations or author
action items are unresolved, final hygiene is incomplete, the PR is unmerged, or
post-merge local/remote branch cleanup and origin sync remain unfinished unless
the result is explicitly blocked or deferred.

Red required checks trigger remediation, not waiting: inspect every failing
check, job, and script; fix according to Octon's target architecture and current
repo state; validate locally when reproducible; commit; push; and re-check.
