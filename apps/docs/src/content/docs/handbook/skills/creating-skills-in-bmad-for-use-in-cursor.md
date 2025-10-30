---
title: Creating BMAD Skills for Cursor
description: Mapping Claude-style skills into BMAD modules and Cursor workflows for discovery, invocation, and guardrails.
---

Short answer: **yes—working inside Cursor simplifies the plan**. You’ll keep the BMAD “Skills module + router + permissions” idea, but you can lean on Cursor’s built-ins for discovery, invocation, and guardrails:

* **Discovery & invocation:** use **Cursor Commands** (Markdown files) as the user-facing entry points for skills—scoped per project (`.cursor/commands/`), global, or team-managed—so they autocomplete with `/` in chat. ([Cursor][1])
* **Auto selection:** implement your *Skill Router* as a **Cursor Hook** that inspects the agent loop and triggers the right command/workflow based on the user request (hooks can observe/modify stages via JSON over stdio). ([Cursor][2])
* **Execution:** run BMAD workflows through Cursor’s **Terminal tool** (agent-driven shell), and expose BMAD capabilities as **tools** (including via MCP) so the agent can call them directly. ([Cursor][3])
* **Guardrails:** mirror Claude’s `allowed-tools` via Cursor **tool permissions / auto-run settings** and hook-level blocking. ([Cursor][4])
* **Docs-as-context:** add BMAD docs to Cursor with `@Docs` so the agent “knows” your skills/workflows while coding. ([Cursor][5])

Also note BMAD v6-alpha is moving fast (breaking changes expected), so keep the glue thin and test often. ([GitHub][6])

---

# Claude Skills ➜ BMAD ➜ Cursor (mapping)

