# Source Of Truth Map

## Runtime / governance truth

The following remain the authoritative MSRAOM sources:

- `.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/instance/governance/policies/mission-autonomy.yml`
- `.octon/instance/governance/ownership/registry.yml`
- `.octon/state/control/execution/**`
- `.octon/state/evidence/control/**`
- `.octon/state/evidence/runs/**`
- `.octon/generated/effective/**`
- `.octon/generated/cognition/**`

## Historical lineage only

The proposal workspace is not authoritative for runtime behavior after MSRAOM closeout.
Proposal packets become historical lineage only.

## Canonical closure statement

The ADR / decision record under `instance/cognition/decisions/**` becomes the
repo-native closure statement that MSRAOM is complete and that proposal lineage
is historical.

The matching migration plan and evidence bundle under
`instance/cognition/context/shared/migrations/**` and
`state/evidence/migration/**` become the canonical execution record for this
provenance-alignment promotion.

This packet is scoped from that posture:
[`resources/implementation-audit.md`](../resources/implementation-audit.md)
establishes runtime completeness and identifies proposal/ADR provenance cleanup as
the remaining non-runtime task.

## Proposal discovery

`generated/proposals/registry.yml` is a committed discovery projection, not a
proposal-lifecycle authority. After closeout it should project:

- archived MSRAOM proposal packets from `inputs/exploratory/proposals/.archive/**`
- the current implementing packet only until the final archival transaction
- no active MSRAOM implementation dependency after promotion
