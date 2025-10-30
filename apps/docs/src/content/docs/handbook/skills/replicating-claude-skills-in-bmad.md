---
title: Replicating Claude Skills in BMAD
description: Strategy for reproducing Claude Assistant skills inside BMAD modules with Cursor integration.
---

**Claude Skills can be replicated in BMAD.**
Claude Skills are “folders of instructions, scripts, and resources” (centered on a `SKILL.md` with YAML front-matter) that the model can **discover and invoke** when their descriptions match the user task, optionally with *allowed tool* permissions; they can be shared via git or plugins and organized as personal/project/plugin skills. ([Claude Docs][1])

BMAD’s core provides **agent orchestration**, a **workflow execution engine**, and a **modular architecture** for domain-specific extensions, with update-safe configuration for agent behavior. BMAD Builder (BMB) explicitly supports **creating custom agents, workflows, and modules** — i.e., the primitives you need to host and run “skills.” ([GitHub][2])

Concretely:

* Claude: Skills = directories with `SKILL.md` (+ optional scripts/templates); model-invoked based on description; can restrict **allowed-tools**. ([Claude Docs][1])
* BMAD: exposes agents + guided workflows + modules; BMB is designed to build those artifacts (agents/workflows/modules) and package them. ([GitHub][2])

The one feature you’ll **need to add** in BMAD is a thin **“Skill Router”** that mirrors Claude’s *model-invoked* discovery (matching a request to a skill by description/keywords), plus a simple permission layer mapping Claude’s `allowed-tools` concept into BMAD agent/workflow settings. BMAD provides the substrate; the router + permissions are straightforward to implement as a BMAD module. ([Claude Docs][1])

---

## How Claude Skills work (essentials to mirror)

* **Packaging & schema.** A Skill is a directory with a `SKILL.md` that includes YAML front-matter (`name`, `description`, etc.), followed by instructions and examples; supporting files (scripts, templates, references) live alongside. ([Claude Docs][1])
* **Discovery & invocation.** “Agent Skills package expertise into discoverable capabilities… Skills are *model-invoked* — Claude autonomously decides when to use them based on your request and the Skill’s description.” ([Claude Docs][1])
* **Tool permissions.** You can restrict tools per skill via `allowed-tools` (e.g., `allowed-tools: Read, Grep, Glob`). ([Claude Docs][1])
* **Distribution.** Personal (`~/.claude/skills/`), project (`.claude/skills/`), or plugin-packaged for team sharing. ([Claude Docs][1])
* **Reference repo.** Anthropic’s public examples show the pattern (skills as folders, including advanced “document skills” like `docx`, `pptx`, `xlsx`, `pdf`). ([GitHub][3])

---

## What BMAD already gives you

* **Agent orchestration + workflow engine + modular architecture** (foundation to host and run skills). ([GitHub][2])
* **Update-safe agent customization** (persist behavior/policy in `bmad/_cfg/agents/`), useful for per-skill constraints and defaults. ([GitHub][2])
* **Specialized agents and interactive, guided workflows** (BMM); **BMB** to *create* new agents/workflows/modules (i.e., define “skills” as first-class BMAD modules). ([GitHub][2])

---

## Game plan: “Claude-style Skills” in BMAD

**Goal:** Implement a BMAD *Skills Module* that loads skill folders, discovers them from descriptions, applies per-skill permissions, and runs their workflows.

### Phase 1 — Schema & packaging

1. **Define a BMAD skill spec** mirroring Claude’s:

   * `skill/`
     ├ `SKILL.md` (YAML front-matter: `name`, `description`, optional `tags`, optional `allowed-tools`)
     ├ `scripts/` (optional)
     └ `templates/` (optional)
     Use the `SKILL.md` pattern and fields shown in Claude’s docs as your north star. ([Claude Docs][1])
2. **Where skills live:** support project-local (`modules/bmad-skills/skills/*`) and user-local (`~/.bmad/skills/*`) locations, analogous to personal vs project skills. ([Claude Docs][1])
3. **Distribution:** package shared skill sets as a **BMAD module** (leveraging BMB’s module development) so teams can version, install, and update them. ([GitHub][2])

### Phase 2 — Loader & registry

4. **Skill Loader:** BMAD module code that:

   * Recursively scans configured skill paths.
   * Parses `SKILL.md` front-matter + markdown body.
   * Indexes `name`, `description`, `tags`, and *capability hints* for matching.
     (Claude expects this; we’re reproducing its discoverability mechanism.) ([Claude Docs][1])
