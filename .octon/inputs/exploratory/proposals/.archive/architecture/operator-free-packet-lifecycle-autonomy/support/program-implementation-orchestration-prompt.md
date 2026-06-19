prompt_id: operator-free-packet-lifecycle-autonomy-program-implementation-orchestration-20260618T220430Z
generated_at: "2026-06-18T22:04:30Z"
generated_by: octon-proposal-lifecycle-generate-program-orchestration-prompt
generator_route_id: generate-program-implementation-orchestration-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
artifact_class: operational-aid
authority: non-authoritative
parent_status_at_generation: accepted
child_receipt_summary_count: 7
child_authority_preserved: yes
program_implementation_orchestration_execution_authorized: no

# Program Implementation Orchestration Prompt

## Purpose

This prompt prepares the later parent program implementation orchestration run
for `operator-free-packet-lifecycle-autonomy`. It is an operational aid only.
It does not execute implementation, does not promote the parent, does not close
out the parent, does not archive, clean, land, publish, delete, clean branches,
or claim `cleaned`, and does not satisfy child-owned evidence.

The next separate governed route may write or refresh only:

- `support/program-implementation-orchestration-run.md`

That run receipt may summarize retained child outcomes, but it must never
replace child manifests, child receipts, child promotion targets, child
validation verdicts, child archive metadata, child closeout state, rollback
handles, or terminal outcomes.

## Mandatory Inputs

Read the current repository state, not conversation summaries:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `resources/child-packet-index.yml`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `RISK-REGISTER.md`
- `validation-plan.md`
- `resources/source-lineage.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Inspect each required child packet as retained child evidence only:

- `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
- `.octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection`
- `.octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation`
- `.octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`

For each child, inspect existing child-owned evidence without recreating it:

- `proposal.yml`
- `support/proposal-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/pre-integration-architecture-review.yml`

Validate each retained-run evidence index declared in
`resources/child-packet-index.yml`. The indexes are retained discovery and
replay aids. They do not replace child-owned packet receipts.

## Child Sequence

Execute the parent orchestration review in the registered dependency order:

1. `blocked-delivery-receipt-semantics`
2. `packet-delivery-wrapper-orchestration-autonomy`
3. `branch-no-pr-closeout-state-machine-autonomy`
4. `generated-freshness-scope-detection`
5. `packet-worktree-partitioning-automation`
6. `terminal-evidence-sink-autonomy`
7. `git-mutation-sandbox-preflight`

No parallel execution is authorized by this prompt. The current route is a
parent evidence reconciliation route over already implemented children, not a
child implementation route.

## Pre-Execution Gates For The Later Route

Before writing `support/program-implementation-orchestration-run.md`, rerun:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --require-implementation-authorization
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Validate every retained child evidence index:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh --index <child-retained-run-evidence-index>
```

If freshness is uncertain or any child-owned source, generated artifact bundle,
retained index, or parent child-registry reference changed, rerun for each
child:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal <child> --run-registry-check
```

## Required Run Receipt Shape

If all gates pass, the later route may write or refresh only
`support/program-implementation-orchestration-run.md` with at least:

```markdown
verdict: pass
implemented_at: <UTC timestamp>
promotion_evidence_count: 7
child_authority_preserved: yes
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
parent_status_observed: accepted
generated_outputs_refreshed: none
blockers: none
```

The receipt must include:

- the seven child packet paths and statuses;
- the seven retained-run evidence indexes validated;
- child-owned review, implementation, conformance, drift/churn, validation,
  strict architecture review, and terminal freshness evidence inspected;
- validator commands and pass/fail summaries;
- generated outputs refreshed, if any, and the canonical generator used;
- a child authority boundary statement;
- an explicit statement that no parent promotion, closeout, archive, cleanup,
  landing, publication, deletion, branch cleanup, or `cleaned` claim occurred.

Use `verdict: blocked` and `child_authority_preserved: no` only if a gate fails
or child authority would need to move into the parent.

## Hard Stops

Stop without writing a passing run receipt if any of these are true:

- parent `proposal.yml#status` is not `accepted`;
- parent review is missing, stale, not accepted, or lacks implementation
  authorization;
- any required child is not `implemented`;
- any retained-run evidence index is missing or invalid;
- child readiness, program structure, parent standard, or registry check fails;
- child evidence is missing, stale, failing, or being replaced by parent text;
- generated outputs would need hand editing;
- the route would require parent promotion, closeout, archive, cleanup,
  landing, publication, deletion, branch cleanup, or a `cleaned` claim;
- the route would mutate child packets or recreate child-owned evidence.

## Generation-Time Evidence

This prompt was generated after these gates passed:

- `validate-retained-run-evidence-index.sh --index <each child index>`:
  7/7 passed with `errors=0`.
- `validate-proposal-review-gate.sh --package <parent> --require-implementation-authorization`:
  `errors=0 warnings=0`.
- `validate-proposal-program-child-readiness.sh --package <parent>`:
  `errors=0 warnings=0`.
- `validate-proposal-program-structure.sh --package <parent>`:
  `errors=0 warnings=0`.
- `validate-proposal-standard.sh --package <parent> --skip-registry-check`:
  `errors=0 warnings=1`.
- `generate-proposal-registry.sh --check`:
  `errors=0`.

No generated outputs were refreshed during prompt generation. Parent status
remained `accepted`. Child packets were not mutated.

## Final Answer Contract For The Later Route

When the separate orchestration-run route is authorized and executed, report:

- parent status before and after;
- `support/program-implementation-orchestration-run.md` path and verdict;
- validators run and results;
- child authority preservation result;
- generated outputs refreshed, if any, and generator used;
- blockers or `none`;
- exact next governed route;
- whether any parent lifecycle mutation beyond the run receipt occurred.
