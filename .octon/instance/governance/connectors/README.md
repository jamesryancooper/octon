# Connector Governance Posture

Tool, MCP, API, browser, shell, service, and host connector posture for the
Safe Start surface is machine-readable under this directory.

Repo-local connector posture declarations live in:

- `registry.yml`
- `posture.yml`

Those files are machine-readable stage/block/deny policy for Work Package
readiness. They are not support admission, capability admission, egress
authorization, credential authorization, or live execution authority.

## Safe Start Rules

- Connector posture may be recorded for planning and Decision Requests.
- Connector posture may map future operations to support tuples, capability
  packs, and material-effect classes.
- Connector posture may not authorize live connector effects.
- Unsupported or unadmitted connectors return `stage_only`, `blocked`, or
  `denied`.
- First live effectful connector use requires support admission, capability
  admission, egress and credential policy, evidence requirements, rollback
  posture, and the existing run authorization path.
- Unknown connector classes are blocked until explicitly registered and mapped.

## Contract

- `.octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json`

Generated connector projections are optional operator read models only and must
not be consumed as runtime, policy, support, or approval authority.
