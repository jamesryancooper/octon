---
title: Skills Comparison
description: Skills vs. other primitives and decision heuristics.
---

# Skills Comparison

This document compares skills to other Harmony primitives to help you choose the right building block for your task.

---

## Skills vs Other Primitives

| Aspect | Skill | Assistant | Workflow | Prompt |
|--------|-------|-----------|----------|--------|
| **Purpose** | Complex capability | Focused specialist | Multi-step procedure | Task template |
| **I/O contract** | Yes (typed paths) | No | No | No |
| **Composable** | Yes (pipelines) | No | Loosely | No |
| **Logging** | Required | No | No | No |
| **Invocation** | `/command` or explicit | `@mention` | Reference | Reference |

---

## Decision Heuristic

Use this guide to choose the right primitive:

| Need | Primitive |
|------|-----------|
| **Complex operations** with defined I/O | Skill |
| **Focused specialist** for scoped tasks | Assistant |
| **Multi-step procedure** to follow | Workflow |
| **Judgment-based template** | Prompt |

### When to Use Skills

- Task has clear inputs and outputs
- Output should be saved to a file
- Execution should be logged for auditing
- Task may be part of a larger pipeline
- Same capability is needed across workspaces

### When NOT to Use Skills

Skills add structure and overhead. Avoid them when simpler primitives suffice:

| Situation | Why NOT a Skill | Use Instead |
|-----------|-----------------|-------------|
| **One-off task** that won't repeat | Skills require upfront definition cost | Direct prompt or ad-hoc instruction |
| **Conversational interaction** without file output | Skills are designed for file I/O | Assistant |
| **Human judgment is primary** and varies each time | Skills assume consistent execution | Prompt template |
| **No audit trail needed** | Skill logging adds overhead | Workflow or prompt |
| **Output format is unpredictable** | Skills expect typed outputs | Assistant with flexible guidance |
| **Quick answer or explanation** | Overkill for information retrieval | Direct question |
| **Process documentation** without execution | Skills are for doing, not describing | Workflow or checklist |
| **Exploratory work** where approach isn't clear | Skills require defined behavior | Research task, then skill |

**Rule of thumb:** If you can't answer "What file will this produce?" and "Could another agent run this identically?", it's probably not a skill.

### When to Use Assistants

- Task requires specialized perspective
- No persistent output needed
- Conversation-based interaction
- Domain expertise more important than I/O contract

### When to Use Workflows

- Multiple steps with human checkpoints
- Steps may involve multiple tools
- Procedure may vary based on context
- Documentation of process is the goal

### When to Use Prompts

- One-shot task template
- Heavy judgment required
- Output format varies significantly
- No logging or persistence needed

---

## Full Primitives Reference

For the complete list of all 7 Harmony primitives (including Commands, Checklists, and Templates), see `.harmony/context/primitives.md`.

---

## See Also

- [Specification](./specification.md) — Spec compliance and validation
- [Architecture](./architecture.md) — Skills architecture
- `.harmony/context/primitives.md` — All Harmony primitives