5. **Registry API:** expose `listSkills()`, `getSkill(name)`, `validateSkill(skillPath)`; include YAML/markdown validation similar to the checks in Claude’s docs. ([Claude Docs][1])

### Phase 3 — Discovery & invocation

6. **Skill Router:** at runtime, before/while a BMAD agent handles a request:

   * Rank skills by semantic match of user request ↔ skill `description`/keywords (exact/keyword match first; optionally add embedding similarity later).
   * If confidence ≥ threshold, **auto-attach** the skill’s instructions/context to the active BMAD workflow — replicating Claude’s *model-invoked* behavior. ([Claude Docs][1])
7. **Multi-skill composition:** allow multiple matched skills to contribute sections/steps when appropriate (Claude encourages composing skills). ([Claude Docs][1])

### Phase 4 — Tool permissions

8. **Map `allowed-tools` → BMAD:** translate the `allowed-tools` list into BMAD agent/workflow permissions and execution gates. Enforce at call-site (deny unlisted tools) and surface a clear error. (Claude shows the `allowed-tools` field; we reproduce the behavior in BMAD.) ([Claude Docs][1])

### Phase 5 — Execution paths

9. **Two ways to run a skill in BMAD:**

   * **Inline within existing workflows:** the router attaches instructions/templates to the current agent’s workflow (typical for “helper” skills like commit messages, code review checklists). ([Claude Docs][1])
   * **Dedicated skill workflows:** package multi-step skills (e.g., document creation/manipulation) as small BMAD workflows invoked by the router. BMAD’s workflow engine is designed for this style of guided execution. ([GitHub][2])

### Phase 6 — DevEx & distribution

10. **CLI ergonomics (optional):** `bmad skills list`, `validate`, `explain` (shows why a skill matched), `scaffold` (creates a new skill from a template using BMB). (BMB is the builder for agents/workflows/modules; a small CLI wrapper is natural.) ([GitHub][2])
11. **Team sharing:** publish a **“bmad-skills” module** (git repo) with canonical, reviewed skills (e.g., *docx/pptx/xlsx/pdf* analogues by porting flows from Anthropic’s “document-skills” examples). ([GitHub][3])

### Phase 7 — Quality bar

12. **Validation suite:** unit tests for loader/registry, permission enforcement, and router ranking; golden tests for a few exemplar skills (commit messages; code review checklist; spreadsheet analysis).
13. **Observability:** log which skills were considered/selected; add a “Why this skill?” debugging aide (mirrors Claude’s recommended troubleshooting). ([Claude Docs][1])

---

## Fit & gaps (what to watch)

* **Skill discovery:** Claude’s “model-invoked” behavior is productized; in BMAD, you’ll implement the selection logic (straightforward matching layer on top of the BMAD agent/workflow engine). ([Claude Docs][1])
* **Permissions:** Claude shows `allowed-tools`; BMAD doesn’t expose the exact same field, but BMAD’s update-safe agent configuration + workflow engine give you the hooks to enforce an equivalent allow-list. ([Claude Docs][1])
* **Marketplace:** Claude mentions plugin-based distribution; BMAD distribution is via modules/repos — functionally equivalent for team use. ([Claude Docs][1])

---

## Recommended initial skill set to prove it out

1. **Commit message generator** (small, single-file skill) – mirrors the example from Claude docs; great for testing loader + router + permissions. ([Claude Docs][1])
2. **Code review checklist** (uses `allowed-tools: Read, Grep, Glob` equivalent) to validate enforcement. ([Claude Docs][1])
3. **Spreadsheet analysis** (multi-file with templates/scripts) to exercise the guided workflow path (akin to Anthropic’s document skills pattern). ([GitHub][3])

---

### Bottom line

* **Feasibility:** High. BMAD has the right primitives (agents, workflows, modules). You’ll add a small **Skills module** with loader/registry, a **Skill Router**, and a **permissions gate** to fully mirror Claude Skills. ([GitHub][2])
* **Scope:** A compact integration — mostly glue code and conventions — not a deep rewrite.
* **Payoff:** Reusable, shareable “micro-capabilities” across your BMAD agents and workflows, just like Claude Skills. ([Claude Docs][1])

If you want, I can draft the `SKILL.md` schema and a minimal BMAD loader/registry skeleton next so you can plug it into your repo.

[1]: https://docs.claude.com/en/docs/claude-code/skills "Agent Skills - Claude Docs"
[2]: https://github.com/bmad-code-org/BMAD-METHOD/tree/v6-alpha "GitHub - bmad-code-org/BMAD-METHOD at v6-alpha"
[3]: https://github.com/anthropics/skills "GitHub - anthropics/skills: Public repository for Skills"
