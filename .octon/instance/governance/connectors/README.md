# Connector Governance Posture

Tool, MCP, API, browser, shell, service, and host connector posture for the
Safe Start surface is machine-readable under this directory.

Repo-local connector posture declarations live in:

- `external-effect-delegation-boundaries.yml`
- `registry.yml`
- `posture.yml`

Those files are machine-readable stage/block/deny policy for Change Package
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
- Machine-delegated connector or external-effect execution requires explicit
  token, scope, egress, replay or compensation, and retained receipt proof.
- Irreversible external effects remain human-required unless rollback or
  compensation proof is explicit and machine-checkable.
- Unknown connector classes are blocked until explicitly registered and mapped.

## Contract

- `.octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json`

Generated connector projections are optional operator read models only and must
not be consumed as runtime, policy, support, or approval authority.
