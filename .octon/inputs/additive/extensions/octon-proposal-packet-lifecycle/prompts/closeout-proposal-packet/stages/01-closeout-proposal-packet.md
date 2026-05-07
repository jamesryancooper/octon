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

Stage only intended files when the selected route requires staging. Commit,
push, and open or update a PR only when the selected implementation route uses a
branch/PR lane. For PR, CI, review, merge, branch cleanup, and sync behavior,
defer to
`.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
and the closeout workflow referenced by `.octon/instance/ingress/manifest.yml`;
do not create proposal-specific GitHub policy.

When PR or CI checks exist, run the failing-job remediation loop before claiming
closeout: inspect every failing required check, job, and script; identify the
failing contract; make the smallest target-architecture-correct fix; re-run
local checks when reproducible; commit and push when the route uses a branch
lane; and re-check until required checks are green or an explicit external
blocker is recorded.

Before merge or final closeout, verify that review conversations and author
action items are resolved, the working tree has no unintended tracked or
untracked artifacts, no unwanted prompt scaffolding or local skill logs remain
in the final changeset, and no further hygiene work is required. Do not report
proposal closeout as complete while required packet receipts fail, required
checks are red, route-required review conversations are unresolved, final
hygiene is incomplete, or route-required PR/merge/branch cleanup/origin sync
gates remain unfinished unless the verdict is explicitly reported as a blocked
or deferred outcome.

When closeout succeeds, write or refresh `support/proposal-closeout.md` with at
least `verdict`, `closed_at`, and `archive_authorized`. Use `verdict: pass` and
`archive_authorized: yes` only when the packet is ready for the separate
`archive-proposal` lifecycle route. Do not archive the packet directly from
this route.
