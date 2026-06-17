# Architecture Conformance Blockers

`validate-architecture-conformance.sh` failed after the durable implementation.

Blocking causes observed:

- `validate-support-envelope-reconciliation.sh`: published support-envelope reconciliation is stale.
- `validate-run-health-read-model.sh`: generated run-health projections under `.octon/generated/cognition/projections/materialized/runs/**/health.yml` contain stale `runtime_route_bundle` and `pack_routes` digests after capability pack manifest changes. The direct validator reported `errors=1057` across 528 health files and no valid health file for its negative controls.

No generated output was edited during this implementation because `.octon/generated/**` is not an accepted promotion target for this packet. Closeout should remain blocked until the owning publication/read-model refresh route is run or the proposal manifest is revised through lifecycle review to authorize generated-output refresh.
