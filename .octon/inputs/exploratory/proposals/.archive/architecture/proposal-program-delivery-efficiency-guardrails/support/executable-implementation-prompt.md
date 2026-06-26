# Executable Implementation Prompt

Implement the accepted architecture packet at
`.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails`.

This prompt is an operational aid only. It does not authorize work outside the
accepted packet, does not make proposal-local files authoritative, and does not
replace the accepted proposal review, durable implementation receipts, retained
evidence, validators, Change closeout, or later promotion routes.

## Target End State

Proposal-program delivery is fail-closed and efficient by construction:

- canonical order is enforced as
  `child implementation -> child validation -> child closeout -> child archive -> parent/program delivery -> landing/sync/cleanup`;
- non-canonical requested order stops in stage 01 unless a schema-valid,
  retained, target-bound override receipt exists;
- one consolidated delivery readiness preflight runs before expensive lifecycle
  continuation, Git mutation, publication checks, parent delivery, landing,
  sync, cleanup, or branch deletion;
- stale or dirty source branches default to a clean route-owned worktree from
  current `origin/main`, with include-path classification before reconstruction,
  staging, or commit;
- readiness projection and child readiness validators share one implementation
  of archived child `support/validation.md` pass semantics;
- long, repeatedly blocked, or recovered proposal-program runs require
  validated lifecycle postmortem evidence before learned-from completion claims.

Keep `proposal.yml#status` as `accepted`. The separate promote-proposal route
owns the implemented-status rewrite after implementation evidence passes.

## In Scope

The implementation may modify only the declared promotion targets:

- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-order-override-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh`
- `.octon/framework/assurance/runtime/_ops/lib/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Use existing validator style, shell/Python/YAML tooling, fixture placement,
workflow vocabulary, and evidence roots. If a target needs a new child file, put
it under the declared target family and keep the boundary narrow.

## Out Of Scope

Do not rerun parent/program delivery, child implementation, child validation,
child closeout, child archive, publication refresh, branch landing, final sync,
cleanup, PR creation, or branch deletion.

Do not edit archived child receipts. Do not replace child-owned receipts with a
parent summary. Do not use generated outputs, generated prompts, dashboards,
chat, model memory, host state, or proposal-local support files as runtime,
policy, support, closeout, archive, delivery, publication, cleanup, or
authority proof.

Do not use broad stage-all unless route-owned include-path classification names
every included path and proves it is intended and publishable. Do not delete
retained evidence or local residue without the owning cleanup route and
authorization evidence.

## Workstreams

1. Re-run prerequisites before durable edits:
   - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails --require-implementation-authorization`
   - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails`

2. Extend the delivery profile contract:
   - add `execution_order_policy` to
     `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`;
   - require `canonical_order_required`,
     `canonical_order_ref: child-before-parent-delivery`,
     `operator_requested_alternative_order`,
     `requested_order_ref`,
     `override_required_when_order_differs`, and `override_receipt_ref`;
   - preserve existing PR, stash, child receipt, generated-output, closeout,
     hygiene, terminal proof, final sync, and non-authority requirements.

3. Add the order override receipt contract:
   - create
     `.octon/framework/product/contracts/proposal-program-delivery-order-override-receipt-v1.schema.json`;
   - require target program binding, run binding, requested order binding,
     operator identity or authority source, efficiency-risk acknowledgement,
     emitted timestamp, non-authority classification, and revocation/staleness
     handling;
   - make the receipt retained evidence only, not delivery authority by itself.

4. Update delivery receipt and workflow contracts:
   - extend
     `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
     so delivery receipts record order policy, override receipt status,
     readiness preflight status, clean-worktree route selection, include-path
     classification, and postmortem-required status when applicable;
   - update
     `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
     so stage 01 evaluates order policy before lifecycle continuation;
   - add the warning/stop behavior for non-canonical order without a valid
     override receipt;
   - add or wire a readiness preflight stage before child lifecycle
     continuation and parent/program delivery;
   - ensure later stages consume the retained readiness receipt instead of
     rediscovering authority blockers independently.

5. Implement validation behavior:
   - update
     `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
     to reject non-canonical requested order when no valid override receipt is
     bound and to accept it only with a target-bound, run-bound, schema-valid
     override receipt;
   - update
     `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
     to require the stage 01 order policy gate, readiness preflight placement,
     retained blocker receipt behavior, and clean-worktree route handoff;
   - update
     `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh`
     to fail closed for required proposal-program postmortem evidence gaps.

