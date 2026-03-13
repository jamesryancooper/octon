---
title: Harness Context
description: Background knowledge stored in .octon/cognition/runtime/context/ including decisions, lessons, and domain knowledge
---

# Harness Context

The `context/` directory contains **background knowledge** that agents need to work effectively in the harness's domain.

## Location

```text
.octon/cognition/runtime/context/
├── decisions.md     # Agent-readable decision summaries
├── lessons.md       # Anti-patterns and failures to avoid
├── glossary.md      # Domain-specific terminology
├── dependencies.md  # External dependencies and integrations
├── constraints.md   # Technical or business constraints
├── compaction.md    # Token compaction strategies (optional)
└── tools.md         # Available tools reference (optional)
```

---

## When to Use Context

| Content Type | Put in `context/` |
|--------------|-------------------|
| Key decisions (agent-readable) | ✅ Yes |
| Lessons learned / anti-patterns | ✅ Yes |
| Domain terminology | ✅ Yes |
| External dependencies | ✅ Yes |
| Technical constraints | ✅ Yes |
| Token compaction strategies | ✅ Yes |
| Available tools reference | ✅ Yes |
| How-to instructions | ❌ No (use prompts/workflows) |
| Full decision rationale | ❌ No (use `docs/decisions/` or `ideation/scratchpad/`) |

---

## `decisions.md`

Agent-readable summaries of key decisions that constrain work. Full ADRs with extended rationale can go in `docs/decisions/` or `ideation/scratchpad/` for drafts.

### Decisions Format

```markdown
# Decisions

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D001 | State format | JSON over YAML | Must parse without dependencies | 2024-01-15 |
| D002 | Token budget | ~2,000 target | Leave room for actual work | 2024-01-15 |
```

### Rules

- MUST include only decisions that affect agent behavior
- MUST be actionable (agent can apply the constraint)
- SHOULD reference full ADR in `docs/decisions/` if one exists
- MAY include superseded decisions section

---

## `lessons.md`

Anti-patterns and failures to avoid. Prevents agents from repeating past mistakes.

### Lessons Format

```markdown
# Lessons Learned

## Anti-Patterns

| Pattern | Why It Failed | Do Instead |
|---------|---------------|------------|
| Reading entire large files | Blows token budget | Use targeted searches |
| Skipping progress updates | Breaks continuity | Always update before session end |

## Failed Approaches

| Date | Attempted | Outcome | Learning |
|------|-----------|---------|----------|
| 2024-01-10 | Nested workflows | Lost track of state | Keep to 3-7 steps |
```

### Rules

- MUST include actionable "Do Instead" for anti-patterns
- SHOULD add entries when failures occur
- MAY reference related tasks or sessions in `continuity/log.md`

---

## `glossary.md`

Domain-specific terms and their definitions.

### Format

```markdown
# Glossary

| Term | Definition |
|------|------------|
| Harness | The `.octon` support structure |
| Boot sequence | Steps to orient and begin work |
| Cold start | First session without prior context |
```

### Rules

- MUST define terms consistently (no synonym drift)
- SHOULD use table format for scannability
- SHOULD be minimal (only terms needed for correct action)

---

## `dependencies.md`

External systems, APIs, or packages the harness interacts with.

### Dependencies Format

```markdown
# Dependencies

## External APIs

| API | Purpose | Docs |
|-----|---------|------|
| GitHub API | PR management | [link] |

## Packages

| Package | Version | Purpose |
|---------|---------|---------|
| zod | ^3.22.0 | Schema validation |
```

---

## `constraints.md`

Technical or business rules that limit what can be done.

### Constraints Format

```markdown
# Constraints

## Technical

- Maximum file size: 100KB
- Required Node.js version: ≥18

## Business

- All changes require PR review
- No breaking changes to public API
```

---

## `compaction.md` (Optional)

Token compaction strategies and guidelines for keeping content within budget.

### Compaction Format

```markdown
# Token Compaction

## Strategies

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Table over prose | Multiple related items | Lists → tables |
| Abbreviations | Repeated terms | "harness" → "hs" in context |
| Remove examples | After pattern is clear | Keep 1, remove 2-3 |
```

### Rules

- SHOULD include only strategies relevant to this harness
- MAY reference specific files that need compaction
- SHOULD prioritize actionable techniques over theory

---

## `tools.md` (Optional)

Reference of available tools and capabilities for agents working in this harness.

### Tools Format

```markdown
# Available Tools

## File Operations

| Tool | Purpose | Usage |
|------|---------|-------|
| read_file | Read file contents | Read specific files or ranges |
| search_replace | Edit files | Replace text in files |

## Search

| Tool | Purpose | Usage |
|------|---------|-------|
| grep | Find text | Search for patterns |
| codebase_search | Semantic search | Find by meaning |
```

### Rules

- SHOULD list only tools relevant to this harness's domain
- SHOULD include common usage patterns
- MAY include harness-specific tool configurations

---

## Token Budget

Context files should be **minimal**. Only include information an agent needs to act correctly. Extended explanations can go in `docs/` or `ideation/scratchpad/`.

See `.octon/engine/governance/rules/adapters/cursor/octon/RULE.md` for
the authoritative token budget table.

---

## See Also

- [README.md](./README.md) — Canonical harness structure
- [Conventions](../../../conventions.md) — Style rules (different from context)
