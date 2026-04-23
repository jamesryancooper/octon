# Repository Baseline Audit

## Baseline summary

Octon’s current repository state is favorable for this proposal. The architecture already contains the relevant contracts, class roots, runtime implementation crates, governance policies, fail-closed obligations, support-target declarations, and assurance surfaces. The gap is not lack of architectural identity; it is incomplete enforcement depth.

## Relevant current surfaces

### Proposal system

`/.octon/inputs/exploratory/proposals/README.md` requires each manifest-governed proposal to include `proposal.yml`, exactly one subtype manifest, `README.md`, `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`, and optional support material. It also states proposals are non-canonical and excluded from runtime and policy resolution.

### Class roots

The umbrella specification defines the only class roots as `framework/`, `instance/`, `state/`, `generated/`, and `inputs/`. It states durable authored authority may live only under `framework/**` and `instance/**`, state is operational truth, generated is rebuildable and never mints authority, and proposal packets remain lineage-only.

### Authorization

`execution-authorization-v1.md` declares all material execution must pass through `authorize_execution(request: ExecutionRequest) -> GrantBundle`, and that no material side effect may occur before a valid grant exists. It names service invocation, workflow-stage execution, executor launch, repo mutation, publication, protected CI checks, and durable side effects as material paths.

### Authorized effect token

`authorized-effect-token-v1.md` already defines typed authorization product requirements and says side-effecting runtime APIs must consume typed effect tokens derived from the authorization boundary instead of relying on ambient grants or raw path inputs.

### Boundary coverage

`authorization-boundary-coverage-v1.md` requires every material path to bind a stable path id, owning module/script/workflow, side-effect class, affected root, authorization binding point, support posture, capability-pack posture, approval posture, rollback posture, negative-path test, and retained evidence. It says uncovered paths are unsupported and must fail closed.

### Runtime implementation

The runtime README describes `crates/authority_engine/src/implementation.rs` as the authority surface facade and describes modules for API types, records, runtime state, support routing, authority artifacts, policy, and execution orchestration. The runtime crate tree includes `authorized_effects`, `authority_engine`, `core`, `runtime_bus`, `replay_store`, and related crates.

### Support targets

`support-targets.yml` declares a bounded-admitted-finite support posture. Live support includes repo-local governed model class, observe/read and repo-consequential workload classes, reference-owned context, English primary locale, repo-shell and CI-control-plane host adapters, and repo/git/shell/telemetry capability packs. Browser/API/frontier/studio/github-control-plane surfaces are stage-only or non-live.

### Fail-closed obligations

Fail-closed obligations include missing approval/grant evidence, missing instruction-layer manifests, invalid support target, missing bound run contract, missing evidence, adapter authority bypass, generated authority, unsupported support claims, and inability to prove authorization-boundary coverage.

## Baseline conclusion

Octon already points directly at Authorized Effect Token enforcement. This packet should strengthen, not replace, existing surfaces.
