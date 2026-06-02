# Token-Efficient Proposal Program Controller

This is a non-authoritative Octon architecture proposal program under `/.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/`.

It coordinates child proposal packets for a **Token-Efficient Proposal Program Controller** layered on Octon's existing governed runtime. The program addresses token waste evidenced by completed proposal-program lifecycle runs, especially `lifecycle-proposal-program-1780379179921-9bb1eb22`.

## Purpose

Reduce total runtime token consumption across proposal-program parent and child lifecycle runs without weakening governance, evidence, replay, rollback, support proof, or implementation quality.

## Grounding

The program is grounded in existing Octon surfaces:

- proposal workspace rules under `/.octon/inputs/exploratory/proposals/README.md`;
- proposal standard and architecture proposal standard under `/.octon/framework/scaffolding/governance/patterns/`;
- Context Pack Builder v1 under `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`;
- Run Lifecycle v1 under `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`;
- lifecycle executor prompt bundle rendering in `/.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`;
- prompt asset resolution in `/.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`;
- proposal-program runner surfaces in `/.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`;
- closeout, publication freshness, validation, generated/read-model, and lifecycle contract surfaces under declared child promotion targets.

## Program Shape

This parent packet coordinates 12 child packets. The child boundaries preserve governance for runtime workflow safety, closeout/change handoff governance, promotion evidence binding, archive observation/recovery, terminal integration tests, authority-affecting architecture changes, and mature cache/index work.

Deterministic or compact preflight behavior is preferred for publication freshness, generated registry freshness, run-health manifests, blocker aggregation when zero blockers exist, dependency vectors, child manifest completeness, registry projection validation, raw-log indexing, closeout schema validation, worktree classification, and parent-review churn detection when digest comparison is sufficient.

## Non-Authority Statement

This packet and all child packets are proposal inputs. They are temporary implementation aids. They do not authorize execution, do not replace framework/instance authority, do not satisfy lifecycle gates, do not replace retained evidence, do not replace generated freshness validators, and do not become runtime source of truth.

## Core Invariants

- Octon remains a Constitutional Engineering Harness.
- The single authoritative super-root remains `/.octon/`.
- Authored framework/instance authority remains separated from raw inputs, operational state, generated outputs, and retained evidence.
- Raw proposal inputs and generated/read-model artifacts must not become runtime authority.
- Agents must not bypass the engine-owned authorization boundary.
- Deny-by-default governance, ACP gates, reversibility, evidence receipts, replayability, rollback posture, and support-proof requirements remain mandatory.

## Review Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/child-packet-index.yml`
4. `architecture/target-architecture.md`
5. `architecture/context-pack-policy.md`
6. `architecture/model-routing-policy.md`
7. `architecture/token-budget-policy.md`
8. `architecture/evidence-and-replay-model.md`
9. `architecture/implementation-plan.md`
10. child proposal packets
11. support receipts
