# File Change Map

## Implementation status

Reviewed on 2026-04-24. Run Lifecycle v1 enforcement has been implemented in
durable runtime, spec, assurance, lab, and retained validation surfaces outside
this packet. This file is a proposal-local closure map only; it is not runtime,
policy, assurance, evidence, governance, or generated authority.

## Primary durable promotion targets

| Path | Planned change type | Observed status | Purpose |
|---|---|---|---|
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | refine | implemented | Adds machine-readable transition/reconstruction contract links, journal-derived transition rules, drift blocking, and control/evidence boundary requirements. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-transition-v1.schema.json` | add | implemented | Machine-readable transition request/outcome/provenance contract. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-reconstruction-v1.schema.json` | add | implemented | Machine-readable reconstruction, drift, closeout, and source-boundary report contract. |
| `.octon/framework/engine/runtime/spec/run-journal-v1.md` | refine | implemented | Binds lifecycle transitions to canonical event refs, reconstruction roles, and append-only runtime bus events. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | refine | implemented | Clarifies control/evidence separation and journal snapshot hash-match posture at closeout. |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | refine | implemented | Requires generated lifecycle summaries to derive from journal reconstruction and marks drifted summaries stale/withheld. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs` | export | implemented | Exports lifecycle validation operation and reconstruction surfaces. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs` | implement/refactor | implemented | Adds lifecycle states, operation validation, journal reconstruction, drift detection, transition gating, required-ref checks, closeout completeness checks, and runtime-state write protection. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | implement/refactor | implemented | Routes authority resolution, start/finalize/closeout events, snapshot refs, review/risk disposition materialization, evidence-store completeness, and runtime-state updates through validated journal-derived lifecycle state. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs` | implement/refactor | implemented | Requires material effect consumption to pass lifecycle-state validation and appends effect-token events through the validated journal path. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/phases/receipt.rs` | refine | implemented | Carries authorize-generated Context Pack Builder v1 binding refs into execution request/receipt payloads when callers did not supply a binding. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs` | update | implemented | Adds lifecycle operation validation for run start, inspect, resume, checkpoint, close, replay, and disclose commands. |
| `.octon/framework/engine/runtime/crates/kernel/src/run_binding.rs` | update | implemented | Validates existing run bindings against lifecycle reconstruction before re-materializing runtime state. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs` | implement/refactor | implemented | Enforces Run Lifecycle v1 on the raw canonical journal append path, rejects unknown states, illegal transitions, post-closed appends, fake/incomplete closeout refs, non-stage-only staged routing, and relative or absolute generated/input authority refs. |
| `.octon/framework/assurance/functional/suites/run-lifecycle-integrity.yml` | refine | implemented | Points the proof suite at the Run Lifecycle v1 validator and declares lifecycle-specific required artifacts. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh` | add | implemented | Validator for transition matrix coverage, journal-derived state, fail-closed negative controls, boundary composition, closeout completeness, append-boundary coverage, and idempotent retained report writing. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-append-boundary.sh` | add | implemented | Static guard that fails if active durable framework/instance/state/generated surfaces directly write canonical control run journals outside runtime_bus. |
| `.octon/framework/assurance/runtime/_ops/tests/test-run-lifecycle-v1.sh` | add | implemented | Regression harness for fixture pass/fail behavior, runtime-state drift mutation, and closeout evidence mutation. |
| `.octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/**` | add | implemented | Positive and negative fixture cases plus transition matrix, including raw-bypass controls for fake closeout refs, unresolved risk, absolute generated refs, non-stage-only staged routing, and unknown lifecycle states. |
| `.octon/framework/assurance/governance/_ops/scripts/normalize-uec-packet-certification-runs.sh` | refine | implemented | Converts the active UEC certification normalizer into a read-only verifier for runtime-owned journals and auxiliary evidence, failing closed instead of repairing tracked artifacts. |
| `.octon/framework/assurance/governance/_ops/scripts/run-uec-packet-certification-pass.sh` | refine | implemented | Renames the first certification step to verify run journals and auxiliary evidence rather than normalize canonical journals. |
| `.octon/instance/assurance/runtime/run-lifecycle-v1.yml` | add | implemented | Instance assurance registration that points to the durable framework validator, fixtures, lab scenario, and retained evidence without making this proposal path authoritative. |
| `.octon/framework/lab/scenarios/registry.yml` | refine | implemented | Registers the lifecycle boundary-composition scenario. |
| `.octon/framework/lab/scenarios/packs/run-lifecycle-v1-boundary-composition.yml` | add | implemented | Lab scenario covering control roots, retained evidence roots, disclosure roots, and generated non-authority read models. |
| `.octon/state/evidence/validation/assurance/run-lifecycle-v1/**` | retained evidence | implemented | Retained validation reports showing validator pass and positive/negative case coverage. |

## Planned targets resolved without file changes

| Path family | Closure disposition |
|---|---|
| `.octon/framework/engine/runtime/crates/core/**` | No code change required; lifecycle domain logic landed in `authority_engine` and `runtime_bus`. |
| `.octon/framework/engine/runtime/run`, `.octon/framework/engine/runtime/run.cmd` | No wrapper change required; CLI validation landed in `kernel/src/commands/mod.rs`. |

## Non-targets

| Path family | Reason excluded |
|---|---|
| `.octon/generated/**` | Derived views may update after implementation but must not be authored promotion targets. |
| `.octon/inputs/exploratory/proposals/**` | This packet remains temporary lineage only. |
| `.octon/instance/governance/support-targets.yml` | No support expansion is required; lifecycle proof should satisfy existing requirements. |
| Browser/API/frontier adapter manifests | Not implicated by the narrow lifecycle enforcement step. |
