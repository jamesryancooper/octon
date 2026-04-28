# Executable Implementation Prompt

Act as a senior Octon implementation orchestrator, governed-runtime architect, connector/capability governance engineer, Rust/runtime engineer, and constitutional authority auditor.

Implement the proposal packet `octon-connector-admission-runtime-v4` as a single coordinated migration.

## Objective

Implement Connector Admission Runtime + Connector Trust Dossier v4.

## Must add or standardize

- Connector Operation contract.
- Connector Admission contract.
- Connector Trust Dossier contract.
- Connector Execution Receipt contract.
- Repo-specific connector registry/admissions.
- Connector control/evidence roots.
- CLI/runtime posture commands:
  - `octon connector inspect`
  - `octon connector list`
  - `octon connector status`
  - `octon connector validate`
  - `octon connector admit --stage-only`
  - `octon connector admit --read-only`
  - `octon connector quarantine`
  - `octon connector retire`
  - `octon connector evidence`
- Validators for capability-pack mapping, material-effect mapping, support posture, evidence, and generated no-widening.
- Fail-closed runtime checks preventing material connector execution outside run contract/context-pack/authorization/verified-effect path.

## Do not implement

- broad effectful MCP support;
- browser-driving autonomy;
- production deployment automation;
- credential self-provisioning;
- campaign promotion runtime;
- cross-repo portfolio runtime;
- general plugin marketplace.

## Non-negotiables

- Connectors do not replace capability packs.
- MCP is not a giant capability pack.
- Connector admission does not authorize material execution.
- Material connector invocation requires execution authorization and verified effect tokens.
- Generated projections are not authority.
- Support-target claims cannot widen through generated support matrix/cards.
- Proposal paths are not runtime dependencies.

## Validation

Run the full existing validation suite and add connector-specific tests for negative bypass, generated no-widening, unknown capability pack, unknown material-effect class, missing trust dossier, missing egress/credential posture, and stage-only material invocation denial.

Produce a final implementation report grouped by root.
