# Constitutional Adapter Contracts

`/.octon/framework/constitution/contracts/adapters/**` defines the
constitutional contract family for host adapters, model adapters, and
governed capability packs.

## Wave 5 Status

Wave 5 hardens adapters as explicit, replaceable boundaries.

- host adapters project interaction and host signals into the runtime, but
  they do not mint authority
- model adapters shape model-family integration, but they do not widen support
  beyond declared support targets
- capability packs expose action surfaces only when they are both governed and
  admitted by repo-local support policy
- adapter conformance remains subordinate to
  `/.octon/instance/governance/support-targets.yml`

## Canonical Files

- `family.yml`
- `host-adapter-v1.schema.json`
- `model-adapter-v1.schema.json`
- `adapter-conformance-v1.schema.json`
- `capability-pack-v1.schema.json`

## Runtime Projection Roots

- host adapter manifests:
  `/.octon/framework/engine/runtime/adapters/host/**`
- model adapter manifests:
  `/.octon/framework/engine/runtime/adapters/model/**`
- capability pack contracts:
  `/.octon/framework/capabilities/packs/**`
- repo-local pack admission:
  `/.octon/instance/capabilities/runtime/packs/**`
