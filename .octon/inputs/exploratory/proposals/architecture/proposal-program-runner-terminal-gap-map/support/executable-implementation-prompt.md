# Executable Implementation Prompt

implementation_prompt_id: proposal-program-runner-terminal-gap-map-implementation-prompt-20260601T022228Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-01T02:22:28Z

This prompt is an operational aid for the accepted proposal packet. It does
not approve execution, widen scope, replace the proposal manifest, replace
durable Octon authority, or substitute for retained evidence.

The packet is a terminal-routing gap-map child. Its implementation end state
is a verified, receipt-backed downstream handoff: the implementer must
reconfirm the reviewed gap map against live repository state, preserve child
ownership for all open or partial terminal-routing fixes, and record the
implementation, conformance, and drift receipts required by the packet
lifecycle. Do not use this packet to implement sibling child fixes.

## Mandatory Preflight

Before editing any file, re-read:

- repo ingress and the constitutional kernel required by `AGENTS.md`;
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`;
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`;
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`;
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`;
- this packet's `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/current-state-gap-map.md`;
- `architecture/file-change-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `architecture/cutover-checklist.md`;
- `architecture/rollback-plan.md`;
- `validation-plan.md`;
- `resources/evidence-plan.md`;
- `resources/risk-register.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- the live promotion target surfaces listed below.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map --require-implementation-authorization
```

Refuse implementation unless both commands pass, `proposal.yml#status` is
`accepted`, `support/proposal-review.md` has `verdict: accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`,
and the reviewed packet digest is fresh.

Profile Selection Receipt for this packet:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent gap-map handoff implementation with no partial
  live terminal-routing mutation
- transitional exception: not authorized

## Promotion Targets

Approved durable target envelope:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`

Use these as live evidence and mutation boundaries only. This packet's
reviewed file-change map assigns actual G-001 through G-009 behavior changes
to downstream child packets. Do not implement those downstream fixes here.

## Target End State

The implemented state must establish all of these facts:

- G-001 through G-009 in `architecture/current-state-gap-map.md` have been
  rechecked against the current live repository state before any
  implementation receipt is written.
- The current classifications remain evidence-bound, or the route stops with
  a blocked `support/implementation-run.md` that explains the stale-source
  conflict and routes back to packet revision.
- The open workflow retry id collision and partial replay-safe resume gaps
  remain owned by `proposal-program-runner-workflow-retry-ids`.
- Closeout and worktree handoff checkpoint work remains owned by
  `proposal-program-runner-change-handoff-checkpoints` and remains
  non-authorizing.
- Parent aggregate blocker evidence remains parent-controller evidence and
  never replaces child receipts.
- Promotion evidence binding remains selected-child and receipt-lineage
  scoped before workflow-owned `promote-proposal` dispatch.
- Generated/effective freshness drift remains non-authoritative and routes to
  canonical publication recovery or the declared recovery action.
- Parent review freshness excludes volatile run-control and route-created
  evidence outside the reviewed packet artifact surface.
- Archive observation remains fixed for active-to-archive target moves, with
  any further blocked archive evidence delegated to the owning child packet.
- Terminal-routing regression coverage remains downstream-owned unless this
  route only records the current validation expectation.
- `proposal.yml#status` remains `accepted`; the `promote-proposal` lifecycle
  route owns the implemented-status rewrite.

## In Scope

In scope for this implementation route:

- Re-read and verify live evidence in
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`,
  especially program planning, child state aggregation, recovery selection,
  closeout hygiene preflight, delegated promotion evidence, blocker
  normalization, checkpoint, recovery log, and aggregate closeout behavior.
- Re-read and verify live evidence in
  `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`,
  especially the current `workflow_run_id = format!("{}-workflow", request.run_id)`
  construction and retryable failure evidence.
- Re-read and verify live evidence in
  `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`,
  especially archived-target completion observation for `archive-proposal`.
- Re-read and verify relevant executor files under
  `.octon/framework/engine/runtime/crates/lifecycle_executor/src/` when they
  materially affect request, authorization, adapter, or result evidence.
- Re-read and verify lifecycle context under
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`,
  especially `lifecycle.contract.yml`,
  `lifecycles/proposal-program.contract.yml`, `lifecycle-model.md`,
  `routing-guide.md`, `output-boundaries.md`, and
  `patterns/proposal-program.md`.
- Record packet-local implementation evidence in
  `support/implementation-run.md`.
- Create or update `support/implementation-conformance-review.md`.
- Create or update `support/post-implementation-drift-churn-review.md`.
- Run the validators listed in this prompt and record their results.

Durable target edits are not expected for this gap-map child. If live
repository state contradicts the accepted gap map, stop and record a blocked
implementation outcome instead of silently rewriting the architecture or
implementing a sibling child fix.

## Out Of Scope

Do not edit:

- sibling proposal packets, including
  `proposal-program-runner-workflow-retry-ids`,
  `proposal-program-runner-change-handoff-checkpoints`,
  `proposal-program-runner-aggregate-terminal-blockers`,
  `proposal-program-runner-promotion-evidence-binding`,
  `proposal-program-runner-publication-freshness-preflight`,
  `proposal-program-runner-parent-review-churn`,
  `proposal-program-runner-archive-observation-recovery`, or
  `proposal-program-runner-terminal-routing-tests`;
- the parent program packet except through separately routed parent lifecycle
  execution;
- `.octon/generated/effective/**` or `.octon/generated/proposals/registry.yml`
  by hand;
- workflow-owned `promote-proposal` or `archive-proposal` behavior for this
  gap-map packet;
- Change closeout, worktree cleanup, branch cleanup, repo-hygiene deletion, or
  hosted-provider state;
