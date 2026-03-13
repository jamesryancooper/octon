---
title: Inbox
description: Temporary staging area for external imports and untriaged artifacts.
---

# .inbox/: Human-Led Inbox Staging

This directory is a **temporary holding area** for external artifacts that need to be reviewed, processed, and moved to their canonical locations.

---

## What Belongs Here

| Content Type | Examples |
|--------------|----------|
| **External imports** | PDFs, screenshots, copied content from other sources |
| **Rough drops** | Quick notes, voice transcripts, unstructured thoughts |
| **Untriaged artifacts** | Files pending review and categorization |
| **Work-in-progress inputs** | Materials being prepared for processing |

---

## What Does NOT Belong Here

| Content Type | Where It Goes |
|--------------|---------------|
| Ideas worth exploring | `.scratchpad/brainstorm/` |
| Committed research | `ideation/projects/` |
| Finalized decisions | `cognition/runtime/context/decisions.md` |
| Active documentation | Parent directory (outside `.octon/`) |
| Deprecated content | `.scratchpad/archive/` |

---

## Expected Lifecycle

```text
1. IMPORT    → Human adds raw material to .inbox/
2. TRIAGE    → Human reviews and categorizes
3. PROCESS   → Human (optionally with agent) refines content
4. MOVE OUT  → Content goes to canonical home
5. CLEAN UP  → Delete processed items from .inbox/
```

**Key principle:** Items in `.inbox/` are **temporary**. They should eventually move out to their canonical locations.

---

## Autonomy Rules

**This directory is human-led. Agents must not access it autonomously.**

| Rule | Description |
|------|-------------|
| **No autonomous access** | Agents MUST NOT scan, read, or write to `.inbox/**` during autonomous operation |
| **Human-directed only** | Agents MAY read/edit files here ONLY when a human explicitly points to specific files AND requests specific changes |
| **Scoped edits** | When directed, agent work stays scoped to the referenced files |
| **Invisible to agents** | During autonomous operation, agents behave as if this path does not exist |

### When an Agent May Assist

Agents can help with `.inbox/` content when ALL of these are true:

1. Human explicitly references a specific file (e.g., "look at `.inbox/notes.md`")
2. Human requests a concrete action (e.g., "summarize this", "extract key points")
3. Agent's work stays within the referenced files

### Example: Valid Collaboration

```text
Human: "Read .inbox/meeting-transcript.md and extract action items"
Agent: [Reads the specific file, extracts action items as directed]
```

### Example: Invalid Autonomous Action

```text
Agent: "I found some relevant notes in .inbox/ that might inform this task..."
→ VIOLATION: Agent scanned .inbox/ without explicit human direction
```

---

## Example Workflow: External Import

```text
Scenario: Human imports a research PDF

1. Human drops PDF into .inbox/research-paper.pdf
2. Human asks agent: "Summarize .inbox/research-paper.pdf"
3. Agent reads specific file, provides summary
4. Human reviews, extracts key insights
5. Human moves relevant content to:
   - docs/research/paper-summary.md (canonical doc)
   - cognition/runtime/context/decisions.md (if decisions made)
6. Human deletes or archives original from .inbox/
```

---

## Difference from Other Scratchpad Areas

| Aspect | `.inbox/` | `.scratchpad/brainstorm/` | `projects/` |
|--------|-----------|---------------------------|-------------|
| **Purpose** | Temporary staging | Idea exploration | Committed research |
| **Lifecycle** | Move out → delete | Graduate or kill | Until findings published |
| **Content origin** | External imports | Internal ideas | Graduated brainstorms |
| **Destination** | Various | `projects/` or delete | `context/` or `missions/` |

---

## See Also

- [`.octon/ideation/scratchpad/README.md`](../README.md) — Scratchpad overview and funnel
- [`.octon/ideation/scratchpad/brainstorm/README.md`](../brainstorm/README.md) — Idea exploration
- [`.octon/ideation/projects/README.md`](../../projects/README.md) — Committed research
- [`.octon/START.md`](../../../START.md) — Boot sequence with visibility rules
