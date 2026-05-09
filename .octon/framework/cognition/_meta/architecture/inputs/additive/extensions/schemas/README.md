# Additive Extension Input Schemas

| Schema | Canonical artifact |
| --- | --- |
| `extension-pack.schema.json` | `.octon/inputs/additive/extensions/<pack-id>/pack.yml` |
| `extension-routing-contract.schema.json` | `.octon/inputs/additive/extensions/<pack-id>/context/routing.contract.yml` |
| `extension-lifecycle-contract.schema.json` | `.octon/inputs/additive/extensions/<pack-id>/context/lifecycle.contract.yml` |
| `program-lifecycle-event.schema.json` | Program lifecycle `program-events.ndjson` records under execution control and workflow evidence roots |
| `proposal-program-child-registry.schema.json` | `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/patterns/proposal-program.md` and proposal-program `resources/child-packet-index.yml` files |
| `proposal-program-mutation.schema.json` | `octon lifecycle program propose-mutation|apply-mutation --spec <path>` mutation specs |
| `proposal-program-scaffold.schema.json` | `octon lifecycle program scaffold --spec <path>` parent-program scaffold specs |

`octon-extension-pack-v5` requires explicit `capability_profiles` so validation
can fail closed on missing command, skill, prompt, routing, lifecycle,
template, or validation artifacts.
