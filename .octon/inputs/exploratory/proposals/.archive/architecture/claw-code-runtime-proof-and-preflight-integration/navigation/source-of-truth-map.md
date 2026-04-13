# Source of Truth Map

## Packet-local truth hierarchy

This packet is **non-authoritative exploratory lineage**. Within the packet, use this
ordering for packet interpretation:

1. `proposal.yml` — packet identity, scope, promotion targets, artifact inventory
2. `architecture-proposal.yml` — packet-level coverage summary, non-negotiables, implementation motion
3. `architecture/concept-coverage-matrix.md` — canonical packet-local concept coverage table
4. `architecture/target-architecture.md` — target-state integration shape
5. `architecture/file-change-map.md` — exact durable targets and change classes
6. `architecture/implementation-plan.md` — phased implementation motion
7. `architecture/acceptance-criteria.md` — concept-level closure tests
8. `architecture/closure-certification-plan.md` — packet-level closure proof requirements
9. `resources/full-concept-integration-assessment.md` — detailed concept dossiers
10. `resources/coverage-traceability-matrix.md` — end-to-end source -> extraction -> verification -> repo -> proposal traceability

## External authoritative inputs

The actual implementation truth lives outside this packet and is governed by live Octon
authority/control/evidence surfaces, primarily:

- `/.octon/framework/constitution/**`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/octon.yml`
- `/.octon/framework/manifest.yml`
- `/.octon/instance/manifest.yml`
- `/.octon/framework/engine/runtime/adapters/host/repo-shell.yml`
- `/.octon/framework/lab/scenarios/**`
- `/.octon/framework/observability/governance/**`
- `/.octon/instance/bootstrap/**`
- `/.octon/framework/orchestration/runtime/workflows/**`
- `/.octon/instance/governance/policies/**`
- `/.octon/state/control/**`
- `/.octon/state/evidence/**`
- `/.octon/generated/cognition/**`

## Proposal-local navigation rule

This packet follows the current super-root proposal reading-order rule called out in
`/.octon/README.md`: proposal-local reading should begin with a source-of-truth map,
then move through working docs and the artifact catalog, while promotion targets stay
outside the proposal tree.
