# Source Artifact Map

This packet was grounded in the live Octon repository surfaces listed below.

## Repository structure and proposal conventions

| Source path | Relevance |
|---|---|
| `README.md` | Establishes Octon as a Constitutional Engineering Harness with a Governed Agent Runtime and `.octon/` class-root separation. |
| `.octon/README.md` | Defines `.octon/` class roots, source-of-truth rules, generated/read-model non-authority, and proposal discovery. |
| `.octon/inputs/exploratory/proposals/README.md` | Defines active proposal packet location and required artifacts. |
| `.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | Defines base proposal standard. |
| `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Defines architecture proposal requirements. |
| `.octon/framework/scaffolding/governance/validators/validate-proposal-standard.sh` | Proposal standard validator. |
| `.octon/framework/scaffolding/governance/validators/validate-architecture-proposal.sh` | Architecture proposal validator. |

## Architecture and runtime authority

| Source path | Relevance |
|---|---|
| `.octon/framework/cognition/_meta/architecture/specification.md` | Umbrella architecture and authority boundaries. |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Contract family registry. |
| `.octon/framework/cognition/_meta/terminology/glossary.md` | Canonical terminology used by this packet. |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Runtime constitutional contract family. |
| `.octon/framework/constitution/contracts/runtime/run-event-ledger-v1.schema.json` | Existing ledger manifest contract. |
| `.octon/framework/constitution/contracts/runtime/run-event-v1.schema.json` | Existing run event contract. |
| `.octon/framework/constitution/contracts/runtime/runtime-state-v1.schema.json` | Existing runtime state contract. |
| `.octon/framework/constitution/contracts/runtime/state-reconstruction-v1.md` | Existing state reconstruction rule. |

## Engine runtime specs and implementation surfaces

| Source path | Relevance |
|---|---|
| `.octon/framework/engine/runtime/README.md` | Runtime CLI and control/evidence root binding. |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Engine-owned authorization boundary. |
| `.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json` | Current runtime event schema. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Existing lifecycle/root rules. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Evidence closeout requirements. |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | Generated operator read model non-authority. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Material-path boundary coverage expectations. |
| `.octon/framework/engine/runtime/crates/**` | Runtime implementation landing zone. |

## Governance, support, assurance, and lab

| Source path | Relevance |
|---|---|
| `.octon/instance/governance/support-targets.yml` | Bounded-admitted-finite support posture and runtime-event-ledger evidence requirement. |
| `.octon/instance/governance/policies/mission-autonomy.yml` | Mission autonomy, intervention, safing, and circuit breaker policy. |
| `.octon/framework/constitution/obligations/fail-closed.yml` | Fail-closed obligations. |
| `.octon/framework/constitution/obligations/evidence.yml` | Evidence obligations. |
| `.octon/framework/assurance/README.md` | Proof planes. |
| `.octon/framework/lab/README.md` | Replay, scenarios, probes, and fault rehearsals. |
| `.octon/framework/assurance/runtime/_ops/scripts/**` | Validation landing zone. |
