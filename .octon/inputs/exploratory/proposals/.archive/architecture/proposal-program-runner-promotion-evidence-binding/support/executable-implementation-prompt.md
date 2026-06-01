# Executable Implementation Prompt

This file is an operational aid for the accepted proposal packet
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding`.
It is not authority, approval, retained implementation evidence, or promotion
proof. Durable authority remains in the declared promotion targets and the
post-implementation receipts produced after implementation.

## Required Starting Gate

Before making durable changes, re-run the implementation authorization gate and
stop if it does not pass:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding --require-implementation-authorization
```

The packet must still have `proposal.yml#status: accepted`, a fresh accepted
`support/proposal-review.md`, zero open blocking findings, and
`implementation_prompt_authorized: yes`. Do not rewrite the packet status to
`implemented`; the `promote-proposal` lifecycle route owns that mutation.

## Target End State

The proposal-program runner fails closed before workflow-owned
`promote-proposal` dispatch unless each supplied `promotion_evidence` path is
repo-relative, existing, selected-child-bound, and consistent with the selected
child identity, child target, child-owned implementation receipts, and child
promotion target lineage. Wrong-child, parent-owned, missing, stale, or
lineage-mismatched evidence must produce retained blocker evidence and must not
reach workflow dispatch. Valid selected-child evidence must still reach the
existing workflow-owned promotion path, with status mutation left to
`promote-proposal`.

## In Scope

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`

Use existing helpers, structs, receipt planning, authority-zone decisions,
program events, lifecycle executor request building, and generated publication
scripts. Add no broad new lifecycle authority surface.

## Out Of Scope

- Rewriting child `proposal.yml#status` from the program runner.
- Letting parent evidence satisfy child implementation, conformance,
  drift/churn, promotion, closeout, or archive requirements.
- Changing `promote-proposal` to delegate status mutation to the runner.
- Treating proposal-local support files as proof that durable implementation
  landed.
- Editing unrelated workflow families, lifecycle executor crates, product
  catalogs, policy surfaces, or generated outputs by hand.
- Expanding this proposal beyond the three declared promotion target families.

If the implementation cannot satisfy the target state inside these boundaries,
record a blocked implementation result in the packet and stop for packet
revision instead of widening scope.

## Ordered Workstreams

1. Reconfirm live context and worktree state.
   - Read root `AGENTS.md`, `.octon/instance/ingress/AGENTS.md`, the packet
     manifests, this prompt, the current three promotion targets, and the
     generated effective proposal-lifecycle contract projection.
   - Check `git status --short` and preserve unrelated local changes.
   - Treat generated effective surfaces as derived publication outputs, not
     source authority.

2. Harden child promotion evidence binding in
   `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`.
   - Bind `promotion_evidence` for child `promote-proposal` dispatch to the
     selected `ProgramChildPlanState.child_id`, `target`, `write_scopes`, and
     `receipt_digests`.
   - Normalize comma-separated evidence inputs with a structured helper. Reject
     absolute paths, empty entries, path traversal, duplicate ambiguity,
     missing files or directories when a file is required, generated-only
     authority claims, parent-target overlap, and paths outside the selected
     child's declared promotion targets or non-proposal write scopes.
   - Do not preserve explicit `promotion_evidence` blindly for child promotion
     routes. Explicit evidence may be accepted only after it passes the same
     selected-child binding checks as derived evidence.
   - Re-read the selected child lifecycle plan before dispatch when needed to
     prove `implementation-run`, `implementation-conformance`, and
     `post-implementation-drift` receipts are present, pass, complete, and not
     stale. The digests recorded in `ProgramChildPlanState.receipt_digests`
     must match the current child-owned receipt files when digest data exists.
   - Emit retained pre-dispatch blocker evidence under the current program run
     evidence root for missing, stale, wrong-child, parent-owned, or
     lineage-mismatched promotion evidence. Use explicit blocker classes such
     as `missing-promotion-evidence`, `stale-promotion-evidence`, and
     `wrong-child-promotion-evidence`, and include the selected child id,
     child target, route id, rejected paths, required receipt digests, observed
     receipt digests, registry digest, and write-scope digest.
   - Return a child preflight summary with zero attempts and no workflow
     request when evidence binding fails. The failure must occur before
     `lifecycle_execution_request_for_route` can dispatch `promote-proposal`.
   - Preserve the valid path: when evidence is selected-child-bound and
     receipts are fresh, the existing workflow-owned `promote-proposal`
     dispatch remains reachable.

3. Align the promote-proposal workflow contract and stage text under
   `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`.
   - Keep the workflow as the only status mutation path.
   - Clarify that promotion evidence must be repo-relative, existing,
     durable-target-bound, and independent of proposal-local paths before the
     workflow rewrites status.
   - Make the workflow documentation fail closed for wrong-child or
     parent-owned evidence when invoked from a program child route.
   - Do not add workflow claims that bypass runner-side selected-child binding.

