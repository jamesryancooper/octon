# Repository Inspection Record

_Status: In-review proposal packet artifact_


## Inspected live paths and files

| Path | Status | Observation |
|---|---|---|
| `README.md` | found | Root audience-facing overview; opens with agent-first language but already contains run contracts, authorization, evidence, rollback, and support-boundary framing. |
| `AGENTS.md` | found | Thin ingress adapter; currently says "Enable reliable agent execution..." and forbids adapter-specific runtime/policy text. |
| `.octon/README.md` | found | Super-root overview; strong class-root and non-authority discipline. |
| `.octon/AGENTS.md` | found | Adapter parallel to root `AGENTS.md`. |
| `.octon/instance/ingress/AGENTS.md` | found | Canonical internal ingress with read order, authority roots, state/control/evidence/generated/input rules. |
| `.octon/instance/bootstrap/START.md` | found | Boot sequence, authority map, publication model, non-authoritative proposal/input rules. |
| `.octon/framework/cognition/_meta/architecture/specification.md` | found | Human-readable structural contract; class roots, path families, structural invariants. |
| `.octon/framework/cognition/_meta/terminology/glossary.md` | found | Defines Constitutional Engineering Harness and Governed Agent Runtime; bans model harness/scaffold/framework/bot/assistant primary classifications. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | found | Fail-closed run lifecycle state machine and canonical run journal. |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | found | Engine-owned material execution authorization boundary. |
| `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md` | found | Deterministic context evidence builder. |
| `.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` | found | Typed effect-token boundary. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | found | Canonical retained evidence store. |
| `.octon/instance/governance/support-targets.yml` | found by path | Live support boundary referenced by README and registry; detailed implementation should validate locally before modifying. |
| `.octon/state/control/**` | found | GitHub directory view shows mutable current-state operational truth and execution control roots. |
| `.octon/state/evidence/**` | found | Evidence store contract and directory view indicate retained evidence roots. |
| `.octon/state/continuity/**` | found | Directory exists; continuity state is separate from authority/control/evidence. |
| `.octon/generated/**` | found | Generated root exists; registry/spec classify it as rebuildable projection. |
| `.octon/inputs/**` | found | Inputs root exists; proposals README defines non-canonical proposal workspace. |
| `.octon/inputs/exploratory/proposals/README.md` | found | Live proposal packet convention. |
| `.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | found | Base proposal standard. |
| `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | found | Architecture proposal subtype standard. |

## Relevant files absent or not observed

- No existing `durable-coordination-adapter-v1` artifact was observed in inspected paths.
- No existing `workflow-statechart-v1` artifact was observed in inspected entry surfaces.
- No existing `agent-node-v1` artifact was observed in inspected entry surfaces.
- No live Durable Object integration was observed in inspected entry artifacts.

## Source references

- `repo_readme`: https://raw.githubusercontent.com/jamesryancooper/octon/main/README.md
- `root_agents`: https://raw.githubusercontent.com/jamesryancooper/octon/main/AGENTS.md
- `octon_readme`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md
- `octon_agents`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/AGENTS.md
- `ingress_agents`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/ingress/AGENTS.md
- `bootstrap_start`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/bootstrap/START.md
- `architecture_spec`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md
- `glossary`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/terminology/glossary.md
- `run_lifecycle`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md
- `execution_auth`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-authorization-v1.md
- `context_pack`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md
- `effect_token`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md
- `evidence_store`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/evidence-store-v1.md
- `support_targets`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/support-targets.yml
- `contract_registry`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/contract-registry.yml
- `proposal_readme`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/inputs/exploratory/proposals/README.md
- `proposal_standard`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/scaffolding/governance/patterns/proposal-standard.md
- `architecture_proposal_standard`: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md
- `cloudflare_do`: https://developers.cloudflare.com/durable-objects/concepts/what-are-durable-objects/
- `mcp_tools`: https://modelcontextprotocol.io/specification/draft/server/tools
