# Generate Closeout Prompt

Generate a closeout prompt grounded in the implemented packet, current repo
state, current validation status, and PR/check/review state when applicable.
The prompt must require safe registry regeneration, intentional staging, green
required checks, resolved review conversations, retained evidence, and branch
sync before merge or final closeout.

The generated prompt must bind PR, CI, review, merge, branch cleanup, and sync
behavior to the repository Git/worktree autonomy contract instead of restating
or replacing that policy. It must explicitly require housekeeping before
staging, including review of incidental build/output artifacts, generated
temporary artifacts, prompt scaffolding, required generated outputs, required
evidence outputs, and local skill logs.

When any required check is red, the prompt must require a remediation loop:
inspect every failing check, job, and script; identify the failing contract;
make the smallest target-architecture-correct fix; validate locally when
reproducible; commit; push; and re-check. It must prohibit claiming closeout as
complete while required checks are red, review conversations are unresolved,
final hygiene is incomplete, the PR is unmerged, or post-merge branch cleanup
and origin sync remain unfinished unless the verdict is explicitly blocked or
deferred.
