# File Change Map

## Portable framework targets

| Path | Change |
| --- | --- |
| `.octon/framework/engine/runtime/spec/connector-operation-v1.schema.json` | New schema for operation contracts. |
| `.octon/framework/engine/runtime/spec/connector-admission-v1.schema.json` | New schema for admission mode, support posture, and governance status. |
| `.octon/framework/engine/runtime/spec/connector-trust-dossier-v1.schema.json` | New schema for operation-level proof dossier. |
| `.octon/framework/engine/runtime/spec/connector-execution-receipt-v1.schema.json` | New schema for future run-bound material connector invocation receipts. |
| `.octon/framework/orchestration/practices/connector-admission-standards.md` | New operating standard. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-connector-admission-runtime-v4.sh` | New validator. |
| `.octon/framework/assurance/runtime/_ops/tests/test-connector-admission-runtime-v4.sh` | New coverage test and negative-control suite. |

## Repo-specific authored authority

| Path | Change |
| --- | --- |
| `.octon/instance/governance/connectors/registry.yml` | New repo-specific connector registry. |
| `.octon/instance/governance/connectors/<connector-id>/connector.yml` | Connector identity and posture. |
| `.octon/instance/governance/connectors/<connector-id>/operations/<operation-id>.yml` | Operation contract instance. |
| `.octon/instance/governance/connector-admissions/<connector-id>/<operation-id>.yml` | Admission mode and support status. |
| `.octon/instance/governance/support-targets.yml` | Reference connector admission roots; no automatic live widening. |

## Control roots

| Path | Change |
| --- | --- |
| `.octon/state/control/connectors/<connector-id>/status.yml` | Mutable connector status. |
| `.octon/state/control/connectors/<connector-id>/operations/<operation-id>/status.yml` | Mutable operation status/admission state. |
| `.octon/state/control/execution/approvals/requests/**` | Existing roots used for connector Decision Requests. |
| `.octon/state/control/execution/revocations/**` | Existing roots used for connector revocations. |

## Evidence roots

| Path | Change |
| --- | --- |
| `.octon/state/evidence/connectors/<connector-id>/admissions/<operation-id>/**` | Admission proof and retained review evidence. |
| `.octon/state/evidence/connectors/<connector-id>/operations/<operation-id>/receipts/**` | Future run-bound material operation receipts. |
| `.octon/state/evidence/connectors/<connector-id>/validation/<operation-id>/**` | Validator outputs and lab/stage proofs. |
| `.octon/state/evidence/validation/support-targets/**` | Support proof bundle linkage. |

## Generated projections

| Path | Change |
| --- | --- |
| `.octon/generated/cognition/projections/materialized/connectors/catalog.yml` | Derived operator connector catalog. |
| `.octon/generated/cognition/projections/materialized/connectors/status.yml` | Derived operator status. |
| `.octon/generated/cognition/projections/materialized/connectors/support-cards/**` | Derived support-card projections. |

Generated projections remain non-authoritative.
