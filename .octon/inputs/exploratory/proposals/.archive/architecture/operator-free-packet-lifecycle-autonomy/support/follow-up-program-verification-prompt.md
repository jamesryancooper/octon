prompt_id: operator-free-packet-lifecycle-autonomy-follow-up-program-verification-20260618T203622Z
generated_by: octon-proposal-lifecycle-generate-program-verification-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
route: run-program-verification-and-correction-loop
artifact_class: operational-aid
authority: non-authoritative

# Follow-Up Program Verification Prompt

## Purpose

Run aggregate parent program verification for
`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
after all required P0/P1 child packets have reached `implemented`.

This prompt is an operational handoff. It is not control truth, parent closeout
evidence, child evidence, archive authorization, cleanup authorization, landing
authorization, publication authorization, or a `cleaned` claim.

## Boundaries

- Preserve parent `proposal.yml#status: accepted`.
- Do not promote, close out, archive, clean, land, publish, delete, or claim
  `cleaned` for the parent.
- Do not use parent evidence to satisfy child-owned evidence.
- Do not recreate child evidence casually; inspect existing child receipts and
  retained evidence.
- Do not mutate child manifests, child receipts, child archive metadata, child
  validation verdicts, or child promotion targets from the parent route.
- Do not hand-edit generated outputs. Refresh generated outputs only through
  canonical generators if a validator proves they are stale.
- Treat generated proposal registry and artifact outputs as derived-only.

## Required Inputs

Parent program:

- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/architecture/packet-sequence.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/architecture/child-packet-contract.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/architecture/program-closeout-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/RISK-REGISTER.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/validation-plan.md`
- parent support receipts under `support/`

Required child packets:

- `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
- `.octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection`
- `.octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation`
- `.octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`

Retained evidence indexes:

- `.octon/state/evidence/runs/blocked-delivery-receipt-semantics-retained-index-20260618T192000Z/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/packet-delivery-wrapper-orchestration-autonomy-retained-index-20260618T192000Z/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/branch-no-pr-closeout-state-machine-autonomy-retained-index-20260618T192000Z/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/generated-freshness-scope-detection-retained-index-20260618T192000Z/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/packet-worktree-partitioning-automation-retained-index-20260618T192000Z/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/terminal-evidence-sink-autonomy-retained-index-20260618T192000Z/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/git-mutation-sandbox-preflight-retained-index-20260618T192000Z/retained-run-evidence-index.yml`

## Verification Work

1. Confirm current worktree state and classify changes as child durable
   targets, child proposal-local receipts, parent-local coordination evidence,
   canonical generated outputs, retained evidence, or unrelated residue.
2. Confirm parent status is `accepted`.
3. Confirm every required child status is `implemented`.
4. Confirm each child has fresh child-owned review, implementation,
   conformance, drift/churn, validation, and strict architecture evidence.
5. Confirm every parent child-registry `evidence_index_refs` entry points to a
   valid retained-run evidence index.
6. Verify parent sequence, dependency order, risk register, validation plan,
   child packet contract, and closeout plan against implemented child outcomes.
7. Inspect durable targets for parent or child proposal-path backreferences.
8. Verify generated proposal registry and child artifact bundles are fresh
   using canonical checks or canonical generators when required.
9. Produce stable findings with owner classification:
   - `parent`
   - `child:<child-id>`
   - `child-group:<group-id>`
   - `cross-packet`
10. If findings exist, generate targeted correction prompts through the
    governed program correction route and stop before unrelated mutation.

## Required Validators

Run at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

For each retained evidence index, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh --index <index>
```

For each required child, rerun dependency-gate validators when freshness is
uncertain, when parent/child/generated evidence changed, or when a finding
depends on the child gate:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal <child> --run-registry-check
```

## Required Outputs

On aggregate pass, write parent-local receipts only:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Each receipt must include:

- `verdict: pass`
- `unresolved_items_count: 0`
- `child_receipt_summary_count: 7`
- `child_authority_preserved: yes`
- child status summary
- retained evidence index summary
- validators run with results
- generated outputs refreshed, if any, and the canonical generator used
- remaining blockers or `none`

Use `verdict: pass` and `child_authority_preserved: yes` only when child
manifests, child receipts, child promotion targets, child validation verdicts,
child archive metadata, and child terminal outcomes remain child-owned.

## Stop Conditions

Stop and generate a governed correction prompt if any validator fails, any
child evidence is missing or stale, any evidence index is invalid, any
generated output is stale and cannot be refreshed through its canonical
generator, any durable target contains active proposal-path backreferences, or
any parent summary would be needed to satisfy child-owned evidence.

Do not proceed to parent closeout. The next route after aggregate verification
passes is `octon-proposal-lifecycle-generate-program-closeout-prompt`, followed
only by an explicitly authorized parent closeout route.