* **Skill packaging** (Claude): folder + `SKILL.md` with YAML front-matter; model-invoked; optional `allowed-tools`. ([Claude Docs][7])
* **BMAD analogue:** a *Skills module* (folders + manifest) with a small **router** that selects instructions/workflows and enforces tool allow-lists.
* **Cursor fit:**

  * `SKILL.md` ➜ **.cursor/commands/**`<skill>.md` (user-invoked), plus a **Hook** to *auto-invoke* when description matches the request (model-invoked feel). ([Cursor][1])
  * `allowed-tools` ➜ **Cursor tools config** (auto-run / auto-apply / guardrails) + pre-exec hook to deny disallowed tools/commands. ([Cursor][4])
  * Runtime ➜ **Agent uses Terminal** to run `bmad` tasks; or expose BMAD as an **MCP tool** for direct calls. ([Cursor][3])

---

# Cursor-aware game plan (delta from the previous plan)

1. **Skill spec stays the same**
   Keep the BMAD skill folder + YAML front-matter you already planned (mirrors Claude’s `SKILL.md`). ([Claude Docs][7])

2. **Surface every BMAD skill as a Cursor Command**

   * Create a generator that turns each BMAD skill into a `.cursor/commands/<skill>.md` file with: a one-line description, parameters (if any), and the action (invoke BMAD workflow or tool).
   * Store commands **per-project** (checked into git) for team sharing, or **global** for your personal set. ([Cursor][1])

3. **Auto-invocation via Hooks (= “model-invoked”)**

   * Add a **pre-plan** or **pre-tool** hook that reads the user’s message, matches it against the skills registry (BMAD), and if confidence ≥ threshold, instructs the agent to run the corresponding command/workflow.
   * Hooks can *observe, block, or modify* the loop; they’re JSON over stdio processes—so you can keep this as a tiny Node/Python shim. ([Cursor][2])
   * InfoQ’s summary of Cursor 1.7 hooks (lifecycle interception, blocking shell commands, running formatters) shows exactly the kind of control you’ll use. ([InfoQ][8])
   * If you want examples, the public **cursor-hooks** repo wires hooks to scripts for auditing/denying commands—useful patterns for allow-lists. ([GitHub][9])

4. **Map `allowed-tools` to Cursor guardrails**

   * For each skill, compile an allow-list of Cursor tools/commands.
   * In **Tools** settings, set auto-run/auto-apply appropriately and have a **pre_exec hook** reject anything not in the allow-list (e.g., block `git push` unless the skill explicitly permits). ([Cursor][4])

5. **Execution paths**

   * **Terminal tool**: run `npx bmad-method …` or `npm run …` scripts from the agent. (BMAD’s README shows `npx bmad-method install` and an IDE-centric dev cycle.) ([GitHub][6])
   * **Cursor tools / MCP**: optionally expose BMAD’s registry/workflows as MCP tools so the agent can call them without shelling out. ([Cursor][4])

6. **Make the agent “BMAD-literate”**

   * Add BMAD docs (including the **Cursor guide** you linked) via `@Docs` so the agent can cite patterns and workflows during chat. ([Cursor][5])

7. **Modes & CLI** (quality of life)

   * Use **Agent mode** for longer, multi-file changes; **Ask/Manual** when you want tighter control. (External write-ups echo this workflow.) ([Stoltzstack][10])
   * The **CLI agent** follows the same rules system as IDE, useful for CI smoke tests of your router and permissions. ([Cursor][11])

---

## Minimal wiring checklist

* [ ] BMAD **Skills module** with loader/registry (as before).
* [ ] **Command generator** → emits `.cursor/commands` from each skill. ([Cursor][1])
* [ ] **Hook** that: (a) matches request→skill, (b) auto-invokes the command, (c) enforces allow-list. ([Cursor][2])
* [ ] **Tools config**: turn on/off auto-run, set guardrails per skill. ([Cursor][4])
* [ ] **Terminal path** to run `bmad` workflows. ([Cursor][3])
* [ ] `@Docs` import of BMAD/skill docs for context. ([Cursor][5])
* [ ] Note BMAD **v6-alpha churn**; keep glue code small and tested. ([GitHub][6])

---

## What *doesn’t* change

* The core judgment that **Claude Skills are replicable in BMAD**—skills as folders + router + permissions—still holds. Claude’s definition (folder + `SKILL.md`, model-invoked, `allowed-tools`) is stable; you’re just swapping Claude’s runtime for BMAD+Cursor primitives. ([Claude Docs][7])

If you want, I can sketch a sample `.cursor/commands/skill.md` and a tiny hook that enforces a `safe-file-reader` allow-list to get you started.

[1]: https://cursor.com/docs/agent/chat/commands?utm_source=chatgpt.com "Commands | Cursor Docs"
[2]: https://cursor.com/docs/agent/hooks?utm_source=chatgpt.com "Hooks | Cursor Docs"
[3]: https://cursor.com/docs/agent/terminal?utm_source=chatgpt.com "Terminal | Cursor Docs"
[4]: https://cursor.com/docs/agent/tools?utm_source=chatgpt.com "Tools | Cursor Docs"
[5]: https://cursor.com/docs/context/symbols?utm_source=chatgpt.com "@ Symbols - Cursor Docs"
[6]: https://github.com/bmad-code-org/BMAD-METHOD "GitHub - bmad-code-org/BMAD-METHOD: Breakthrough Method for Agile Ai Driven Development"
[7]: https://docs.claude.com/en/docs/claude-code/skills "Agent Skills - Claude Docs"
[8]: https://www.infoq.com/news/2025/10/cursor-hooks/?utm_source=chatgpt.com "Cursor 1.7 Adds Hooks for Agent Lifecycle Control - InfoQ"
[9]: https://github.com/hamzafer/cursor-hooks?utm_source=chatgpt.com "Cursor Hooks Examples - GitHub"
[10]: https://stoltzstack.com/blog/mastering-cursor-modes?utm_source=chatgpt.com "Making the Most of Cursor: When to Use Each Mode"
[11]: https://cursor.com/docs/cli/using?utm_source=chatgpt.com "Using Agent in CLI | Cursor Docs"
