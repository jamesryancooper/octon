# Proposal Reading and Precedence Map

## Authority Boundary

Current canonical repository authority outranks this proposal. The intake
controls accepted operator-intent lineage while remaining non-authoritative
pending promotion; the fixed reconciliation controls the RP-13 packet boundary,
engineering refinement, and proof sequence without reopening accepted intent.
A child contract, role, schedule, provider mapping, output, receipt, or terminal
record cannot grant authority, advance mission/run state, publish, or become a
persistent identity.

## External Sources

| Concern | Source | Role |
| --- | --- | --- |
| Authority, isolation, recovery, and Harness | Existing canonical contracts plus RP-08/RP-11 outputs | Supplies frozen guard, isolation, reconciliation, Harness, and generic adapter interfaces. |
| Proposal lifecycle | `.octon/inputs/exploratory/proposals/README.md` and proposal standards | Governs this packet's form and lifecycle. |
| Reconciled child boundary | Reconciliation packet-map entry RP-13 | Controls scope, dependencies, proof, and exclusions. |
| Traceability | FD-022, FD-023 child mapping, RF-031, RF-004/016/025/027, PO-FD-022, PO-FD-023, UE-013, ROD-005, ED-001 premise | Controls accepted decision lineage, engineering configuration, proof, and dependency assumptions; no ROD-005 operator disposition remains open. |
| Current implementation facts | Lifecycle program scheduler/locks/retries, lifecycle executor cancellation/process groups, token ledger, Agent Node, Harness, mission status, and evidence | Establishes reusable primitives and gaps. |

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/traceability.yml`
5. `architecture/target-architecture.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/implementation-plan.md`
8. remaining architecture and navigation documents
9. `README.md`

## Planned Ownership

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Temporary MissionChildRun identity/contract and parent lineage | RP-13 | Never a persistent agent/account or authority source. |
| Scope/depth/budget derivation and admission | RP-13 | Strict intersection only; cannot widen parent or mint grants. |
| One-shot child guard consumption | Existing/RP-11 authority interface consumed by RP-13 | RP-13 binds/verifies exact inputs; authority semantics remain outside RP-13. |
| Isolated candidate repository and non-exportable session | RP-11/RP-08 dependency chain using ED-001/RP-02 premise | RP-13 consumes; cannot redesign sandbox/session/credentials. |
| Scheduling, locks, concurrency, retries, timeout | Existing lifecycle-program scheduler reused by RP-13 | No new scheduler, queue, or persistent worker. |
| Generic executor adapter | RP-11 | RP-13 cannot edit trait/registry/primary generic conformance. |
| Child provider mapping and child conformance | RP-13 | Separate mapping contract/module over RP-11 operations only. |
| Cancel/process group/usage observations | RP-11 generic adapter primitives consumed by RP-13 | RP-13 adds child trigger/identity mapping, not generic mechanics. |
| Unknown-outcome reconciliation and recovery | RP-08 | RP-13 invokes and awaits; does not redefine recovery/store semantics. |
| Terminal retirement/tombstone evidence | RP-13 | Revoke/release child-owned guard/session/task/candidate identity after reconciliation; never delete parent/canonical evidence. |
| Integrated provider equivalence/support proof | RP-14 | Consumes RP-13 specialization receipt; no RP-13 self-promotion. |

## Shared-Code Symbol Boundary

- `kernel/lifecycle_program.rs`: RP-13 may expose/reuse exact scheduler batch,
  lock, retry, cancellation, terminal-observation, and recovery hooks; proposal-
  program `ProgramChild` identity/closeout semantics remain unchanged.
- `kernel/mission_child.rs`: RP-13 exclusively owns `MissionChildRun`, scope and
  budget intersection, admission, scheduler job mapping, cancel/reconcile, and
  terminal retirement orchestration.
- `lifecycle_executor/child.rs`: RP-13 exclusively owns child contract to RP-11
  generic `prepare/launch/observe/cancel/usage/retire` mapping and child-specific
  outcome checks.
- `lifecycle_executor/child_codex.rs`: RP-13 owns only the conditionally admitted
  primary-provider child API mapping; it cannot redefine `codex.rs` or the
  generic adapter.
- `lifecycle_executor/lib.rs`: one child-module export only.
- `lifecycle_executor/token_budget.rs`: child hard/measurement posture fields
  and evidence only; token ledger remains non-authoritative.
- `kernel/commands/mission.rs` and `main.rs`: fold child status/cancellation into
  existing mission surfaces; no normal child administration command family.

Any required change to authority predicates, one-shot guard semantics,
canonical runtime store transitions, recovery truth, generic adapter trait, or
candidate isolation is a blocker requiring the owning packet to revise first.

## Derived and Operational Surfaces

- child run control records live under the existing parent/mission run control
  model and are temporary runtime truth, not agent accounts;
- child outputs remain candidate artifacts until the parent reconciler accepts
  them;
- child evidence, usage, cancellation, unknown, and retirement receipts prove
  outcomes but cannot advance mission/run state;
- generated child/mission status views are projections; and
- `.octon/generated/proposals/registry.yml` remains a discovery projection and
  is intentionally not edited during child authoring.

## Conflict Rule

Any mismatch among parent, mission, project, Harness, guard, isolation,
provider mapping, scope, budget, depth, cancellation, or terminal identity
fails child admission/continuation closed. The child cannot repair or override
the conflict, recruit another child, or fall back to credentials or a broader
session.
