# Capability, Tool, and Protocol Model

## Contract split

Octon collapses capability concepts into two conceptual classes:

| Class | Existing surfaces | Meaning |
|---|---|---|
| Instruction contracts | commands, skills | Operator-facing instructions and reusable procedures. |
| Invocation contracts | tools, services | Runtime-callable action surfaces. |

Capability packs, manifests, registries, support targets, and adapter tuples are
packaging, admission, and governance layers.

## Capability packs

Capability packs remain governance-grade. They bound a broader action surface
above individual tools/services/skills/commands and must be admitted by support
target and granted by the engine.

## Support-target binding

A run may use only capability packs admitted by its support-target tuple.

The live claim boundary is:

```text
(model tier, workload tier, language/context tier, locale tier, host adapter, model adapter, capability packs)
```

Only tuple-admitted and dossier-backed claims are live.

## Adapter tuple

The adapter tuple is:

```text
host_adapter + model_adapter
```

Adapters are replaceable, non-authoritative boundaries. They cannot mint
authority, expand support, or bypass grants.

## MCP role

MCP is limited to tool/resource/prompt integration. It does not provide Octon's
run lifecycle, approval, evidence, replay, rollback, disclosure, or support
semantics.

## Runtime event surface

Octon must expose a runtime event surface over canonical control/evidence roots:

- `run.started`
- `run.context_pack_bound`
- `run.grant_issued`
- `run.grant_denied`
- `approval.requested`
- `approval.resolved`
- `capability.invoked`
- `checkpoint.created`
- `evidence.persisted`
- `replay.available`
- `rollback.started`
- `rollback.completed`
- `intervention.recorded`
- `disclosure.ready`
- `run.closed`

Events are projections over canonical roots, not independent authority.

## Browser/API/multimodal governance

Browser/API/multimodal execution is live only when runtime-real and proof-backed.
Required services:

- `interfaces/browser-session`
- `interfaces/browser-replay`
- `interfaces/api-client`
- `interfaces/connector-registry`
- `interfaces/multimodal-provenance`
- `execution/egress-lease-controller`
- `execution/rollback-recovery`

Required records:

- browser UI execution record
- API egress record
- redaction metadata
- replay manifest
- event ledger
- compensation/rollback posture
- support dossier
- disclosure evidence

## Connector leases and egress

Egress must be connector-scoped:

- allowed domain/service
- auth mode
- data classes
- idempotency class
- rate/cost limits
- compensation plan
- redaction policy
- replay requirements
- approval thresholds

## Sandboxing

Every material run must be sandboxed according to support target, adapter tuple,
capability packs, and risk/materiality classification.
