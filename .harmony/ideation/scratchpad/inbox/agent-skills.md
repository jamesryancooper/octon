# AI Agent Skills

Below is a curated “best-of” reading list for **AI Agent Skills** (the reusable, folder-based *SKILL.md + resources/scripts* pattern), plus the **adjacent standards** that have effectively become best practice for real-world skill implementations.

---

## Canonical spec and “industry standard” docs (start here)

- **Agent Skills (open standard) – Overview / adoption**
  - What it is, why it exists, and which products support it. Notes that the format originated at Anthropic and is now an open standard. ([agentskills.io](https://agentskills.io/home?utm_source=chatgpt.com))
- **Agent Skills – Format specification**
  - The definitive source for directory structure (`SKILL.md` required; optional `scripts/`, `references/`, `assets/`). ([agentskills.io](https://agentskills.io/specification?utm_source=chatgpt.com))
- **Agent Skills – “Integrate skills” guide**
  - Practical guidance for agent/product implementers (discovery, loading, execution) and interoperability with the ecosystem. ([agentskills.io](https://agentskills.io/integrate-skills))
- **agentskills/agentskills (GitHub)**
  - The spec + docs repo; describes Agent Skills as an open format maintained by Anthropic and open to community contributions. ([GitHub](https://github.com/modelcontextprotocol/modelcontextprotocol))
- **skills-ref (reference library / validator)**
  - Reference library and tooling for validating skills; also explicitly framed as demo/non-production. ([GitHub](https://github.com/agentskills/agentskills/tree/main/skills-ref?utm_source=chatgpt.com))

---

## Big-lab / major-product implementations (architecture, purpose, usage)

### Anthropic (Claude + Claude Code)

- **Claude Docs: Agent Skills – Overview**
  - Defines Agent Skills as modular, filesystem-based packages (instructions + metadata + optional resources) that load on-demand and can be composed. Links to the engineering deep dive. ([Claude Developer Platform](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview))
- **Claude Code Docs: Skills**
  - Concrete “how-to”: where skills live (project and user scopes) and how Claude Code discovers/uses them. ([Claude Code](https://code.claude.com/docs/en/skills))
- **Anthropic Engineering: “Equipping agents for the real world with Agent Skills”**
  - One of the best architecture writeups: why skills exist, how they manage context, and real-world concerns like safety/abuse and reliability. ([Anthropic](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills))

### OpenAI (Codex)

- **OpenAI Codex Docs: Agent Skills – Overview**
  - Very explicit on architecture:
    - `SKILL.md` + optional `scripts/`, `references/`, `assets/`
    - **progressive disclosure**: load only name/description at startup; pull full skill content only when invoked
    - explicit invocation (`/skills` or `$skill`) vs implicit invocation ([OpenAI Developers](https://developers.openai.com/codex/skills))
- **OpenAI Codex Docs: Create custom skills**
  - Practical authoring guidance (frontmatter, scope, references/scripts) and workflow for bootstrapping skills. ([OpenAI Developers](https://developers.openai.com/codex/skills/create-skill))

### Microsoft/GitHub (VS Code + Copilot)

- **VS Code Docs: Use Agent Skills**
  - Clear comparison vs custom instructions; **portable across Copilot surfaces**; recommended locations:
    - project: `.github/skills/` (recommended), `.claude/skills/` (legacy)
    - personal: `~/.copilot/skills/` (recommended), `~/.claude/skills/` (legacy)
  - Also emphasizes “efficient loading” (only load what’s needed). ([Visual Studio Code](https://code.visualstudio.com/docs/copilot/customization/agent-skills))
- **GitHub Docs: About Agent Skills**
  - Defines skills as folders of instructions/scripts/resources loaded when relevant, and points to shared skill collections. ([GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills))
- **GitHub Changelog announcement (Dec 18, 2025)**
  - Confirms “auto-load when relevant,” cross-surface support, and backward-compat pickup of `.claude/skills`. ([The GitHub Blog](https://github.blog/changelog/2025-12-18-github-copilot-now-supports-agent-skills/))

### Cursor

- **Cursor Docs: Skills (concept + usage)**
  - Cursor documents “skills” as packaging reusable knowledge/scripts in an open standard format (Agent Skills). (Cursor’s docs are partially JS-rendered; this is the indexable docs text.) ([Cursor](https://cursor.com/docs/context/skills?utm_source=chatgpt.com))

---

## High-signal example libraries (to copy patterns from)

- **anthropics/skills (GitHub) – public skills repository**
  - A huge set of real skills you can read and reuse as patterns. ([GitHub](https://github.com/anthropics/skills?utm_source=chatgpt.com))
- **awesome-copilot: skills readme**
  - A community curation that summarizes what makes a skill “a skill” and how they differ from other customization primitives. ([GitHub](https://github.com/github/awesome-copilot/blob/main/docs/README.skills.md?utm_source=chatgpt.com))

---

## Adjacent standards that matter in practice (skills ↔ tools ↔ repo rules)

These aren’t “Agent Skills” per se, but they’ve become **de-facto best practice** in modern agent systems that run skills.

- **Model Context Protocol (MCP)**
  - Widely used standard for connecting agents to external tools/data sources; the official repo notes the spec + protocol schema and that the schema is TypeScript-first and also published as JSON Schema. ([GitHub](https://github.com/modelcontextprotocol/modelcontextprotocol))
- **AGENTS.md (agent instruction files) + ecosystem standardization**
  - OpenAI has described AGENTS.md as a shared, platform-neutral way to provide agents with repo/project instructions, with stewardship moving into an industry org (AAIF / Linux Foundation coverage varies by source). ([OpenAI](https://openai.com/index/agentic-ai-foundation/))
- **Tool/function calling schemas (how skills “touch the world”)**
  - **OpenAI tools/function calling** patterns (structured schemas) ([OpenAI Platform](https://platform.openai.com/docs/guides/function-calling))
  - **Anthropic tool use** patterns (schema-driven tool definitions) ([Claude Developer Platform](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview))
  - **Google / Vertex AI function calling** (OpenAPI-based tooling patterns) ([Google Cloud Documentation](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/multimodal/function-calling))

Why this matters: many “skills” are basically *reusable workflows* that (a) instruct an agent, and (b) constrain/shape its tool use and execution.

---

## Best practices that show up across the big implementations

These themes repeat across Anthropic, OpenAI, and Microsoft/GitHub docs:

- **Progressive disclosure / context efficiency**
Load only skill *name/description* at startup; inject full `SKILL.md` + references only when invoked. ([OpenAI Developers](https://developers.openai.com/codex/skills))
- **Treat `SKILL.md` frontmatter as the “routing contract”**
Make `name` unique + stable; make `description` concrete about *when* and *why* to use the skill (this drives auto-selection). ([Visual Studio Code](https://code.visualstudio.com/docs/copilot/customization/agent-skills))
- **Bundle execution helpers, but keep them safe**
Skills can include scripts/resources; implementers should assume scripts can be dangerous and design for least privilege / review / sandboxing. ([Claude Developer Platform](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview))
- **Prefer portability-friendly layout**
You’ll see consistent, cross-agent conventions:
  - skill folder per capability
  - `SKILL.md` as the entrypoint
  - `references/` for supporting docs
  - `scripts/` for deterministic helpers ([OpenAI Developers](https://developers.openai.com/codex/skills))
- **Validate + keep references shallow**
The ecosystem is converging on validation tooling and guidance like avoiding deeply nested reference chains. ([GitHub](https://github.com/agentskills/agentskills/blob/main/docs/specification.mdx?utm_source=chatgpt.com))

---

## Secondary explainers (useful, but not authoritative)

- **Medium explainer: “What are agent skills?”**
  - A narrative intro; useful for onboarding, but treat as commentary vs spec. ([Medium](https://medium.com/%40tahirbalarabe2/what-are-agent-skills-c7793b206daf))

---

- [theverge.com](https://www.theverge.com/news/808032/github-ai-agent-hq-coding-openai-anthropic?utm_source=chatgpt.com)
- [theverge.com](https://www.theverge.com/news/669339/github-ai-coding-agent-fix-bugs?utm_source=chatgpt.com)
- [wired.com](https://www.wired.com/story/openai-anthropic-and-block-are-teaming-up-on-ai-agent-standards?utm_source=chatgpt.com)
- [theverge.com](https://www.theverge.com/ai-artificial-intelligence/841156/ai-companies-aaif-anthropic-mcp-model-context-protocol?utm_source=chatgpt.com)
- [itpro.com](https://www.itpro.com/software/development/github-just-launched-a-new-mission-control-center-for-developers-to-delegate-tasks-to-ai-coding-agents?utm_source=chatgpt.com)

