prompt_id: run-program-clean-delivery-postmortem-hardening-program-implementation-orchestration-20260703T0836Z
generated_at: "2026-07-03T08:31:22Z"
generated_by: octon-proposal-lifecycle-generate-program-orchestration-prompt
generator_route_id: generate-program-implementation-orchestration-prompt
generation_run_id: lifecycle-proposal-program-postmortem-hardening-20260703T0836Z
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
artifact_class: operational-aid
authority: non-authoritative
parent_status_at_generation: accepted
child_authority_preserved: yes
program_implementation_orchestration_execution_authorized: gated-rerun-required

# Program Implementation Orchestration Prompt

## Purpose

This prompt prepares the later parent program implementation orchestration run
for `run-program-clean-delivery-postmortem-hardening`. It is an operational
aid only. It does not execute implementation, promote the parent, close out the
parent, archive, clean, land, publish, delete residue, delete branches, refresh
generated outputs, or claim `cleaned`.

The later governed route may write or refresh only:

- `support/program-implementation-orchestration-run.md`

That parent-local run receipt may summarize child outcomes by reference, but it
must never replace child manifests, child receipts, child promotion targets,
child validation verdicts, child archive metadata, Change receipts, delivery
receipts, cleanup authorization, branch state, rollback handles, or terminal
proof.

## Mandatory Inputs

Read the current repository state, not conversation summaries:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `architecture/implementation-plan.md`
- `architecture/target-architecture.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `navigation/source-of-truth-map.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/pre-integration-architecture-review.yml`

Inspect each required child packet as child-owned evidence. The parent
registry records the original sibling paths; at generation time each child
resolved to the current archived implemented packet path through the child
readiness validator.

For each child, inspect existing child-owned evidence without recreating it:

- `proposal.yml`
- `support/proposal-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/pre-integration-architecture-review.yml`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

If any child is no longer archived implemented or implemented when the later
route runs, stop the parent orchestration route and return to the child-owned
lifecycle route for that packet.

## Child Sequence

Run the parent orchestration review in the registered sequential order. No
parallel child execution is authorized by this prompt.

1. `run-program-clean-delivery-architecture-review-freshness`
   - Original registry path:
     `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness`
   - Current generation-time evidence path:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture-review-freshness`
   - Scope: stale architecture-review receipt recurrence and review-gate
     freshness.
   - Generation-time archive promotion evidence count: 6.

2. `run-program-clean-delivery-delivery-receipt-completion`
   - Original registry path:
     `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion`
   - Current generation-time evidence path:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-delivery-receipt-completion`
   - Scope: concrete Proposal Program Delivery receipt and evidence-index
     requirements before clean-delivery claims.
   - Generation-time archive promotion evidence count: 6.

3. `run-program-clean-delivery-change-closeout-reconciliation`
   - Original registry path:
     `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation`
   - Current generation-time evidence path:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-change-closeout-reconciliation`
   - Scope: hosted landing, local main sync, source branch cleanup, and
     terminal proof after manual or route-owned Git completion.
   - Generation-time archive promotion evidence count: 3.

4. `run-program-clean-delivery-cleanup-disposition`
   - Original registry path:
     `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition`
   - Current generation-time evidence path:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-cleanup-disposition`
   - Scope: classifier detection, protected residue, preserved residue,
     deletion authorization, and final terminal cleanliness.
   - Generation-time archive promotion evidence count: 3.

5. `run-program-clean-delivery-validator-hardening`
   - Original registry path:
     `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening`
   - Current generation-time evidence path:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validator-hardening`
   - Scope: aggregate clean-delivery validators, disclosure-tier validation,
     and negative controls.
   - Generation-time archive promotion evidence count: 3.

6. `run-program-clean-delivery-test-hermeticity`
   - Original registry path:
     `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity`
   - Current generation-time evidence path:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-test-hermeticity`
   - Scope: hermetic proposal hygiene tests that do not dirty tracked
     generated read models.
   - Generation-time archive promotion evidence count: 4.

## Pre-Execution Gates For The Later Route

Before writing `support/program-implementation-orchestration-run.md`, rerun
from the repository root:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
```

Stop if any gate fails, any accepted review digest is stale, any child
readiness check fails, any predecessor gate is unmet, or any packet has
blockers, unresolved questions, clarification requirements, or authority
ambiguity.

The generation-time child readiness run passed with `errors=0 warnings=6`.
Each warning reported that an archived child had no registry
`evidence_index_refs`. The later route must retain those warnings as
readiness-context warnings and must not convert them into delivery evidence,
registry evidence-index proof, or a `cleaned` claim.

## Required Run Receipt Shape

If all gates pass, write or refresh only
`support/program-implementation-orchestration-run.md` with at least:

```markdown
schema_version: program-implementation-orchestration-run-v1
verdict: pass
implemented_at: <UTC timestamp>
promotion_evidence_count: <sum of current child archive promotion_evidence entries; generation-time expected 25>
child_authority_preserved: yes
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
parent_status_observed: accepted
required_child_count: 6
terminal_child_count: 6
parent_summary_not_child_evidence: true
child_receipts_remain_child_owned: true
generated_outputs_refreshed: none
blockers: none
```

The receipt must include:

- the six child ids, original registry paths, current evidence paths, and
  current statuses;
- the child-owned review, implementation, conformance, drift/churn,
  validation, strict architecture review, closeout, terminal closeout, archive
  metadata, and promotion evidence inspected;
- validator commands and pass/fail summaries;
- the six generation-time child-readiness `evidence_index_refs` warnings if
  they still apply;
- generated outputs refreshed, if any, and the canonical generator used;
- a child authority boundary statement;
- an explicit statement that no parent promotion, closeout, archive, cleanup,
  landing, publication, deletion, branch cleanup, or `cleaned` claim occurred.

Use `verdict: blocked` and `child_authority_preserved: no` if a gate fails, if
child-owned evidence is missing or stale, or if child authority would need to
move into the parent.

## Delivery Boundary

This prompt does not authorize `/proposal-program-delivery` and does not claim
clean delivery. Proposal Program Delivery may claim `cleaned` only through its
own governed route and only when concrete aggregate delivery receipt,
evidence-index validation, terminal proof, Change closeout alignment, branch
cleanup authorization, final sync proof, worktree hygiene, cleanup
authorization, and no-open-blocker evidence all pass.

If the later route discovers that aggregate delivery has not been retained, it
must report the highest evidence-backed parent orchestration outcome and name
the next owning lifecycle instead of filling the gap with parent text.

## Hard Stops

Stop without writing a passing run receipt if any of these are true:

- parent `proposal.yml#status` is not `accepted`;
- parent review is missing, stale, not accepted, or lacks implementation
  authorization;
- child-readiness, program structure, parent standard, or architecture
  validation fails;
- any required child is missing from the active path and the archive resolver
  cannot confirm the original path;
- any required child is not implemented or archived implemented;
- child evidence is missing, stale, failing, or being replaced by parent text;
- generated outputs would need hand editing;
- the route would require parent promotion, closeout, archive, cleanup,
  landing, publication, deletion, branch cleanup, or a `cleaned` claim;
- the route would mutate child packets or recreate child-owned evidence.

## Generation-Time Evidence

This prompt was generated after these gates passed:

- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --require-implementation-authorization`:
  `errors=0 warnings=0`.
- `validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening`:
  `errors=0 warnings=6`.

No generated outputs were refreshed during prompt generation. Child packets
were not mutated. Parent status remained `accepted`.

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
