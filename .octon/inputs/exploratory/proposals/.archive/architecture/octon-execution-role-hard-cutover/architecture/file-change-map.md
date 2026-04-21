# File Change Map

| Path | Change | Rationale | Class | Authority/control/evidence/generated | Validator impact | Criticality |
|---|---|---|---|---|---|---|
| `.octon/framework/agency/**` | delete | Legacy agency ontology no longer final. | framework | authority removed | old-path absence check | critical |
| `.octon/framework/execution-roles/README.md` | add | New subsystem entrypoint. | framework | authority | execution-role doc check | critical |
| `.octon/framework/execution-roles/_meta/architecture/specification.md` | add | Canonical execution-role spec. | framework | authority | spec validation | critical |
| `.octon/framework/execution-roles/registry.yml` | add | Single execution-role registry. | framework | authority | registry schema | critical |
| `.octon/framework/execution-roles/governance/DELEGATION.md` | add | Delegation and escalation contract. | framework | authority | delegation rules | high |
| `.octon/framework/execution-roles/governance/MEMORY.md` | add | No role-owned memory contract. | framework | authority | memory boundary tests | high |
| `.octon/framework/execution-roles/runtime/orchestrator/**` | add | Required accountable role. | framework | authority | one-orchestrator test | critical |
| `.octon/framework/execution-roles/runtime/specialists/**` | add | Bounded specialist roles. | framework | authority | specialist boundary tests | high |
| `.octon/framework/execution-roles/runtime/verifiers/**` | add | Optional independent verifier. | framework | authority | verifier activation tests | high |
| `.octon/framework/execution-roles/runtime/composition-profiles/**` | add | Reusable handoff config only. | framework | authority | non-execution tests | medium |
| `.octon/framework/engine/runtime/spec/execution-request-v2.schema.json` | retire | Old `actor_ref` and agent mode language. | framework | authority retired | schema v3 required | critical |
| `.octon/framework/engine/runtime/spec/execution-request-v3.schema.json` | add | Execution-role, context-pack, support tuple, rollback requirements. | framework | authority | schema tests | critical |
| `.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json` | retire | Old receipt shape. | framework | authority retired | schema v3 required | high |
| `.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json` | add | Evidence and event-aligned receipt shape. | framework | authority | receipt tests | critical |
| `.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json` | add | Canonical runtime event ledger. | framework | authority | event tests | high |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | modify | Replace actor/agent language and bind v3 schemas. | framework | authority | authorization tests | critical |
| `.octon/framework/constitution/charter.yml` | modify | Align support mode with schema and remove product suffix. | framework | authority | support schema tests | critical |
| `.octon/README.md` | modify | Remove mission-only transitional path and agency terminology. | framework-ish root doc | authority map | terminology tests | critical |
| `.octon/octon.yml` | modify | Add execution role root and v3 runtime schema references. | root manifest | authority | root manifest tests | critical |
| `.octon/framework/overlay-points/registry.yml` | modify | Replace `instance-agency-runtime` with `instance-execution-roles-runtime`. | framework | authority | overlay validation | high |
| `.octon/instance/manifest.yml` | modify | Enable execution-role overlay, remove agency overlay. | instance | authority | overlay validation | high |
| `.octon/framework/orchestration/runtime/workflows/manifest.yml` | modify | Retain only governance/evidence/recovery workflow core. | framework | authority | workflow manifest tests | high |
| `.octon/framework/capabilities/_meta/architecture/specification.md` | modify | Collapse capability explanation into instruction vs invocation contracts. | framework | authority | docs lint | medium |
| `.octon/framework/capabilities/runtime/services/manifest.runtime.yml` | modify | Add browser/API services only if proof-backed; otherwise mark non-live. | framework | authority | service manifest tests | critical |
| `.octon/framework/engine/runtime/adapters/model/experimental-external.yml` | delete | Liminal experimental adapter cannot remain active discovery. | framework | authority removed | adapter discovery test | high |
| `.octon/instance/governance/policies/network-egress.yml` | replace | Connector leases required for API/browser support. | instance | authority | egress policy tests | high |
| `.octon/instance/governance/policies/execution-budgets.yml` | replace | Add run/mission/model/tool/browser/API budgets. | instance | authority | budget tests | high |
| `.octon/instance/governance/support-targets.yml` | modify | Ensure live tuples only; browser/API staged unless proof-backed. | instance | authority | support tests | critical |
| `.octon/framework/lab/README.md` | modify | Make baseline benchmark and support-proof obligations explicit. | framework | authority | lab test inventory | medium |
| `.octon/framework/observability/README.md` | modify | Add runtime event and intervention accounting expectations. | framework | authority | observability tests | medium |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-role-hard-cutover.sh` | add | Hard-cut validator. | framework | authority/executable | required validator | critical |
