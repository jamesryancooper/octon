# Unified Validation and Failure Semantics

This is a temporary, implementation-scoped architecture proposal for
`validation-fail-closed-quarantine-staleness`.
It translates the ratified Packet 14 design packet and the ratified
super-root blueprint into the repository's proposal format.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Define Octon's final class-root-aware validation contract,
  fail-closed runtime and policy protection, scope-local and pack-local
  quarantine behavior, freshness enforcement for runtime-facing effective
  outputs, and the atomic desired/actual/quarantine/compiled publication
  model.

## Promotion Targets

- `.octon/octon.yml`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/instance/extensions.yml`
- `.octon/state/control/extensions/`
- `.octon/state/control/locality/`
- `.octon/state/evidence/validation/`
- `.octon/generated/effective/extensions/`
- `.octon/generated/effective/locality/`
- `.octon/generated/effective/capabilities/`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/octon_packet_14_validation_fail_closed_quarantine_staleness.md`
4. `resources/octon_ratified_architectural_blueprint.md`
5. `navigation/source-of-truth-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`

## Supporting Resources

- `resources/octon_packet_14_validation_fail_closed_quarantine_staleness.md`
  captures the ratified Packet 14 design packet used to draft this proposal.
- `resources/octon_ratified_architectural_blueprint.md` bundles the ratified
  blueprint sections that constrain validation, fail-closed behavior,
  quarantine semantics, generated-output freshness, and migration order.

## Exit Path

Promote the unified validation model, class-root-aware failure boundaries,
scope and pack quarantine control surfaces, freshness and publication
metadata requirements, and retained validation receipt rules into durable
`.octon/` manifests, architecture docs, validators, workflows, and generated
effective schemas, then archive this proposal once canonical runtime and
policy consumers no longer depend on proposal-local failure-semantics
guidance.
