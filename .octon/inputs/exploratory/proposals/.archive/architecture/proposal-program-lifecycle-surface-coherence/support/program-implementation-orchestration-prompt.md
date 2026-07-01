# Program Implementation Orchestration Prompt

program: `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence`
route: `Run Program to Clean Delivery`
canonical command: `/proposal-program-delivery target=.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence outcome=cleaned`

## Goal

Run the accepted proposal program through child-owned implementation, validation,
closeout, archive handoff, Change closeout, final sync, cleanup proof, and
terminal proof while preserving child authority. Report the highest
evidence-backed delivery outcome if `cleaned` cannot be proven.

## Mandatory Preflight

From the repository root, rerun and require both gates to pass before doing any
implementation, delivery, Git mutation, archive, cleanup, or terminal proof
work:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
```

Stop if either gate fails, any accepted review digest is stale, any child
readiness check fails, any predecessor gate is unmet, or any packet has
blockers, unresolved questions, or clarification requirements.

## Authority Boundaries

- Parent evidence may summarize child posture by reference only.
- Parent evidence must not satisfy child receipts, child promotion targets,
  child validation verdicts, child archive metadata, child cleanup
  dispositions, or child terminal outcomes.
- Proposal-local files, generated prompts, generated outputs, host state, tool
  state, chat history, and model memory are not authority.
- Do not hand-edit generated/effective outputs.
- Do not mutate Git, hosted branches, PR state, branch cleanup, archive state,
  or repo hygiene residue outside the owning closeout and cleanup routes.

## Execution Order

Use canonical `child-before-parent-delivery` order. Do not use a different
order unless a retained target-bound `proposal-program-delivery-order-override-receipt-v1`
exists and validates.

1. Implement `proposal-delivery-input-contract-alignment`.
   - Scope: align delivery inputs across workflow, command, skill, profile,
     receipt, manifest, validator, and lifecycle documentation surfaces.
   - Required proof: missing required inputs fail before mutation; resume paths
     cite retained receipt or run evidence.

2. Implement `proposal-program-delivery-operator-alias`.
   - Scope: add only the optional delegating alias
     `octon-proposal-run-program-delivery`.
   - Required proof: alias delegates to `proposal-program-delivery` and owns no
     independent workflow, lifecycle, closeout, archive, cleanup, or terminal
     proof authority.

3. Implement `proposal-program-delivery-host-projections`.
   - Scope: publish or correct repo-local `.codex` command and skill
     projections for accepted proposal delivery wrappers.
   - Required proof: every projection cites canonical `.octon` source surfaces
     and remains non-authoritative.

4. Implement `proposal-program-review-loop-documentation`.
   - Scope: document existing parent-local `program-review-revision` behavior
     and the intentional absence of a standalone wrapper.
   - Required proof: documentation and tests preserve child authority
     boundaries.

5. Implement `proposal-lifecycle-surface-validation-hardening`.
   - Scope: add regression validation for lifecycle surface coherence,
     projection/catalog claims, closeout, archive handoff, cleanup, terminal
     proof, generated-output freshness, and child authority boundaries.
   - Required proof: validators distinguish intentional asymmetry from missing
     lifecycle surfaces without making projection mirrors authoritative.

For each implemented child packet, produce and pass:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Each child closeout, archive handoff, cleanup disposition, and terminal proof
must remain child-owned and cite child-owned evidence.

## Parent Orchestration Evidence

After child-owned implementation evidence exists, write parent-local
`support/program-implementation-orchestration-run.md` with:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`
- `child_authority_preserved: yes`

This parent run receipt may summarize child outcomes but never satisfies child
receipts, promotion targets, validation verdicts, archive metadata, cleanup
disposition, or terminal outcomes.

## Delivery Route

After retained delivery-readiness preflight passes, run:

```text
/proposal-program-delivery target=.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence outcome=cleaned
```

The aggregate delivery receipt may claim `cleaned` only when child-owned
implementation receipts, publication freshness, packet closeout, archive
handoff, Change closeout, landing proof, branch cleanup authorization, final
sync proof, terminal proof, worktree hygiene, and cleanup authorization all
pass. Otherwise, record the highest evidence-backed outcome, blocker class,
downgrade rationale, excluded evidence classes, and next owning lifecycle.

## Required Validators

Run the relevant child validators from each child packet plus these program
checks from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <aggregate-delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --index <compact-delivery-evidence-index>
```

## Stop Conditions

Stop and report the next owning lifecycle if any prerequisite receipt is
missing, stale, contradictory, or outside local authority; if cleanup lacks an
owning cleanup authorization; if generated or host projection evidence is used
as authority; if product catalog claims outstate available surfaces; or if the
parent attempts to satisfy child-owned evidence.
