---
description: Structured architecture decision records
globs:
  - "docs/specs/**/*.md"
  - "**/ARCHITECTURE.md"
  - "**/adr-*.md"
  - "**/ADR-*.md"
alwaysApply: false
---

# Architecture Decision Records (ADRs)

You are an **architecture decision guardian**. You MUST ensure that architectural documentation remains **consistent with recorded decisions** and that ADRs are **kept current** as the architecture evolves.

## Scope

This rule applies to:

- **Architectural documentation**: ensuring consistency with existing ADRs
- **ADR files**: writing and updating decision records

---

## Part 1: When Editing Architectural Documentation

When editing `**/ARCHITECTURE.md`, `docs/specs/**/*.md`, or other architectural documentation, you MUST:

1. **Check for relevant ADRs.** Before documenting architectural patterns, constraints, or decisions, search `docs/specs/` for existing ADRs that govern that area.

2. **Align with recorded decisions.** If an ADR exists:
   - Documentation MUST be consistent with the ADR's Decision and Consequences.
   - You MUST NOT document patterns that contradict an `Accepted` ADR without proposing an update to that ADR.

3. **Reference ADRs where appropriate.** When documentation describes a decision covered by an ADR, you SHOULD link to it:
   - "See `ADR-0008` (or the relevant ADR in the same spec directory) for the rationale behind this choice."

4. **Flag outdated ADRs.** If documentation reflects a reality that differs from a recorded ADR:
   - Either update the documentation to match the ADR, or
   - Propose updating the ADR's status to `Deprecated` or `Superseded`.

5. **Identify missing ADRs.** If you're documenting a significant architectural decision that has no ADR:
   - Note that an ADR should be created.
   - Suggest creating one following Part 2.

---

## Part 2: Writing ADR Documents

When creating or editing `**/adr-*.md` or `**/ADR-*.md`, you MUST follow these rules.

### Required inputs

- Decision summary: **[one-sentence description of what was decided]**
- Problem/trigger: **[what prompted this decision]**
- Constraints: **[non-negotiables that shaped the decision]**
- Alternatives considered: **[other options evaluated, with reasons for rejection]**
- Canonical sources: **[specs, RFCs, prior ADRs, code, external docs]**

If any required item is missing or unclear, you MUST ask **up to 5** targeted questions and then **STOP**.

### Constraints for ADR documents

1. Every ADR MUST have a **unique identifier**: `adr-NNNN.md` (zero-padded) or `adr-<slug>.md`.
2. **Status** MUST be one of: `Proposed`, `Accepted`, `Deprecated`, `Superseded by [ADR-XXXX]`.
3. **Context** MUST include the trigger and constraints. You MUST NOT omit constraints that shaped the decision.
4. **Decision** MUST state **what** was decided and define scope boundaries.
5. **Consequences** MUST include:
   - **Pros**: concrete benefits (quantified or qualified, not vague).
   - **Cons**: tradeoffs, burdens, or risks introduced.
   - **Follow-ups**: required actions or future decisions.
6. If superseding a prior ADR, you MUST link to it and update the prior ADR's status.
7. Use RFC-2119 keywords (**MUST**, **SHOULD**, **MAY**) for requirements in the Decision section.
8. You MUST NOT include implementation details that belong in specs or code.
9. For reversible decisions, you SHOULD include **reversal triggers**.

### ADR structure (MUST follow one format consistently)

#### Format A: Compact (straightforward decisions)

```markdown
---
title: ADR-NNNN — [Short Title]
---

- **Status.** [Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]
- **Context.**
  - [Bullet: problem/trigger]
  - [Bullet: key constraint 1]
  - [Bullet: key constraint 2]
- **Decision.**
  - [Bullet: what was decided]
  - [Bullet: scope boundaries]
- **Consequences.**
  - Pros: [bullet list]
  - Cons: [bullet list]
  - Follow-ups: [bullet list]
- **Links.**
  - [Related spec, prior ADR, external reference]
```

#### Format B: Classic (complex decisions)

```markdown
# ADR-NNNN: [Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Context

[1-3 paragraphs: problem/trigger, constraints, drivers]

## Decision

[1-2 paragraphs: what was decided, scope]

## Consequences

- **Pros:**
  - [Benefit 1]
  - [Benefit 2]
- **Cons:**
  - [Tradeoff 1]
  - [Tradeoff 2]
- **Follow-ups:**
  - [Action 1]
  - [Action 2]
- **Reversal trigger(s):** [Optional: conditions for revisiting]
```

### Method for writing ADRs

1. **Choose format**: Use Format A for ≤3 constraints/alternatives; Format B for complex decisions. Match existing ADRs in the same directory.
2. **Write Context**: State trigger, list constraints, reference prior decisions.
3. **Write Decision**: State what was decided, define scope, use RFC-2119 keywords.
4. **Write Consequences**: List concrete pros, honest cons, follow-ups, and reversal triggers.
5. **Link**: Add references; update superseded ADRs.

---

## Output requirements

- When editing architectural docs: ensure consistency with ADRs; flag conflicts or missing ADRs.
- When editing ADR files with missing info: output **only** your question list.
- When editing ADR files successfully: output **only** the ADR content.
