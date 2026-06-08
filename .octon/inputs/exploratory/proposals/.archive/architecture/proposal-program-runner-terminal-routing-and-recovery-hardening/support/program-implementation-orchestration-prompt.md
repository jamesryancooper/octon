# Program Implementation Orchestration Prompt

generated_at: 2026-06-01T02:13:36Z
generator_route_id: generate-program-implementation-orchestration-prompt
program_packet_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening
verdict: ready-for-execution

This file is an operational prompt and evidence pointer. It is not Octon
authority, runtime truth, a child receipt, generated-effective authority, or a
substitute for child-owned validation.

## Gate Receipt

This prompt was generated only after the required gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening --require-implementation-authorization
```

Result: `errors=0 warnings=0`.

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening
```

Result: `errors=0 warnings=0`.

The live lifecycle contract also requires program structure before this route:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening
```

Result: `errors=0 warnings=0`.

## Execution Objective

Implement the coordinated proposal-program runner terminal-routing and recovery
hardening program while preserving every child packet as the owner of its
manifest, promotion targets, receipts, validation verdicts, rollback posture,
closeout posture, archive metadata, and terminal outcome.

The parent program owns sequencing, dependency gates, aggregate coordination,
and the final parent-local implementation orchestration receipt. It does not
implement child authority and must not satisfy child receipts.

## Hard Stops

Stop before durable edits when any of these conditions appear:

- the parent review gate or child-readiness gate no longer passes;
- a required non-deferred child packet becomes stale, blocked, rejected,
  missing, or inconsistent with `resources/child-packet-index.yml`;
- a requested edit falls outside the selected child manifest promotion targets;
- a shared file would require one child to silently absorb another child's
  scope without a recorded child-id mapping;
- generated/effective output is being treated as direct authority instead of
  a freshness-checked derived handle;
- workflow-owned promotion or archive mutation, Change closeout, cleanup
  deletion, publication, or registry refresh is being moved into the generic
  program runner;
- implementation would require policy override, scope expansion, stale
  evidence acceptance, or unresolved authority ambiguity.

## Parent-Owned Coordination Work

1. Re-run the three gates in the Gate Receipt before implementation begins.
2. Re-read the parent packet and every child packet from live repository state.
3. Build an execution board from `resources/child-packet-index.yml`,
   `architecture/packet-sequence.md`, and the child manifests.
4. Preserve the current parent boundary: the parent coordinates only and does
   not rewrite child receipts, child validation verdicts, child promotion
   targets, child closeout receipts, or child archive metadata.
5. Coordinate shared generated/runtime surfaces without hand-editing generated
   outputs or publishing generated state outside canonical scripts.
6. After program execution, write
   `support/program-implementation-orchestration-run.md` in the parent packet
   with at least:
   - `verdict`
   - `implemented_at`
   - `promotion_evidence_count`
   - `child_authority_preserved`
7. Use `verdict: pass` and `child_authority_preserved: yes` only when parent
   coordination evidence is complete and child manifests, child receipts,
   child promotion targets, child validation verdicts, and child archive
   metadata remain child-owned.

Parent implementation-run evidence may summarize child outcomes, but it never
satisfies child receipts or child promotion, closeout, archive, conformance, or
drift requirements.

## Child-Owned Implementation Targets

| Child | Target | Promotion targets | Required result |
| --- | --- | --- | --- |
| `proposal-program-runner-terminal-gap-map` | Verify the postmortem gap map against live runner, workflow, contract, validator, and evidence state before downstream edits. | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/` | Fresh gap classifications are either confirmed or superseded with live evidence. Downstream child scopes remain explicit. |
| `proposal-program-runner-workflow-retry-ids` | Make workflow retries collision-safe and separate retry dispatch from replay-safe resume. | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`; `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` | Fresh dispatch attempts do not reuse canonical workflow run ids; existing-run resume requires same-input, same-authority, same-target, replay-safe proof; ambiguous state fails closed with retained evidence. |
| `proposal-program-runner-change-handoff-checkpoints` | Add non-authorizing lifecycle interaction checkpoints for `closeout-change` and `closeout-worktree` handoff after mutating child batches. | `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`; `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`; `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`; `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` | Handoff evidence requests partitioning and returned evidence only; it cannot authorize Git mutation, cleanup deletion, publication, promotion, or archive. |
| `proposal-program-runner-aggregate-terminal-blockers` | Add parent-controller aggregate child terminal blocker evidence. | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; `.octon/framework/engine/runtime/spec/`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml` | Aggregate evidence lists all blocked required children with route id, blocker class, receipt freshness, terminal policy state, hygiene state, retry state, and next route condition while child receipts remain child-owned. |
| `proposal-program-runner-promotion-evidence-binding` | Bind supplied promotion evidence to the selected child identity and receipt lineage before workflow-owned promotion dispatch. | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml` | Wrong-child, missing, or stale promotion evidence fails before workflow dispatch; status mutation remains `promote-proposal` workflow-owned. |
| `proposal-program-runner-publication-freshness-preflight` | Classify generated-state freshness drift before avoidable workflow dispatch. | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; `.octon/framework/assurance/runtime/_ops/scripts/`; `.octon/framework/assurance/runtime/_ops/tests/`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml` | Stale runtime route bundle, extension catalog, pack route, capability routing, or generated proposal registry state routes to canonical publication scripts or declared recovery actions; generated output remains non-authority. |
| `proposal-program-runner-parent-review-churn` | Suppress irrelevant parent review churn while preserving strict implementation authorization gates. | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml` | Parent review freshness changes for parent-owned coordination surface changes and not merely for volatile run-control or route-created evidence outside the reviewed digest scope; implemented-state gates follow the lifecycle contract. |
| `proposal-program-runner-archive-observation-recovery` | Harden archive workflow observation and blocked archive evidence. | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`; `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`; `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` | Archive mutation remains workflow-owned; observation follows the archived target after active-path moves; duplicate run id, stale workflow state, missing archive authorization, or non-convergence emits machine-readable blocked archive evidence. |
| `proposal-program-runner-terminal-routing-tests` | Add integrated terminal-routing fixtures and negative controls. | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; `.octon/framework/engine/runtime/crates/kernel/tests/`; `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`; `.octon/framework/assurance/runtime/_ops/tests/`; `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/` | Tests cover workflow retry, change handoff, aggregate blockers, promotion binding, publication freshness, parent review freshness, archive observation, replay, locks, and fail-closed authority boundaries. |

