# Closeout Packet

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

Before claiming archive readiness, run the read-only worktree hygiene
classifier and retain its output as closeout evidence. For ordinary packet
closeout, classify the target packet with `--lifecycle proposal-packet`; pass
the packet lifecycle run id when available. For a program-child closeout route,
the route prompt includes `Program Context` with `program_run_id`; in that case
classify hygiene with `--lifecycle proposal-program --run-id <program_run_id>`
so sibling child evidence and parent program lifecycle artifacts from the same
retained program run are not treated as foreign worktree residue. Do not use
the child route run id as the classifier run id for program-child hygiene
classification. This hygiene scope does not transfer child authority: the
closeout receipt, archive authorization, promotion evidence, validation
verdicts, and terminal lifecycle outcome remain child-owned.

For a program-child closeout route, bound inputs may include
`lifecycle_interaction_return_refs`,
`program_child_closeout_worktree_report_ref`,
`program_child_worktree_hygiene_classifier_ref`, and
`program_child_worktree_hygiene_foreign_fingerprint`. When present, validate
each bound route-scoped return receipt with
`validate-lifecycle-interaction-receipts.sh --return <return-ref>`. Do not
require unrelated historical return receipts from the same program run. Validate
the closeout-worktree report with
`validate-closeout-worktree-wrapper.sh --report <report-ref>`. The report must
cite the bound classifier evidence, match the bound foreign fingerprint, use a
non-mutating preserve/exclude disposition for this child route, and preserve
child-owned closeout authority. If those checks pass, the cited
foreign-or-ambiguous paths are preserved and excluded from child closeout
blocking only. Do not clean, stage, commit, archive, publish, delete, reset,
claim `cleaned`, or substitute parent/program evidence for child receipts. If
validation fails, evidence is stale, or any other child-owned gate fails, write
a blocked child closeout receipt.

For implemented packet closeout, verify preserved review evidence with the
baseline review gate:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <proposal_path>
```

Do not require the pre-implementation authorization flag during closeout for a
packet that is already `status: implemented`; that strict gate remains required
before implementation prompt generation, implementation execution, and
promotion. Implemented closeout may rely on the baseline gate when it confirms
the packet preserves accepted review evidence, and closeout must still fail
closed if implementation-run, conformance, drift/churn, validation, promotion
evidence, or hygiene gates fail.

If the packet declares governed mechanism integration gates, also require
`support/governed-mechanism-integration-evaluation.yml` and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh --receipt <proposal_path>/support/governed-mechanism-integration-evaluation.yml --package <proposal_path>
```

Archive-ready claims must also retain terminal freshness evidence. Current-state
mechanism architecture review and lifecycle postmortem evidence remain
evidence-only.

If the correctly scoped classifier still reports foreign or ambiguous paths,
write or refresh `support/proposal-closeout.md` with `verdict: blocked`,
`archive_authorized: no`, the hygiene counts and evidence path, and
`next_route_condition: closeout-change or operator scope resolution`. Do not
stage, commit, push, delete, reset, archive, or otherwise clean worktree paths
from this route.

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
least `verdict`, `closed_at`, and `archive_authorized`. When
`archive_authorized: yes`, also record explicit workflow inputs
`archive_disposition` and `promotion_evidence`. For implemented packets,
`archive_disposition` must be `implemented` and `promotion_evidence` must name
durable repo-relative evidence paths outside the proposal packet. For
superseded packets, `archive_disposition` must be `superseded` and
`promotion_evidence` must name repo-relative successor packet/program evidence
or retained successor closeout evidence outside the superseded packet. Do not
list validation commands in `promotion_evidence`; record them in the
validation summary instead. Use `verdict: pass` and
`archive_authorized: yes` only when the packet is ready for the separate
`archive-proposal` lifecycle route. Do not archive the packet directly from
this route.
