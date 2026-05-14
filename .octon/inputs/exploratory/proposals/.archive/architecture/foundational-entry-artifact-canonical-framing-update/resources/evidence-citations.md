# Evidence Citations

_Status: In-review proposal packet artifact_


## Live Octon sources

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

## Citation notes

The packet uses path references and raw GitHub source URLs. Promotion implementation should rerun local repository inspection and retain command output under `state/evidence/**`.

Supplemental conversation files are proposal-local source context only:

- `resources/octon-determinism-conversation-1.md`: deterministic-workflow-first
  critique and Octon direction review.
- `resources/octon-determinism-conversation-2.md`: expanded architecture
  analysis, packet-generation prompt lineage, and implementation-prompt lineage.

These files may inform proposal wording and traceability. They must not be used
as runtime, policy, authority, control truth, evidence, or promotion approval.

## Core evidence summary

- `README.md`: audience-facing current framing and current-state support caveat.
- `AGENTS.md` / `.octon/AGENTS.md`: adapter parity and no extra runtime/policy text.
- `.octon/README.md`: class-root authority discipline.
- `.octon/instance/ingress/AGENTS.md`: read order and topology reference.
- `.octon/instance/bootstrap/START.md`: boot sequence and authority map.
- `run-lifecycle-v1.md`: fail-closed state machine.
- `execution-authorization-v1.md`: engine-owned authorization.
- `authorized-effect-token-v1.md`: typed effect-token enforcement.
- `context-pack-builder-v1.md`: deterministic context evidence.
- `evidence-store-v1.md`: retained evidence and closeout rules.
- Proposal standards: path and manifest conventions.
- Supplemental conversations: local background and lineage only, subordinate to
  live repository state and proposal manifests.
