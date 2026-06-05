# Program Implementation Orchestration Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-program-implementation-orchestration-prompt
program_packet_path: .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
verdict: ready-for-execution

This file is an operational prompt and evidence pointer. It is not Octon
authority, runtime truth, a child receipt, generated-effective authority, or a
substitute for child-owned validation.

## Gate Receipt

This prompt was generated only after the required gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery --require-implementation-authorization
```

Result: `errors=0 warnings=0`.

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
```

Result: `errors=0 warnings=0`.

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
```

Result: `errors=0 warnings=0`.

## Execution Objective

Implement the autonomous proposal-program lifecycle blocker recovery program
while preserving proposal input non-authority, generated-output derived-only
posture, and child-owned lifecycle authority.

Routine and soft blockers should be repaired, refreshed, retried, delegated, or
continued autonomously when safely repairable in scope. Hard blockers must stop
the runner.

## Hard Stops

Stop before durable edits when any of these conditions appear:

- parent review gate or child-readiness gate no longer passes;
- a required child becomes stale, blocked, rejected, missing, or inconsistent with `resources/child-packet-index.yml`;
- implementation would require destructive cleanup without repo-hygiene-cleanup authority or explicit approval;
- ownership is ambiguous;
- child-owned receipts or child authority are missing;
- parent summaries would be the only proof of child state;
- a requested edit widens beyond declared child promotion targets;
- external provider permission, external human review, or unsupported scope expansion is required;
- validation fails in a way that cannot be safely repaired within declared scope.

## Parent-Owned Coordination Work

1. Re-run the three gates in the Gate Receipt before implementation begins.
2. Re-read the parent packet and every child packet from live repository state.
3. Use `resources/child-packet-index.yml`, `architecture/packet-sequence.md`, and each child manifest to build the implementation board.
4. Coordinate shared write scopes without collapsing child authority.
5. Keep generated outputs derived-only and refresh them only through canonical publication routes when later implementation requires it.
6. Route local run-state cleanup only through repo-hygiene-cleanup with receipt-backed authority.
7. After program execution, write parent-local `support/program-implementation-orchestration-run.md` with at least:
   - `verdict`
   - `implemented_at`
   - `promotion_evidence_count`
   - `child_authority_preserved`
8. Use `verdict: pass` and `child_authority_preserved: yes` only when parent coordination evidence is complete and child manifests, child receipts, child promotion targets, child validation verdicts, and child archive metadata remain child-owned.

Parent implementation-run evidence may summarize child outcomes, but it never
satisfies child receipts, child promotion, child closeout, child archive,
child conformance, or child drift requirements.

## Child-Owned Implementation Targets

| Child | Purpose | Required result |
|---|---|---|
| `autonomous-blocker-taxonomy` | Define routine-autonomous, soft-blocker, and hard-blocker classes. | Durable lifecycle taxonomy exists with examples and hard-blocker negative controls. |
| `token-efficiency-preservation` | Preserve or improve token efficiency during recovery. | Recovery receipts, event deltas, and diagnostics remain compact while replayable evidence is preserved. |
| `validator-affordances` | Add validator diagnostics for recovery. | Validators emit compact machine-readable recovery classes, failing paths, accepted repairs, stale causes, and rerun gates. |
| `cleanup-routing` | Route local run-state residue through repo-hygiene-cleanup. | Cleanup is delegated with receipt-backed authority; wrappers do not delete ad hoc. |
| `evidence-and-receipt-hardening` | Harden child-owned receipt and replay evidence boundaries. | Child terminal claims require child-owned receipts; parent-summary-only proof is rejected. |
| `runner-recovery-behavior` | Implement bounded autonomous recovery behavior. | Runner repairs routine issues, retries soft blockers within policy, reruns gates, and stops on hard blockers. |
| `escalation-policy-update` | Update lifecycle escalation policy examples and criteria. | Operator escalation remains limited to hard blockers, with routine and soft blockers downgraded to autonomous handling. |

## Sequencing And Parallelism

Use the parent `gated-parallel` sequence:

1. Phase 0: `autonomous-blocker-taxonomy` and `token-efficiency-preservation`.
2. Phase 1: `validator-affordances` and `cleanup-routing`.
3. Phase 2: `evidence-and-receipt-hardening`.
4. Phase 3: `runner-recovery-behavior`.
5. Phase 4: `escalation-policy-update`.

Parallel read-only reconnaissance is allowed. Durable edits that share target
files must be integrated by one accountable orchestrator and mapped back to the
owning child packets.

## Validation And Evidence

At minimum, implementation must run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
```

Each child implementation must also create or update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Then each child must pass:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-packet-path>
```

The program must retain evidence for:

- routine-autonomous recovery examples;
- soft-blocker bounded retry examples;
- hard-blocker negative controls;
- cleanup delegation through repo-hygiene-cleanup;
- child-owned receipt preservation;
- token-efficiency or compact-summary checks.

## Rollback

Rollback is child-owned per child packet. Parent rollback is limited to
removing or reverting parent coordination changes and prompt artifacts before
durable implementation begins. After implementation, each child owns rollback
for its declared promotion targets.

## Terminal Criteria

Leave the parent `proposal.yml#status` as `accepted`. Do not claim
implemented, closeout-ready, archived, cleanup-complete, or published state
until the lifecycle runner and child-owned evidence prove those states.
