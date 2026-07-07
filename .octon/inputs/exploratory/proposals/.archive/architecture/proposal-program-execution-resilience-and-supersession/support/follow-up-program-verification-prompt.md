# Follow-Up Program Verification Prompt

schema_version: program-verification-prompt-v1
verdict: pass
generated_at: 2026-07-07T14:40:00Z
generator: octon-proposal-lifecycle-generate-program-verification-prompt
parent_program: .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession
verification_mode: child-owned-terminal-reconciliation
child_authority_preserved: yes
parent_summary_not_child_evidence: true

## Verification Scope

Verify the implemented parent program as a coordinator of four already-terminal child packets. Do not reimplement child behavior. Do not use parent summaries, generated proposal projections, retained run summaries, chat context, or external workflow status as substitutes for child-owned manifests, receipts, validators, or archive metadata.

The parent verification must cover:

- sequence and dependency integrity from `resources/child-packet-index.yml`;
- all four required child packets reaching terminal archived implemented state;
- parent-local `support/program-implementation-orchestration-run.md` preserving child authority;
- lifecycle residue handling as evidence-only unless validated closeout-worktree returns explicitly authorize a non-mutating handoff;
- parent conformance against program structure, review authorization, child readiness, architecture proposal, readiness projection, and terminal freshness gates.

## Required Receipts

Write these parent-local receipts after verification:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Each receipt must include:

- `verdict`
- `unresolved_items_count`
- `child_receipt_summary_count`
- `child_authority_preserved`

Use `verdict: pass` and `child_authority_preserved: yes` only when aggregate parent evidence is clean and child manifests, child receipts, child promotion targets, child validation verdicts, child terminal closeout receipts, and child archive metadata remain child-owned.

## Validation Floor

Run or cite current passing evidence for:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <parent>`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <parent>`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <parent> --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <parent>`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package <parent>`
- targeted parent `validate-proposal-lifecycle-terminal-freshness.sh` after proposal artifact indexes are refreshed

If any validator fails, record stable findings with owner scope (`parent`, child id, child group, or cross-packet dependency), severity, affected paths, evidence, expected behavior, correction scope, acceptance criteria, and deferral eligibility.

This prompt does not authorize deletion, cleanup, archive relocation, Git mutation, publication edits, `cleaned` claims, durable promotion, or parent substitution for child-owned evidence.
