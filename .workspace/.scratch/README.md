---
title: Scratchpad
description: Persistent human-led thinking, research, and collaboration space.
---

# .scratch/: Human-Led Scratchpad

This directory is for **persistent thinking and research**—a space where humans can explore ideas, draft content, and collaborate with agents under explicit direction.

---

## What Belongs Here

| Content Type | Examples |
|--------------|----------|
| **Daily notes** | `daily/2025-01-04.md` — stream-of-consciousness, meeting notes |
| **Drafts** | `drafts/feature-proposal.md` — work-in-progress before promotion |
| **Research** | `research/` — collected findings, links, analysis |
| **Clips** | `clips/` — snippets, quotes, code fragments for reference |
| **Ideas** | `ideas/` — brainstorming, possibilities, "what if" explorations |

---

## What Does NOT Belong Here

| Content Type | Where It Goes |
|--------------|---------------|
| Finalized decisions | `.workspace/context/decisions.md` |
| Confirmed constraints | `.workspace/context/constraints.md` |
| External imports (unprocessed) | `.workspace/.inbox/` |
| Agent-executable instructions | `.workspace/prompts/`, `workflows/`, `commands/` |
| Deprecated content | `.workspace/.archive/` |

---

## Autonomy Rules

**This directory is human-led. Agents must not access it autonomously.**

| Rule | Description |
|------|-------------|
| **No autonomous access** | Agents MUST NOT scan, read, or write to `.scratch/**` during autonomous operation |
| **Human-directed only** | Agents MAY read/edit files here ONLY when a human explicitly points to specific files AND requests specific changes |
| **Scoped edits** | When directed, agent work stays scoped to the referenced files |
| **Invisible to agents** | During autonomous operation, agents behave as if this path does not exist |

### When an Agent May Assist

Agents can help with `.scratch/` content when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `.scratch/ideas.md`")
2. Human requests a concrete action (e.g., "summarize this", "add X to the list")
3. Agent's work stays within the referenced files

### Example: Valid Collaboration

```text
Human: "Review .scratch/research.md and help me organize the findings into sections"
Agent: [Reads the specific file, proposes organization, edits as directed]
```

### Example: Invalid Autonomous Action

```text
Agent: "I noticed some interesting notes in .scratch/ideas.md that might help..."
→ VIOLATION: Agent scanned .scratch/ without explicit human direction
```

---

## Publish Workflow

When insights in `.scratch/` mature into actionable knowledge, **promote them** to agent-facing locations.

**Workflow:** See `.workspace/workflows/promote-from-scratch.md`

### Quick Reference: Where to Promote

| Content Type | Destination |
|--------------|-------------|
| Finalized decisions + rationale | `context/decisions.md` |
| Non-negotiable constraints | `context/constraints.md` |
| Domain terminology | `context/glossary.md` |
| Next actions | `progress/next.md` |
| Lessons learned | `context/lessons.md` |

**Rule:** Never copy raw scratch verbatim. Always summarize and distill into agent-facing artifacts.

---

## Directory Structure

```text
.scratch/
├── README.md       ← You are here
├── ideas/          ← Brainstorming and possibilities
├── research/       ← Collected findings and analysis
├── daily/          ← Date-based notes (YYYY-MM-DD.md)
├── drafts/         ← Work-in-progress documents
└── clips/          ← Snippets and fragments
```

---

## Git Hygiene

**Default:** This directory structure and README are committed to share the convention.

**Content:** Individual notes (especially `daily/`) may be personal. Options:

1. **Commit everything** — Team shares research openly
2. **Selective gitignore** — Add `daily/*.md` to `.gitignore` if notes are personal
3. **Keep structure only** — `.gitkeep` files preserve directories without content

This workspace commits the structure. Adjust `.gitignore` if needed for your workflow.

---

## See Also

- [`.workspace/.inbox/README.md`](./.inbox/README.md) — Temporary staging for external imports
- [`.workspace/START.md`](../START.md) — Boot sequence with visibility rules
- [`.workspace/workflows/promote-from-scratch.md`](../workflows/promote-from-scratch.md) — Publish workflow
