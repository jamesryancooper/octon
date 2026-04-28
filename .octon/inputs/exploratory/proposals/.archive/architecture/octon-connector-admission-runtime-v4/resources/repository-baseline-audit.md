# Repository Baseline Audit

## Proposal standards

The live repo defines proposal packets as non-canonical artifacts under `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`. `proposal.yml` and exactly one subtype manifest are lifecycle authorities for the packet only. Active architecture proposals require `architecture-proposal.yml`, `architecture/target-architecture.md`, `architecture/acceptance-criteria.md`, and `architecture/implementation-plan.md`.

## Authority model

The live architecture specification defines:
- `framework/**` and `instance/**` as durable authored authority;
- `state/control/**` as mutable operational truth;
- `state/evidence/**` as retained factual proof;
- `state/continuity/**` as resumable context, not authority;
- `generated/**` as derived and never authority;
- `inputs/**` as non-authoritative proposal/raw input lineage.

## Support target baseline

`instance/governance/support-targets.yml` uses:
- `default_route: deny`;
- `support_claim_mode: bounded-admitted-finite`;
- live capability packs: `repo`, `git`, `shell`, `telemetry`;
- non-live/resolved surfaces: `browser`, `api`;
- proof bundle roots, support dossiers, support cards, support admissions, and generated support matrix rules that forbid generated widening.

## Capability packs

`instance/governance/capability-packs/registry.yml` includes `repo`, `git`, `shell`, `telemetry`, `browser`, and `api`. Connector operations must map into those packs rather than making MCP a giant pack.

## Authorization and material effects

`execution-authorization-v1.md` requires all material execution to pass through `authorize_execution(request) -> GrantBundle`, and material APIs must consume typed `AuthorizedEffect<T>` values that verify into `VerifiedEffect<T>` before mutation. The material side-effect inventory includes service invocation, protected CI, executor launch, repo mutation, control/evidence mutation, generated-effective publication, extension activation, and capability-pack activation.

## Campaign baseline

Campaigns are explicitly optional/deferred coordination objects. They are not execution containers and must not become a second mission system. This v4 step preserves campaigns as deferred/non-required.

## Watcher/automation baseline

Watcher routing hints are recommendations, not authorization grants. Automations should replay through new routing context and not treat automation-local counters as run truth. This supports the connector design: event or routing surfaces cannot authorize tool execution.
