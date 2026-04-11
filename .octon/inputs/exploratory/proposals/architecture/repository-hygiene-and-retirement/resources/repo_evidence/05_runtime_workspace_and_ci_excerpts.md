# Repo Evidence 05 — Runtime Workspace and CI Excerpts

## Runtime workspace

**Source:** `/.octon/framework/engine/runtime/crates/Cargo.toml`

- workspace members include:
  - `core`
  - `authority_engine`
  - `wasm_host`
  - `kernel`
  - `studio`
  - `assurance_tools`
  - `policy_engine`
  - `replay_store`
  - `telemetry_sink`
  - `runtime_bus`

This is why a Rust-native detector stack is required.

## Existing workflow facts that matter

**Source:** `/.github/workflows/architecture-conformance.yml`

- the workflow already installs `yq`
- it already runs architecture and build-to-delete validation jobs
- it already watches governance, assurance, state/evidence, generated, and
  workflow surfaces

**Source:** `/.github/workflows/closure-certification.yml`

- the workflow is already `workflow_dispatch` capable
- both passes already install `jq` and `yq`
- both passes already assert a broad closure bundle rather than a single
  lightweight lint

## Implication for this packet

Repo hygiene can be added as a bounded extension to existing validation and
closure flows. It does not require a new CI platform, a different language
ecosystem, or a new authority model.