4. Align the proposal-packet lifecycle contract at
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`.
   - Preserve `promotion_evidence` as an input binding for promotion and
     archive routes.
   - Add or tighten gate and receipt wording only as needed to state that
     promotion evidence is consumed by `promote-proposal` after
     implementation-run, implementation conformance, and drift/churn receipts
     are available.
   - Keep generated effective publication surfaces derived from source; do not
     manually edit generated files.

5. Add focused regression coverage in the existing kernel test surface.
   - Add negative tests for explicit wrong-child evidence, parent-owned
     evidence, stale child receipt digest, and missing evidence.
   - Add a positive test proving valid selected-child evidence reaches
     workflow-owned promotion dispatch and carries normalized promotion
     evidence.
   - Prefer tests inside `lifecycle_program.rs` near existing proposal-program
     runner tests. Do not create a new test family unless existing test
     placement is insufficient, and record the reason in the implementation
     receipt if a new test surface is unavoidable.

6. Publish derived extension state only if source extension files changed.
   - Run the extension publication command instead of hand-editing
     `.octon/generated/effective/extensions/**`.
   - Retain publication receipts under the existing publication evidence roots.
   - If extension publication invalidates capability routing, republish
     capability routing with the existing script and retain its receipt.

## Validation Commands

Run the smallest credible set, then broaden if a touched surface requires it:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel promotion_evidence -- --nocapture
cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel child_promotion -- --nocapture
cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel --test proposal_program_cli -- --nocapture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-promote-proposal-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh
git diff --check -- .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs .octon/framework/orchestration/runtime/workflows/meta/promote-proposal .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml .octon/generated/effective/extensions .octon/generated/effective/capabilities
```

If `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
changes, also run:

```sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
```

After durable changes and validation, run the post-implementation proposal
gates in this order:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
```

## Evidence Outputs

Retain deterministic validation evidence outside generated outputs, preferably
under `.octon/state/evidence/validation/proposals/proposal-program-runner-promotion-evidence-binding/`.
Record command transcripts, validator summaries, test names, and publication
receipt paths.

After durable changes land, create or update
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding/support/implementation-run.md`
with at least:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`

The implementation-run receipt must also summarize the changed promotion
targets, validation commands, retained evidence paths, rollback posture, and
any blockers. A passing receipt may not rely on proposal-local support files as
implementation proof.

Then create or update
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding/support/implementation-conformance-review.md`
with the sections required by the validator:

- `verdict`
- `unresolved_items_count`
- `Blockers`
- `Checked Evidence`
- `Promotion Target Coverage`
- `Implementation Map Coverage`
- `Validator Coverage`
- `Generated Output Coverage`
- `Rollback Coverage`
- `Downstream Reference Coverage`
- `Exclusions`
- `Final Closeout Recommendation`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
```

Then create or update
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding/support/post-implementation-drift-churn-review.md`
with the sections required by the validator:

- `verdict`
- `unresolved_items_count`
- `Blockers`
- `Checked Evidence`
- `Backreference Scan`
- `Naming Drift`
- `Generated Projection Freshness`
- `Manifest And Schema Validity`
- `Repo-Local Projection Boundaries`
- `Target Family Boundaries`
- `Churn Review`
- `Validators Run`
- `Exclusions`
- `Final Closeout Recommendation`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding
```

## Rollback Posture

Rollback is patch reversal of the promotion evidence binding checks, workflow
text, lifecycle contract text, tests, and any derived publication outputs from
the same implementation. Keep the change coherent: do not leave runtime code
expecting a contract shape that the authored or generated lifecycle contract
does not publish. If publication commands produce derived output, rollback the
source change and rerun publication rather than editing generated files by
hand.

## Terminal Criteria

The implementation route can report success only when all of the following are
true:

- The three declared promotion target families contain the complete durable
  change and no unrelated durable target is added.
- Wrong-child, parent-owned, missing, and stale promotion evidence fail before
  workflow dispatch and retain blocker evidence.
- Valid selected-child promotion evidence still reaches workflow-owned
  `promote-proposal` dispatch.
- `proposal.yml#status` remains `accepted`.
- `support/implementation-run.md` exists and records the implemented result.
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh` passes.
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh` passes.
- Generated effective extension or capability outputs, if changed, were
  produced by publication scripts and have retained publication receipts.
- No retained evidence, support receipt, or final summary claims implemented,
  closeout, or archive-ready status while either post-implementation receipt is
  missing, failing, unresolved, or blocked.

## Closeout Refusal Criteria

Refuse closeout and record a blocked implementation result if promotion
evidence can reach workflow dispatch while missing, stale, parent-owned,
wrong-child, outside the selected child write scopes, or unsupported by fresh
child-owned implementation receipts. Refuse archive or closeout claims if
conformance, drift/churn, generated publication, rollback, or retained evidence
requirements remain unresolved.

Delegation is optional. If delegated implementation is used, split work by
disjoint write scopes and keep one integration owner accountable for final
validation, evidence, generated publication, and receipt correctness.
