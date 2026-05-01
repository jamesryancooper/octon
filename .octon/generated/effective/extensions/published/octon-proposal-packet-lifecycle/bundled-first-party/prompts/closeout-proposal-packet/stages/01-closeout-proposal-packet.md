# Closeout Proposal Packet

Verify implementation and follow-up verification are clean, then archive or
promote the proposal using existing workflows. Regenerate the proposal registry
only when safe.

Before staging anything, run a housekeeping pass that reviews tracked,
unstaged, untracked, ignored, generated, and local-output candidates. Exclude
incidental build/output artifacts. Decide explicitly whether newly added prompt
scaffolding, packet support files, generated projections, validation evidence,
and local skill logs belong in the final changeset. Remove only unnecessary
temporary generated artifacts; preserve required generated outputs and required
evidence outputs.

Stage only intended files, commit, push, and open or update the PR in the same
branch/PR lane. For PR, CI, review, merge, branch cleanup, and sync behavior,
defer to
`.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
and the closeout workflow referenced by `.octon/instance/ingress/manifest.yml`;
do not create proposal-specific GitHub policy.

After the PR exists, run the failing-job remediation loop before claiming
closeout: inspect every failing required check, job, and script; identify the
failing contract; make the smallest target-architecture-correct fix; re-run
local checks when reproducible; commit; push; and re-check until required
checks are green or an explicit external blocker is recorded.

Before merge or final closeout, verify that review conversations and author
action items are resolved, the working tree has no unintended tracked or
untracked artifacts, no unwanted prompt scaffolding or local skill logs remain
in the final changeset, and no further hygiene work is required. Do not report
proposal closeout as complete while required checks are red, review
conversations are unresolved, final hygiene is incomplete, the PR is unmerged,
or local/remote branch cleanup and origin sync remain unfinished unless the
verdict is explicitly reported as blocked or deferred.
