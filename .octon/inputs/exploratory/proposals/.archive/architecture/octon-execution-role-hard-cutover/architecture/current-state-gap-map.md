# Current-State Gap Map

| Current repo surface | Target requirement | Exact gap | Severity | Hard-cut action | Validator / evidence |
|---|---|---|---|---|---|
| `framework/agency/**` | `framework/execution-roles/**` is sole execution-role authority | Current subsystem preserves agents/assistants/teams taxonomy. | Critical | Delete active agency subsystem and promote execution-role subsystem. | `validate-execution-role-hard-cutover.sh` proves no active agency paths. |
| `framework/agency/runtime/agents/**` | Orchestrator/verifier under execution roles | Agent noun remains durable. | Critical | Replace with `runtime/orchestrator/**` and `runtime/verifiers/**`. | Registry validation. |
| `framework/agency/runtime/assistants/**` | Specialists under execution roles | Assistant noun remains durable. | Critical | Replace with `runtime/specialists/**`. | Specialist schema validation. |
| `framework/agency/runtime/teams/**` | Composition profiles only | Team noun appears as multi-actor artifact. | High | Replace with `runtime/composition-profiles/**`. | Composition profile validation. |
| Execution schemas use `actor_ref` | Use `execution_role_ref` | Actor is not final canonical noun. | High | Rename field and require in v3 request/receipt. | JSON Schema tests. |
| `workflow_mode: agent-augmented` | No agent ontology in runtime modes | Runtime mode preserves old noun. | High | Replace with `role-mediated` or remove where not needed. | Schema and receipt tests. |
| `.octon/README.md` mission-only transitional path | Run-contract is only atomic execution path | Transitional mission-only path remains documented. | Critical | Delete mission-only execution language. | Readme/charter terminology validator. |
| `support-targets.yml` and charter vocabulary | Support mode must be schema-valid and coherent | `support-targets.yml` is schema-valid but charter says `bounded-admitted-finite-product`. | High | Align charter to schema or update schema with precise product value. Prefer `bounded-admitted-finite`. | Support schema validation. |
| Runtime service manifest | Browser/API/multimodal live only when runtime-real | Manifest lacks browser-session and api-client services. | Critical | Remove live support claims or add runtime services with proof. | Service manifest and support dossier tests. |
| `experimental-external.yml` | No liminal live adapter surfaces | Experimental adapter in active adapter tree. | High | Delete or move to non-live exploratory input. | Adapter discovery validator. |
| Workflow manifest | Only governance/evidence workflows canonical | Catalog contains foundations, projects, ideation, task playbooks, token-routing language. | High | Reduce manifest to governance-critical workflow core. | Workflow manifest validator. |
| `network-egress.yml` | Connector leases for browser/API | Current policy only allows local LangGraph runner. | High | Rebuild egress policy around connector leases. | Egress policy tests. |
| `execution-budgets.yml` | Run/mission/model/tool/browser/API budgets | Current budget policy is insufficiently frontier-scoped. | High | Add run/mission/tool/browser/API budget classes. | Budget validation. |
| `generated/cognition/**` | Derived context only | Generated cognition must never become memory/authority. | Medium | Add context-pack derived-input labeling and freshness receipts. | Context-pack validator. |
| Proposal workspace | Non-authoritative packet only | Packet must not be a source of truth after promotion. | Medium | Promotion targets stand alone; archive after implemented. | Proposal standard validator. |
