# Foundational Entry-Artifact Canonical Framing Update

_Status: In-review proposal packet artifact_


This packet is a temporary, non-canonical architecture proposal intended for `/.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update/`.
It prepares octon-internal foundational entry artifacts for promotion into durable Octon surfaces, but it does not itself become runtime, policy, documentation, or contract authority.
Repo-root `README.md` and `AGENTS.md` are retained as source context and linked companion scope, not active promotion targets in this packet.

Canonical implementation target:

> Octon is a governed workflow runtime for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes.

Strict non-goal: this packet does **not** implement workflow statecharts, harness runtime enforcement, agent-node schemas, replay history, connector admission, MCP integration, Durable Object integration, or external workflow-engine integration.


## Why this packet exists

Octon's live repository already contains strong deterministic runtime surfaces:
run lifecycle state, engine-owned authorization, typed effect tokens, deterministic context packs, bounded support claims, retained evidence, and non-authority rules for generated projections and inputs.

The remaining entry-artifact issue is framing. The root README and ingress adapters still naturally introduce Octon through agents first. That is understandable but strategically incomplete. This packet proposes a foundational wording update so the first repo-facing narrative says:

> Octon is a governed workflow runtime for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes.

## Packet status

- Status: in-review
- Proposal kind: architecture
- Intended canonical proposal path: `/.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update/`
- Promotion scope: octon-internal
- Runtime behavior impact: none
- Linked repo-local companion targets: `README.md`, `AGENTS.md`

## Packet map

Read in this order:

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `EXECUTIVE-SUMMARY.md`
4. `architecture-proposal.md`
5. `current-state-framing-audit.md`
6. `proposed-entry-artifact-edits.md`
7. `implementation-plan.md`
8. `validation-plan.md`
9. `acceptance-criteria.md`
10. `follow-on-packet-sequence.md`
11. `support/implementation-grade-completeness-review.md`

Supporting evidence and inspection material lives under `resources/`.
The supplemental conversation files under `resources/` are proposal-local
background only; they are not runtime, policy, or authority sources.

## Repository source anchors

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
