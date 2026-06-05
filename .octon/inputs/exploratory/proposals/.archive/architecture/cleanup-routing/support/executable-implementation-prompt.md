# Executable Implementation Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-packet-implementation-prompt
proposal_packet_path: .octon/inputs/exploratory/proposals/architecture/cleanup-routing
verdict: ready-for-execution

This prompt is operational guidance only. It is not authority, runtime truth,
generated-effective authority, cleanup authorization, or implementation proof.

## Gate Receipt

Run before implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/cleanup-routing --require-implementation-authorization
```

Expected result: `errors=0 warnings=0`.

## Objective

Route local run-state residue through repo-hygiene-cleanup with receipt-backed authorization and prevent ad hoc deletion by lifecycle or closeout wrappers.

## Promotion Targets

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/cleanup-lifecycle-residue/`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstreams

1. Define residue classes that lifecycle and closeout wrappers may classify.
2. Route eligible cleanup to repo-hygiene-cleanup with fresh cleanup authority.
3. Preserve referenced evidence, active control state, manual-review residue, and local-private residue.
4. Add wrapper validation and cleanup helper tests proving no ad hoc deletion path remains.

## Validation And Evidence

- Run cleanup helper positive and negative tests.
- Run closeout-worktree wrapper validation.
- Run proposal standard validation for this packet.
- Retain cleanup authorization evidence only through repo-hygiene-cleanup routes when cleanup is actually performed.
- Create or update `support/implementation-run.md` with `verdict`, `implemented_at`, and `promotion_evidence_count`.
- Create or update `support/implementation-conformance-review.md`, then run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/cleanup-routing`.
- Create or update `support/post-implementation-drift-churn-review.md`, then run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/cleanup-routing`.

## Rollback

Rollback is removal or reversion of cleanup routing changes in the declared targets, followed by cleanup helper and wrapper validation.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. Refuse closeout or archive claims while implementation-run, conformance, or drift/churn receipts are missing, failing, unresolved, or blocked.