## Sequencing And Parallelism

Declared execution mode is `gated-parallel`, but the current run checkpoint
uses `max_child_concurrency: 1`. Respect the active runner limit when executing
inside the lifecycle program runner.

When operating manually, parallel work is allowed only for read-only
reconnaissance or for edits with disjoint write scopes. Most behavior children
share `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`;
those edits must be coordinated as one integrated file plan while each changed
block remains mapped back to its child id and child receipt.

Use this handoff order:

1. `proposal-program-runner-terminal-gap-map` gates downstream implementation.
2. After the gap map is confirmed, prepare the following children in parallel
   only as read/design work; serialize shared writes:
   - `proposal-program-runner-workflow-retry-ids`
   - `proposal-program-runner-change-handoff-checkpoints`
   - `proposal-program-runner-aggregate-terminal-blockers`
   - `proposal-program-runner-promotion-evidence-binding`
   - `proposal-program-runner-publication-freshness-preflight`
   - `proposal-program-runner-parent-review-churn`
3. Run `proposal-program-runner-archive-observation-recovery` after workflow
   retry and aggregate terminal blocker behavior are implemented or explicitly
   proven unaffected.
4. Run `proposal-program-runner-terminal-routing-tests` only after all behavior
   children have child-owned implementation evidence or an explicit
   child-owned no-op/blocker receipt.

## Shared Runtime And Generated Surfaces

