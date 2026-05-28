# Additive Extension Input Schemas

| Schema | Canonical artifact |
| --- | --- |
| `extension-pack.schema.json` | `.octon/inputs/additive/extensions/<pack-id>/pack.yml` |
| `extension-routing-contract.schema.json` | `.octon/inputs/additive/extensions/<pack-id>/context/routing.contract.yml` |
| `extension-lifecycle-contract.schema.json` | `.octon/inputs/additive/extensions/<pack-id>/context/lifecycle.contract.yml` |
| `lifecycle-human-exception-grant.schema.json` | Typed lifecycle human exception grant context for non-machine-provable boundaries |
| `lifecycle-cancellation.schema.json` | Durable packet/program lifecycle cancellation markers and evidence |
| `lifecycle-run-event.schema.json` | Packet route-progression `lifecycle-events.ndjson` records under execution control and workflow evidence roots |
| `program-lifecycle-event.schema.json` | Program lifecycle `program-events.ndjson` records under execution control and workflow evidence roots |
| `proposal-program-child-registry.schema.json` | `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md` and proposal-program `resources/child-packet-index.yml` files |
| `proposal-program-mutation.schema.json` | `octon lifecycle program propose-mutation|apply-mutation --spec <path>` mutation specs |
| `proposal-program-scaffold.schema.json` | `octon lifecycle program scaffold --spec <path>` parent-program scaffold specs |

`octon-extension-pack-v5` requires explicit `capability_profiles` so validation
can fail closed on missing command, skill, prompt, routing, lifecycle,
template, or validation artifacts.

Naming rules that depend on pack-relative ownership are enforced by extension
pack validators, not by generated projections. Schemas define the wire shape
and safe identifier syntax; validators enforce that command IDs, skill IDs, and
prompt set IDs remain namespaced while runtime route IDs remain local
orchestration contract identifiers.
