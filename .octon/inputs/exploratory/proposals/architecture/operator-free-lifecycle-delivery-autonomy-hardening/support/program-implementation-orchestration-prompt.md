# Program Implementation Orchestration Prompt

prompt_id: operator-free-lifecycle-delivery-autonomy-hardening-program-implementation-orchestration-20260620T132900Z
generated_at: 2026-06-20T13:29:00Z
generator: codex-manual-generate-program-implementation-orchestration-prompt-route
parent_program: .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening
parent_review_ref: .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening/support/proposal-review.md
child_registry_ref: .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening/resources/child-packet-index.yml
child_authority_preserved: yes

## Execution Brief

Run the implementation orchestration for the parent proposal program from the
current live repository state. Keep the parent as coordination and aggregate
evidence only. Implement each child packet through its own manifest, promotion
targets, validators, acceptance criteria, and child-owned receipts.

Before durable edits, verify:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening`

Stop if either gate fails, if a child packet becomes stale, or if a required
change falls outside the relevant child promotion targets.

## Child Implementation Order

Respect the declared dependency gates and sequence:

1. `complete-program-blocker-vector-planner-output`
2. `lifecycle-validator-runtime-resolver`
3. `proposal-program-execution-mode-normalization`
4. `normalized-child-terminal-evidence-summary`
5. `completed-plan-nonblocking-diagnostics`
6. `targeted-proposal-freshness-checks`
7. `batched-review-and-architecture-digest-refresh`
8. `autonomous-proposal-program-recovery-envelope`
9. `delivery-retained-evidence-index`
10. `proposal-program-delivery-postmortem-evaluation-profile`
11. `branch-no-pr-delivery-receipt-builder`
12. `branch-no-pr-bounded-authorization-envelope`

Parallel work is allowed only when dependencies and write scopes do not
conflict. The parent may coordinate handoffs, but one child packet must not
broaden itself to cover another child unless the parent sequence explicitly
requires a coordinated changeset.

## Child Evidence Requirements

For each implemented child, produce child-local evidence before claiming child
completion:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- validation command output for the child validation plan
- child closeout evidence required by the proposal-packet lifecycle

The parent may summarize these artifacts later, but parent summaries never
satisfy child manifests, child receipts, child validation verdicts, child
promotion evidence, child closeout authorization, child archive metadata, or
child lifecycle outcomes.

## Program Run Receipt

After the orchestration run completes, write parent-local
`support/program-implementation-orchestration-run.md` with at least:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`
- `child_authority_preserved`

Use `verdict: pass` and `child_authority_preserved: yes` only when child
authority was preserved, child evidence exists for every implemented child, and
all required child validators pass. The program run receipt may summarize child
outcomes and evidence references, but it must not replace child-owned receipts.

## Durable Scope

Durable implementation must stay within each child packet's declared promotion
targets. Generated outputs must be refreshed through canonical generators.
Branch, cleanup, publication, archive, delivery-wrapper entry, and `cleaned`
claims remain governed by their later lifecycle routes and explicit evidence
gates.

## Terminal Criteria

The program implementation orchestration is complete only when:

- all required child packets have completed their child-owned implementation
  and validation evidence;
- child conformance and drift/churn reviews pass;
- parent `support/program-implementation-orchestration-run.md` is present with
  the required fields;
- no child-owned authority has been replaced by parent evidence; and
- the proposal-program lifecycle controller can legally replan to the next
  route.
