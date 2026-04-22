# Current Repo State Audit

## Summary

The live Octon repo is already a serious constitutional engineering harness, not a generic agent memo.
The current structure contains a real super-root, authored authority classes, generated/effective
publication classes, runtime specs, Rust runtime code, support-target declarations, pack admissions,
extension lifecycle state, proof bundles, and proposal-packet standards.

## Strong current-state evidence

- `/.octon/README.md` declares `.octon/` as the single authoritative super-root and states that only
  `framework/**` and `instance/**` are authored authority. It also states that `generated/**` never
  mints authority and `inputs/**` never becomes a direct runtime or policy dependency.
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` is the machine-readable
  topology, authority, publication, and doc-target registry.
- `/.octon/framework/cognition/_meta/architecture/specification.md` is the human-readable companion
  and explicitly says the registry owns topology, authority families, publication metadata, and doc targets.
- `/.octon/octon.yml` is root-manifest v2 with profiles, raw-input and generated-staleness policy,
  generated commit defaults, runtime input bindings, mission roots, support roots, and execution-governance defaults.
- `/.octon/instance/ingress/manifest.yml` owns mandatory reads, optional orientation, adapter parity,
  closeout workflow pointer, profile rule, and human-led blocked roots.
- `/.octon/framework/constitution/CHARTER.md` declares Octon a Constitutional Engineering Harness with
  a Governed Agent Runtime and a bounded admitted finite support universe.
- `/.octon/framework/constitution/obligations/fail-closed.yml` contains active fail-closed obligations
  for raw input dependencies, generated-as-authority, host UI/chat authority, stale manifests, missing
  support targets, missing run contracts, missing evidence, missing proof bundles, and unsupported claims.
- `/.octon/framework/constitution/obligations/evidence.yml` contains active retained evidence obligations
  for runs, control mutations, publication receipts, RunCards, HarnessCards, support claims, generated read
  model freshness, and closure-grade proof.
- `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` defines the engine-owned boundary
  `authorize_execution(request: ExecutionRequest) -> GrantBundle` for material execution.
- `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json` requires support tuple,
  capability packs, context pack, risk/materiality, rollback plan, execution role, side-effect flags,
  and autonomy context for autonomous work.
- `/.octon/framework/engine/runtime/crates/kernel/src/main.rs` exposes run-first lifecycle commands,
  workflow compatibility wrapper, doctor architecture, service commands, replay, disclosure, closeout,
  and orchestration inspection.
- `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` contains
  nontrivial enforcement for policy mode, executor profile, write scope, run binding, support tier,
  approval, rollback, budget, egress, decisions, stage attempts, and evidence refs.
- `/.octon/instance/governance/support-targets.yml` declares a bounded support universe, tuple admissions,
  claim effects, support proof roots, support-card roots, supported and non-live surfaces.
- `/.octon/instance/governance/support-target-admissions/*.yml`, `support-dossiers/*/dossier.yml`, proof
  bundles, and generated support cards establish support-proof architecture.
- `/.octon/framework/capabilities/packs/README.md` correctly positions framework pack contracts above
  tools/skills/services, with repo-local governance intent and runtime admission projections.
- `/.octon/instance/extensions.yml`, `state/control/extensions/active.yml`, `quarantine.yml`, and
  `generated/effective/extensions/**` define desired/active/quarantine/published extension lifecycle.

## Material gaps observed

1. **Runtime-resolution concentration**: `octon.yml` is useful but carries dense runtime and execution
   coordination load that should be delegated for 10/10 quality.
2. **Freshness enforcement gap**: freshness contracts and validators exist, but target-state quality requires
   runtime hard gates for every generated/effective read.
3. **Support-path normalization gap**: support targets and proof bundles refer to partitioned `live/` paths,
   while current visible admissions/dossiers are flat; this is a credibility and validation risk.
4. **Pack-layer duplication**: framework contract, governance pack, and instance runtime pack projection
   are useful but too duplicative; runtime routes should compile into generated/effective outputs.
5. **Extension active-state bulk**: active state includes large repeated required inputs and dependency closure;
   target state should compact active state and move expansion to locks/maps.
6. **Operator legibility gap**: the architecture is internally coherent but still requires registry archaeology.
7. **Proof maturity gap**: proof-plane design is strong, but closure-grade maturity requires continuously
   regenerated proof and negative-control evidence.