6. Consolidate child validation receipt semantics:
   - add the smallest reusable helper under
     `.octon/framework/assurance/runtime/_ops/lib/`;
   - move the archived child `support/validation.md` pass semantics used by
     readiness projection and child readiness into that helper;
   - update
     `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`
     and
     `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
     to call the helper;
   - preserve strict `verdict: pass` for implementation-run,
     implementation-conformance, drift/churn, closeout, delivery, and route
     receipts.

7. Wire clean route-owned worktree defaults:
   - update
     `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
     and
     `.octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh`
     only as needed to prove Git metadata write access, stale source posture,
     dirty source posture, route-owned clean worktree selection, and include
     path classification before reconstruction, staging, commit, push, landing,
     sync, cleanup, or branch deletion.

8. Update runtime command, skill, and lifecycle documentation:
   - update
     `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`;
   - update
     `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`;
   - update
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`;
   - update
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`;
   - keep all text as enforced behavior tied to validators and receipts, not
     prompt-only guidance.

9. Add positive and negative controls under
   `.octon/framework/assurance/runtime/_ops/tests/` and
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`
   as appropriate:
   - canonical order passes;
   - non-canonical order without override fails;
   - non-canonical order with valid override passes;
   - stale, target-mismatched, run-mismatched, or risk-unacknowledged override
     receipts fail;
   - stage 01 warning/stop blocks expensive continuation without override;
   - readiness preflight catches Git write, cleanliness, stale review, child
     receipt compatibility, tooling, route legality, and generated freshness
     blockers before expensive continuation;
   - stale or dirty source defaults to a clean route-owned worktree;
   - missing include-path classification blocks reconstruction and broad
     stage-all;
   - readiness projection and child readiness accept the same archived child
     validation receipt success forms;
   - fail, failed, error, blocked, malformed, missing, or mixed-status child
     validation receipts fail closed;
   - lifecycle postmortem threshold cases require valid `evaluation.yml`,
     `report.md`, `readiness-summary.md`, and digest-bound evidence references;
   - prompt text, parent summaries, generated projections, dirty worktree
     residue, and missing postmortem artifacts cannot authorize delivery.

10. Refresh generated outputs only through owning generators when required by
    touched authoritative sources. Generated output remains derived-only and
    cannot authorize route decisions.

## Required Evidence Outputs

After durable changes land, update packet support evidence:

- `support/implementation-run.md` with at least `verdict`,
  `implemented_at`, `promotion_evidence_count`, promotion target coverage,
  commands run, evidence refs, rollback posture, and blockers or `none`;
- `support/implementation-conformance-review.md` with `verdict: pass` only
  when every accepted promotion target is implemented or explicitly
  non-applicable with rationale;
- `support/post-implementation-drift-churn-review.md` with `verdict: pass`
  only when no unrelated churn, duplicate helper, proposal-path dependency,
  generated-output authority drift, or cleanup residue was introduced;
- `support/validation.md` with the final validation command list and outcomes.

Retained implementation evidence belongs under canonical `.octon/state/evidence/**`
roots when a run emits retained evidence. Do not place retained evidence in
`.octon/generated/**`, and do not treat this proposal packet as durable
authority after implementation.

## Validation Commands

Run packet gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails
```

Run implementation validators and focused tests:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --help
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --help
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh --help
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-readiness-projection.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-child-readiness.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-postmortem.sh
```

Run post-implementation packet gates before any success claim:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails
```

Run publication or registry checks only through owning generators when touched
source surfaces require them. Record command, cwd, start/end time, exit code,
bounded output, and retained evidence ref or explicit no-retained-evidence
rationale.

## Rollback Posture

This packet is atomic. If implementation cannot pass the gates, revert the
delivery-profile schema, override receipt schema, delivery receipt schema,
validators, shared helper, workflow stages, command and skill text, lifecycle
contract changes, Git preflight updates, and tests as one coherent Change
unless a later packet revision explicitly splits the scope.

Rollback must preserve retained evidence and must not delete child-owned
receipts, archive evidence, generated publication evidence, or unrelated local
work. If partial edits reached generated outputs, refresh them through owning
generators or revert them with the same Change; never hand-edit generated
outputs into a claimed fresh state.

## Terminal Criteria

Implementation may be reported as ready for promotion only when all of these
conditions hold:

- every declared promotion target is implemented or explicitly non-applicable
  with reviewable rationale;
- positive and negative controls cover execution order, override receipts,
  readiness preflight, clean-worktree defaulting, shared receipt semantics,
  lifecycle postmortem thresholds, generated-output authority, parent summary
  substitution, prompt-only authority, and broad stage-all rejection;
- `support/implementation-run.md` records `verdict: pass`;
- `support/implementation-conformance-review.md` records `verdict: pass`;
- `support/post-implementation-drift-churn-review.md` records `verdict: pass`;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails`
  passes;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-efficiency-guardrails`
  passes;
- `proposal.yml#status` remains `accepted` for the later promote-proposal
  route.

Refuse closeout and archive claims, and block any implemented or archive-ready
claim, while either post-implementation receipt is missing, failing,
unresolved, blocked, stale, or unsupported by the validators above.
