# Framework Core Architecture Cutover Evidence (2026-03-18)

## Scope

Single-promotion clean-break migration implementing Packet 3
`framework-core-architecture`:

- remove framework-local `_ops/state/**` from live framework authority surfaces
- rehome preserved control state, retained evidence, and generated artifacts
  into canonical `state/**` and `generated/**` roots
- reclassify portable service policy support data into framework governance
- wire new overlay and framework-boundary validators into the harness gate
- update runtime consumers, docs, and templates to the new Packet 3 path
  contract

## Cutover Assertions

- `framework/**` now contains portable authored core and portable helper assets
  only.
- No live `framework/**/_ops/state/**` path remains on disk.
- Framework companion metadata and overlay registry remain authoritative and are
  validator-enforced.
- Engine, capability, service, skill, and assurance runtime consumers resolve
  only to the new `instance/**`, `state/**`, and `generated/**` homes.
- The harness gate now fails closed on any reintroduction of framework-local
  state roots or undeclared overlay validator drift.

## Receipts and Evidence

- Proposal: `/.octon/inputs/exploratory/proposals/architecture/framework-core-architecture/`
- Path map: `path-map.json`
- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
