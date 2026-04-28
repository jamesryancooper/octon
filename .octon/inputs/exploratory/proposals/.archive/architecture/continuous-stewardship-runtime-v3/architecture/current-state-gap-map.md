# Current-State Gap Map

## Current Live Repository State

The live repository already has the constitutional super-root and root class
model: authored authority under `framework/**` and `instance/**`; mutable control,
evidence, and continuity under `state/**`; generated projections under
`generated/**`; and non-authoritative input/proposal lineage under `inputs/**`.
The umbrella architecture specification states that missions are continuity
containers and consequential run control belongs under
`state/control/execution/runs/**`.

The repository also contains mission contracts and practices:

- `framework/engine/runtime/spec/mission-charter-v2.schema.json`
- `framework/engine/runtime/spec/mission-control-lease-v1.schema.json`
- `framework/engine/runtime/spec/autonomy-budget-v1.schema.json`
- `framework/engine/runtime/spec/circuit-breaker-v1.schema.json`
- `framework/engine/runtime/spec/action-slice-v1.schema.json`
- `framework/orchestration/runtime/missions/README.md`
- `framework/orchestration/practices/mission-lifecycle-standards.md`

Campaigns are explicitly deferred. The live campaign promotion criteria say
campaigns are optional coordination objects, not execution containers or a second
mission system.

## Assumed v1 Baseline

This v3 packet assumes v1 has introduced Engagement, Project Profile, Work
Package, Decision Request, Evidence Profile, Preflight Evidence Lane,
stage-only Tool/MCP Connector Posture, and first run-contract candidate
generation. If these are not present at implementation time, v3 must add only
minimal compatibility shims and must not reimplement the whole v1 compiler.

## Assumed v2 Baseline

This v3 packet assumes v2 has introduced Autonomy Window, Mission Runner,
Mission Queue, Action Slice handling, Continuation Decisions, Mission Run Ledger,
Mission Evidence Profiles, mission-aware Decision Requests, limited connector
admission hooks, and bounded multi-run continuation under mission lease, budget,
breakers, support/capability/context/rollback/evidence gates. If these are not
present, v3 implementation must document the dependency and provide only minimal
handoff stubs.

## Missing v3 Capability

Octon currently lacks a canonical stewardship layer that can remain available
over time without starting an unbounded agent loop. The missing capabilities are:

1. Stewardship Program authority.
2. Finite Stewardship Epoch control.
3. Normalized event/trigger ingestion.
4. Stewardship Admission Decisions.
5. Idle Decision semantics.
6. Renewal Decisions.
7. Stewardship Ledger.
8. Stewardship-level evidence profiles and retained evidence roots.
9. Stewardship-aware Decision Requests.
10. Runtime/CLI stewardship commands.
11. Explicit campaign coordination hooks that preserve campaign deferment.
12. Anti-infinite-loop validation and progress gates.

## Why v3 Is Needed

V2 makes one mission safe to continue. It does not define how Octon remains
available after missions close, how repeated reviews are bounded, how idle is
represented, how recurring events are admitted or rejected, or how renewal occurs
without silently widening authority.