Coordinate these surfaces explicitly:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/generated/effective/runtime/route-bundle.yml`
- `.octon/generated/effective/runtime/route-bundle.lock.yml`
- `.octon/generated/effective/extensions/catalog.effective.yml`
- `.octon/generated/effective/extensions/generation.lock.yml`
- `.octon/generated/effective/capabilities/pack-routes.effective.yml`
- `.octon/generated/effective/capabilities/pack-routes.lock.yml`
- `.octon/generated/effective/capabilities/routing.effective.yml`
- `.octon/generated/proposals/registry.yml`

Generated surfaces may be checked for freshness and regenerated by canonical
publication or registry scripts only. Do not hand-edit generated outputs as a
substitute for source changes.

## Per-Child Receipt Protocol

For every required non-deferred child that receives implementation work:

1. Re-run child standard, readiness, and strict review gates before editing.
2. Keep edits inside that child's declared promotion targets.
3. Record a child-local `support/implementation-run.md` with at least
   `verdict`, `implemented_at`, and `promotion_evidence_count`.
4. Run and pass child-local implementation conformance before child closeout:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-packet-path>
   ```

5. Run and pass child-local post-implementation drift/churn before child
   closeout or implemented archival:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-packet-path>
   ```

6. Keep child `proposal.yml` lifecycle status changes, child closeout, and
   child archive metadata route-owned. Parent evidence may cite those results
   after they exist; it may not synthesize them.

If a child is intentionally no-op after fresh live evidence, record the
child-owned rationale and validation evidence in that child packet. Do not use
the parent run receipt as the no-op proof.

## Validation Commands

Run the gate commands first:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening
```

Run child proposal validators for each required child:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-packet-path> --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child-packet-path> --require-implementation-authorization
```

Run the focused runtime and assurance suite after implementation:

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_lifecycle_executor
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-child-readiness.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-review-gate.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-interaction-receipts.sh
```

After generated proposal registry changes are required by promotion or archive
routes, regenerate through the canonical script:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh
```

Then rerun applicable proposal validators for the parent and every touched
child.

## Evidence Outputs

Retain validation and route evidence under canonical evidence roots, not under
`generated/**`:

- `.octon/state/evidence/validation/**`
- `.octon/state/evidence/runs/skills/**`
- `.octon/state/evidence/runs/workflows/**`
- `.octon/state/control/skills/checkpoints/**` for resumable loops

The parent program execution must leave:

- child-owned `support/implementation-run.md` for each implemented child;
- child-owned `support/implementation-conformance-review.md` for each
  implemented child before closeout or archival;
- child-owned `support/post-implementation-drift-churn-review.md` for each
  implemented child before closeout or archival;
- any child-owned closeout or archive receipts produced by later child routes;
- parent-owned `support/program-implementation-orchestration-run.md` with
  `verdict`, `implemented_at`, `promotion_evidence_count`, and
  `child_authority_preserved`.

Use this minimum parent receipt shape:

```markdown
# Program Implementation Orchestration Run Receipt

verdict: pass
implemented_at: <UTC timestamp>
promotion_evidence_count: <integer>
child_authority_preserved: yes

## Parent Coordination Evidence

- gates rerun:
- child registry digest:
- sequence observed:
- validation commands:
- retained evidence refs:

## Child Outcome Summary

| Child | Implementation receipt | Conformance | Drift/churn | Promotion evidence | Notes |
| --- | --- | --- | --- | --- | --- |

## Authority Boundary Review

- child manifests remain child-owned:
- child receipts remain child-owned:
- child promotion targets remain child-owned:
- child validation verdicts remain child-owned:
- child archive metadata remains child-owned:

## Blockers

None.
```

If any child remains blocked, stale, or unimplemented, write `verdict: blocked`
or `verdict: fail` in the parent run receipt, preserve the child-owned blocker
evidence, and do not promote the parent as implemented.

## Terminal Criteria

The program implementation orchestration is complete only when:

- parent and child gates still pass from live repository state;
- all required non-deferred children have child-owned implementation outcomes;
- child conformance and drift/churn reviews pass before any child closeout or
  implemented archival;
- shared-file edits are traceable to child ids and promotion targets;
- workflow-owned promotion and archive mutation remain workflow-owned;
- Change closeout and worktree cleanup remain `closeout-change` /
  `closeout-worktree` or repo-hygiene route-owned;
- generated/effective freshness is checked through canonical handles or
  publication scripts;
- retained evidence is recorded under canonical evidence roots;
- the parent `program-implementation-orchestration-run.md` summarizes but does
  not replace child receipts;
- no proposal path is treated as durable runtime, policy, support, closure, or
  publication authority.
