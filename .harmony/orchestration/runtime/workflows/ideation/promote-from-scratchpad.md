---
name: promote-from-scratchpad
title: Promote from Scratch
description: Publish distilled insights from ideation/scratchpad/ to agent-facing artifacts.
access: human
version: "1.0.0"
---

# Promote from Scratch

When thinking in `ideation/scratchpad/` matures into actionable knowledge, use this workflow to promote insights to agent-facing locations.

## Context

This is a human-initiated bridge between raw ideation notes and durable
agent-facing artifacts. Use it only when scratchpad content has become stable
enough to act on.

## Failure Conditions

- Scratchpad source is still speculative or unresolved -> STOP, continue ideation before promotion
- No suitable destination artifact can be identified -> STOP, clarify the target surface before promoting
- Promotion would cross a human-led boundary without explicit direction -> STOP, wait for human instruction

---

## When to Promote

| Trigger | What Happened | Action |
|---------|---------------|--------|
| **Decision made** | You've resolved a question or chosen a direction | Add to `cognition/runtime/context/decisions.md` |
| **Constraint discovered** | You've identified a non-negotiable requirement | Add to `cognition/runtime/context/constraints.md` |
| **Pattern identified** | You've found a reusable approach | Add to `cognition/runtime/context/lessons.md` or create workflow |
| **Term clarified** | You've defined domain vocabulary | Add to `cognition/runtime/context/glossary.md` |
| **Next step identified** | You know the immediate action to take | Add to `continuity/next.md` |

---

## Destination Reference

| Content Type | Destination | Format |
|--------------|-------------|--------|
| Finalized decisions + rationale | `cognition/runtime/context/decisions.md` | Table row or section |
| Non-negotiable constraints | `cognition/runtime/context/constraints.md` | Table row or section |
| Domain terminology | `cognition/runtime/context/glossary.md` | Table row |
| Lessons learned, anti-patterns | `cognition/runtime/context/lessons.md` | Entry with context |
| Immediate next actions | `continuity/next.md` | Actionable list |
| Reusable procedures | `orchestration/runtime/workflows/` or `capabilities/runtime/commands/` | New file |

---

## Promotion Process

### 1. Identify Mature Content

Review `ideation/scratchpad/` for content that is:

- Validated (not speculation)
- Actionable (agents can use it)
- Stable (unlikely to change soon)

### 2. Distill, Don't Copy

**Rule:** Never copy raw scratch verbatim. Always summarize and distill.

| Raw Scratch | Distilled for Agent |
|-------------|---------------------|
| Long exploration of options with pros/cons | Decision summary + chosen option + key rationale |
| Stream-of-consciousness research | Structured findings with clear conclusions |
| "I think maybe we should..." | "Use X approach because Y" |

### 3. Create or Update Destination Files

If the destination file doesn't exist, create it:

```bash
# Example: create next.md if missing
touch .harmony/continuity/next.md
```

### 4. Add Distilled Content

Follow the format conventions of the destination file:

**For `cognition/runtime/context/decisions.md`:**

```markdown
| ID | Decision | Choice | Rationale | Date |
|----|----------|--------|-----------|------|
| D00X | [Topic] | [Choice] | [Why] | YYYY-MM-DD |
```

**For `cognition/runtime/context/constraints.md`:**

```markdown
| Constraint | Implication | Reason |
|------------|-------------|--------|
| [Rule] | [What it means] | [Why it exists] |
```

**For `cognition/runtime/context/glossary.md`:**

```markdown
| Term | Definition |
|------|------------|
| [Term] | [Meaning in this context] |
```

**For `continuity/next.md`:**

```markdown
## Next Actions

- [ ] [Actionable task with clear scope]
- [ ] [Another concrete step]
```

### 5. Update Scratch Status (Optional)

Mark promoted content in `ideation/scratchpad/` to avoid re-promoting:

```markdown
## Ideas

- ~~Idea about X~~ → promoted to decisions.md (2025-01-04)
```

Or move to a "promoted" section within the scratch file.

---

## Example Scenario

**Situation:** Human explored authentication approaches in `ideation/scratchpad/research.md`

**Before (in `ideation/scratchpad/research.md`):**

```markdown
## Auth Options

Looked at JWT vs session-based. JWT is stateless but tokens can't be revoked
easily. Session-based needs Redis or similar. Team already uses Redis for
caching so session-based makes more sense. Also aligns with security team
preference for revocable sessions.

Maybe we should also consider...
[more exploration]
```

**After promotion (in `cognition/runtime/context/decisions.md`):**

```markdown
| ID | Decision | Choice | Rationale | Date |
|----|----------|--------|-----------|------|
| D005 | Authentication strategy | Session-based | Redis already in use; aligns with security team; sessions are revocable | 2025-01-04 |
```

---

## Autonomy Note

This workflow is **human-initiated**. Agents assist only when explicitly directed to help with the promotion.

A human decides:

- When content is ready to promote
- What to distill from the raw notes
- Where the distilled content goes

An agent may help:

- Draft the distilled summary (when asked)
- Format content for the destination file
- Identify which destination file is appropriate

---

## See Also

- [`.harmony/ideation/scratchpad/README.md`](../../../../ideation/scratchpad/README.md) — Human-led zone (includes inbox, archive, projects)
- [`.harmony/START.md`](../../../../START.md) — Visibility rules and routing

## Required Outcome

- [ ] Mature scratchpad content is distilled rather than copied verbatim
- [ ] Destination artifact is identified and updated
- [ ] Promotion result is understandable to a future agent or operator
