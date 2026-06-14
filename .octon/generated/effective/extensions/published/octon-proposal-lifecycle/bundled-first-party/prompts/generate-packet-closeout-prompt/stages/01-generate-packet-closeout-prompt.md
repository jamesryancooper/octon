# Generate Packet Closeout Prompt

Generate a closeout prompt grounded in the implemented packet, current repo
state, current validation status, and PR/check/review state when applicable.
The prompt must require safe registry regeneration, intentional staging, green
route-required checks, resolved route-required review conversations, retained
evidence, final hygiene, and route-required branch sync before merge or final
closeout.

The generated prompt must bind PR, CI, review, merge, branch cleanup, and sync
behavior to the repository Git/worktree autonomy contract instead of restating
or replacing that policy. Those gates apply only when the selected
implementation route uses a PR or branch lane. It must explicitly require
housekeeping before staging or direct closeout, including review of incidental
build/output artifacts, generated temporary artifacts, prompt scaffolding,
required generated outputs, required evidence outputs, and local skill logs.

For implemented closeout, the generated prompt must require passing
`support/implementation-conformance-review.md`,
`support/post-implementation-drift-churn-review.md`,
`validate-proposal-implementation-conformance.sh --package <proposal_path>`,
and `validate-proposal-post-implementation-drift.sh --package <proposal_path>`.
It must refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, failing, unresolved, or blocked.

When the packet declares governed mechanism integration gates, the generated
prompt must also require
`support/governed-mechanism-integration-evaluation.yml`,
`validate-governed-mechanism-integration-receipt.sh --receipt <proposal_path>/support/governed-mechanism-integration-evaluation.yml --package <proposal_path>`,
fresh generated publication validation, and terminal freshness validation
before archive readiness. The prompt must keep current-state architecture
review and lifecycle postmortem evidence evidence-only.

When any required check is red, the prompt must require a remediation loop:
inspect every failing check, job, and script; identify the failing contract;
make the smallest target-architecture-correct fix; validate locally when
reproducible; commit; push; and re-check. It must prohibit claiming closeout as
complete while required checks are red, review conversations are unresolved,
final hygiene is incomplete, or route-required PR/merge/branch cleanup/origin
sync gates remain unfinished unless the verdict is explicitly reported as a
blocked or deferred outcome.
