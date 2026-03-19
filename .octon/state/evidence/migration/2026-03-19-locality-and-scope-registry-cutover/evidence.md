# Locality And Scope Registry Cutover Evidence (2026-03-19)

## Scope

Single-promotion atomic migration implementing Packet 6
`locality-and-scope-registry`:

- turn locality into one root-owned scope registry under `instance/locality/**`
- add canonical per-scope manifests plus one live repo scope
- add compiled effective locality outputs and mutable locality quarantine
  state
- harden validators, harness gates, scaffolding, and CI to the Packet 6
  locality contract
- record Packet 6 governance evidence in the repo’s migration and ADR ledgers

## Cutover Assertions

- `instance/locality/**` is now the only authored locality authority surface.
- `generated/effective/locality/**` is now the compiled runtime-facing
  locality publication surface.
- `state/control/locality/quarantine.yml` is now the mutable locality
  quarantine surface.
- The live repo now includes a real authored scope manifest.
- `nearest-registry-wins` locality semantics are removed from the active
  agency contract and scaffolding.
- The harness alignment profile passes with Packet 6 locality checks enabled.

## Receipts and Evidence

- Proposal:
  `/.octon/inputs/exploratory/proposals/architecture/6-locality-and-scope-registry/`
- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-19-locality-and-scope-registry-cutover/plan.md`
- ADR:
  `/.octon/instance/cognition/decisions/050-locality-and-scope-registry-atomic-cutover.md`

No `path-map.json` is included because this cutover hardens and adds canonical
Packet 6 surfaces in place rather than moving one retired tracked authority
tree to another.
