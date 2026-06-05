# Follow-Up Program Verification Prompt

prompt_id: lifecycle-postmortem-evaluation-program-follow-up-verification-20260605T122240Z
generated_at: 2026-06-05T12:22:40Z
verdict: ready-for-verification-loop

## Verification Scope

Verify the implemented lifecycle-postmortem proposal program across parent
coordination evidence and all required child packets:

- `lifecycle-postmortem-meta-workflow`
- `lifecycle-postmortem-evaluator-template`
- `lifecycle-postmortem-validator`

## Required Receipts

The verification loop must produce:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Both receipts must use `verdict: pass`, `unresolved_items_count: 0`,
`child_receipt_summary_count: 3`, and `child_authority_preserved: yes` only
when child-owned implementation-run, conformance, and drift/churn receipts are
present and passing.

## Verification Checks

- Parent and child proposal manifests are structurally valid.
- All required child packets are sibling-owned and implemented.
- Child implementation-run, conformance, and drift/churn receipts are present.
- Durable promotion targets exist and remain outside proposal-local inputs.
- The postmortem workflow remains read-only except for retained evidence writes.
- Evaluator and validator outputs remain evidence and do not authorize changes.
- Invariant compliance and invariant validity/evolution review are covered.
- Any scope correction is recorded as proposal evidence and does not replace
  child receipts.

## Correction Rule

Run targeted correction only for concrete verification findings. Do not rewrite
child receipts from the parent and do not treat parent aggregate evidence as a
child validation verdict.
