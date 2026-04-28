# Implementation Report

## Status

Implemented in the durable repository surfaces on 2026-04-28.

The proposal packet remains non-authoritative lineage under `inputs/**`; the promoted authority lives under `framework/**`, `instance/**`, and `state/**`. Derived `generated/**` connector projections are read models only.

## Promoted Durable Surfaces

- Runtime and constitutional connector contracts:
  - `framework/engine/runtime/spec/connector-*.schema.json`
  - `framework/constitution/contracts/adapters/connector-*.schema.json`
  - `framework/constitution/contracts/runtime/connector-*.schema.json`
  - `framework/constitution/contracts/assurance/connector-*.schema.json`
  - `framework/constitution/contracts/authority/connector-aware-decision-request-v1.schema.json`
- Runtime/CLI command surface:
  - `octon connector list|inspect|status|validate|admit|stage|quarantine|retire|dossier|evidence|drift|decision`
  - `octon support proof connector`
  - `octon support validate-connector`
  - `octon capability map-connector`
- Repo-local connector authority:
  - `instance/governance/connectors/mcp/**`
  - `instance/governance/connector-admissions/mcp/observe-context/admission.yml`
  - connector admission, credential, data-boundary, and evidence-profile policies
- Operational truth and retained proof:
  - `state/control/connectors/mcp/**`
  - `state/evidence/connectors/mcp/**`
  - `state/evidence/disclosure/connectors/mcp-observe-context.yml`
  - `state/continuity/connectors/mcp/summary.yml`
- Derived read models only:
  - `generated/cognition/projections/materialized/connectors/**`

## Implemented Boundaries

Connector identity, operation contracts, admissions, trust dossiers, support proof maps, capability maps, drift records, quarantine state, and generated connector views do not authorize execution.

The only admitted sample operation is `mcp/observe-context`, and it is stage-only/non-live. Broad MCP/API/browser execution, deployment automation, credential provisioning, destructive external operations, cross-repo execution, and autonomous support-target widening remain deferred.

Material connector execution remains bound to governed run contracts, context packs, execution authorization, authorized-effect token verification, run journal events, connector receipts, retained run evidence, rollback/compensation posture, and disclosure. V4 defines these receipt requirements but does not admit a live material connector operation.

## Validation

Added focused validation:

- `framework/assurance/runtime/_ops/scripts/validate-connector-admission-runtime-v4.sh`
- `framework/assurance/runtime/_ops/tests/test-connector-admission-runtime-v4.sh`

The validator covers contract presence, root placement, operation/admission/dossier completeness, capability mapping, material-effect classification, credential/data/egress posture, evidence roots, drift digest, quarantine reset requirements, generated non-authority, CLI/runtime non-execution, and overlay/architecture registration.

Negative controls cover missing material-effect classification, disallowed admission modes, live-effect authorization, generated support widening, placeholder drift digest, and active-quarantine/status mismatch.

## Deferred Scope

- Broad effectful MCP support.
- Arbitrary external API writes.
- Browser-driving autonomy.
- Deployment/release automation.
- Self-provisioned credentials.
- Destructive external operations.
- Multi-organization federation.
- Autonomous support-target widening.
- General plugin marketplace behavior.
