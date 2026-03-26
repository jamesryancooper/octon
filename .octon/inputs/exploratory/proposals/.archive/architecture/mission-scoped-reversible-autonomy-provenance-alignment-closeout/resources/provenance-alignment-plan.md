# Provenance Alignment Plan

## Decision

Treat MSRAOM as **implemented, canonical, and complete** and make the proposal
workspace reflect that state explicitly, as evidenced by
[`implementation-audit.md`](./implementation-audit.md).

The target state is the already-landed `0.6.3` runtime closeout plus one final
repo-side provenance normalization. This packet does not reopen runtime
implementation.

## Required repository state after cutover

### 1. Proposal lineage is normalized
All MSRAOM proposal packets are either:
- archived as historical implementation guidance with explicit archive metadata, or
- explicitly superseded by a later packet that also projects coherently into
  the generated registry

No active proposal should appear to be required for current MSRAOM operation.

### 2. A canonical ADR / decision exists
A durable decision record must state that:
- MSRAOM is complete
- canonical truth now lives in runtime, policy, control, evidence, and summary surfaces
- proposal packets are historical lineage, not operational dependencies
  (the implementation scope and residual traceability gap are documented in
  [`implementation-audit.md`](./implementation-audit.md)).

The matching migration plan and evidence bundle must describe the atomic
promotion transaction that normalized archive state, registry projection, and
navigation.

### 3. Bootstrap and architecture navigation point to canonical truth first
`START.md`, `README.md`, and architecture navigation docs should reference:
- MSRAOM principle
- architecture specification
- runtime-vs-ops contract
- mission-autonomy policy
- ownership registry
- control/evidence/read-model roots

Proposal packets may be linked as historical background, but not as primary current guidance.

### 4. Generated proposal registry is consistent
The generated proposal registry should show:
- current MSRAOM proposal lineage
- superseded/archived state for prior packets
- completion/closeout status reflected accurately
- archived steady-state and final-closeout packets included rather than silently
  omitted

## Explicit no-runtime-delta rule

This packet must not:
- modify runtime code
- modify policy behavior
- modify schemas
- modify control truth
- modify summaries or generated runtime artifacts except where a navigation or registry artifact must be refreshed
- modify CI/runtime enforcement semantics unrelated to proposal discovery

If a change would alter runtime semantics, it is out of scope for this packet.
