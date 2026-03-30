# Phase 5 Adapter Conformance Model

## Host criteria

- `HOST-001`: host signals are projections only and never mint authority
- `HOST-002`: default host path remains replaceable and bounded by engine
  authorization
- `HOST-003`: projected control-plane state never becomes hidden authority
- `HOST-004`: canonical host-family coverage is explicit for GitHub, CI, local
  CLI, and Studio

## Model criteria

- `MODEL-001`: model support claims remain bounded by declared support tiers
- `MODEL-002`: model execution emits runtime receipts and instruction-layer
  manifests
- `MODEL-003`: memory discipline remains runtime-backed rather than
  persona-backed
- `MODEL-004`: model manifests publish conformance suites, contamination/reset
  posture, and known limitations

## Runtime enforcement

- support-target routing now loads the published adapter declarations
- host/model adapter declarations must resolve to valid runtime manifests
- manifest criteria refs must cover the declaration’s criteria refs
- support-tier declarations in manifests must cover the tuple envelopes exposed
  through `support-targets.yml`
- capability-pack admission must agree with both the runtime pack registry and
  the tuple’s `allowed_capability_packs`
- any undeclared host, broken model manifest, or unadmitted pack returns an
  unsupported posture and fails closed before material execution
