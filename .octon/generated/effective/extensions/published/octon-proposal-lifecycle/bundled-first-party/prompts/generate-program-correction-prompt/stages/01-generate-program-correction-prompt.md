# Generate Program Correction Prompt

Create a bounded correction prompt for one program finding. Preserve finding
ownership as parent, child, child-group, or cross-packet dependency. Do not let
parent correction override child `proposal.yml`, subtype manifests, acceptance
criteria, validation verdicts, or promotion targets.

If the correction changes aggregate verification posture, refresh only the
parent-local `support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` receipts. Do not
rewrite child receipts, child promotion targets, child validation verdicts,
child archive metadata, or child terminal outcomes from the parent program.