- `.octon/state/control/**` or `.octon/state/evidence/**` except retained
  validation evidence created by commands or lifecycle execution;
- `proposal.yml#status`.

If any out-of-scope edit appears necessary, stop and write
`support/implementation-run.md` with `verdict: blocked`, concrete evidence,
and `required_next_route: revise-packet` or the specific downstream child
route that owns the gap.

## Ordered Workstreams

### 1. Baseline And Search Receipt

1. Record the current worktree state and preserve unrelated existing changes.
2. Run the mandatory preflight gates.
3. Search before changing anything:
   - `rg -n "workflow_run_id|retry_attempt|replay|promotion_evidence|publication-drift|archive|closeout|normalized_child_blockers" .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs .octon/framework/engine/runtime/crates/lifecycle_executor/src .octon/inputs/additive/extensions/octon-proposal-lifecycle/context`
   - `rg -n "implementation-run|implementation-conformance|post-implementation-drift|proposal-closeout|promote-proposal|archive-proposal" .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
4. Record searched surfaces, reused surfaces, rejected edits, and
   non-authority boundaries in `support/implementation-run.md`.

### 2. Gap Map Verification

For each gap in `architecture/current-state-gap-map.md`:

1. Reconfirm the cited live evidence.
2. Confirm the downstream owner remains correct.
3. Confirm the required change or no-op rationale remains current.
4. Confirm the validation expectation remains specific and executable.
5. If a gap classification has changed because another route already landed
   durable work, record the current evidence and stop for packet revision
   unless the accepted packet already permits the changed classification.

Do not close an open or partial gap by changing runtime behavior in this
packet. Downstream child packets must provide their own accepted reviews,
implementation receipts, validation evidence, closeout receipts, and archive
metadata.

### 3. Implementation Receipt

Create or update
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map/support/implementation-run.md`
after the gap-map handoff verification completes.

The receipt must include at least:

- `verdict: pass` or `verdict: blocked`;
- `implemented_at: <UTC timestamp>`;
- `promotion_evidence_count: <number>`;
- `implementation_type: verified-gap-map-handoff`;
- `durable_target_edits: none` unless a packet revision explicitly authorizes
  a durable target correction;
- `proposal_status_preserved: accepted`;
- `review_gate: passed`;
- `readiness_gate: passed`;
- `promotion_targets_rechecked`;
- `downstream_child_ownership_preserved: yes`;
- `generated_outputs_changed: no`;
- `retained_evidence_refs`;
- rollback notes.

Use `promotion_evidence_count: 0` when no durable target file changed. If any
durable target did change under explicit packet revision authority, count and
list the evidence for every changed promotion target.

### 4. Conformance Review

Create or update
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map/support/implementation-conformance-review.md`
after `support/implementation-run.md`.

The receipt must include `verdict` and `unresolved_items_count`, and these
sections:

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

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
```

The review must fail or block if promotion targets were not rechecked, if a
downstream child receipt was synthesized by this packet, if generated output
was treated as authority, or if `proposal.yml#status` was changed away from
`accepted`.

### 5. Post-Implementation Drift And Churn Review

Create or update
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map/support/post-implementation-drift-churn-review.md`.

The receipt must include `verdict` and `unresolved_items_count`, and these
sections:

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

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
```

The review must fail or block on proposal-path backreferences from durable
targets, unexpected generated projection churn, registry drift caused by this
route, target-family widening, stale source evidence, or hidden downstream
scope changes.

## Validation Commands

Run and record the packet validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-gap-map
```

If durable Rust or lifecycle context files are edited after an explicit packet
revision, also run the focused commands that match the touched surfaces:

```sh
cargo test -p octon_lifecycle_executor --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
cargo test -p octon_kernel --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh
```

Do not claim success if any required validator fails, cannot run, or produces
an unresolved blocker. Record blocked validation evidence instead.

## Retained Evidence

Retain implementation and validation evidence in packet support receipts and,
when command output needs durable retention, under:

- `.octon/state/evidence/validation/proposals/proposal-program-runner-terminal-gap-map/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` if lifecycle execution
  creates workflow run evidence
- `.octon/state/evidence/runs/<run-id>/` if the generic lifecycle runner
  creates run evidence

Do not store retained evidence in `.octon/generated/**`. Do not treat
proposal-local support files as durable implementation proof for downstream
child packets.

## Rollback Posture

If no durable target changed, rollback before promotion is removal or reversal
of this packet's implementation support receipts. Do not delete retained run
evidence produced by validators or lifecycle execution.

If a later packet revision explicitly authorizes durable target edits, rollback
must be patch reversal of only those edits plus re-running the relevant
validators. Rollback must not remove child receipts, parent program evidence,
generated/effective locks, workflow-owned archive or promotion evidence,
closeout receipts, or retained validation evidence.

## Delegation

Delegation is optional and not a control requirement. If the implementer uses
workers, assign one integration owner and disjoint read/write scopes. Workers
must not edit sibling proposal packets, synthesize child receipts, mutate
generated/effective outputs by hand, or move closeout, cleanup, promotion,
archive, publication, or run-control authority into this packet.

## Terminal Criteria

This implementation route is complete only when:

- mandatory preflight gates pass;
- live promotion targets are rechecked;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, and `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh` passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh` passes;
- downstream child ownership remains intact;
- no generated output, proposal registry entry, workflow route, closeout
  state, archive state, or run-control truth was mutated by hand;
- `proposal.yml#status` remains `accepted`.

Refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, stale, failing, unresolved, or blocked.
The next lifecycle route after a passing implementation receipt is still
route-owned by the proposal-packet lifecycle; do not perform the
`implemented` status rewrite in this route.
