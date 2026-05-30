# Follow-Up Program Verification Prompt

verification_prompt_id: "evidence-disclosure-tier-contract-program-final-verification-20260529T234212Z"
created_at: 2026-05-29T23:42:12Z
target: ".octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contract-program"
child_authority_preserved: yes

## Verification Scope

Verify the parent program aggregate state without replacing child-owned
receipts. Confirm that each registered child packet keeps passing structure,
architecture, review, implementation-readiness, implementation-conformance, and
post-implementation drift/churn gates.

## Required Aggregate Receipts

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Both receipts must include `verdict`, `unresolved_items_count`,
`child_receipt_summary_count`, and `child_authority_preserved`.

## Closeout Refusal Criteria

Refuse successful closeout or archive authorization when worktree hygiene is
blocked, route-resolution validation is stale or timed out, child receipts are
missing or failing, or parent aggregate receipts attempt to satisfy child-owned
evidence.
