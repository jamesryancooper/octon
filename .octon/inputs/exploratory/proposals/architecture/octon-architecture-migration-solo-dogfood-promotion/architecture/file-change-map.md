# File Change Map

| Surface | RP-14 posture |
| --- | --- |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-solo-dogfood-promotion/**` | Sole direct durable target: `protocol.yml`, expected-old `generation-index.yml`, and immutable run-local inputs, corpus, environment, mission/fault/burden/provider results, metrics, claim map, handoff, manifest, and commit-last completion receipt. |
| Runtime, workflow, CLI, validator, provider config, `.github/**` | Forbidden implementation ownership; failures return to owning child. |
| `support-targets.yml`, admissions/dossiers, HarnessCard, roadmap, release lineage | Downstream promotion-handoff surfaces only; not RP-14 targets or authority. |
| Child evidence roots | Read-only inputs; parent/RP-14 evidence never replaces child receipts. |

There is no target-family split because RP-14 writes only retained `.octon`
evidence. Provider configuration is observed, never mutated.

The exact internal paths and integrity order are selected in
`resources/solo-dogfood-proof-protocol-receipt.yml`. They refine one parent
directory target and do not create additional write scope or runtime authority.
