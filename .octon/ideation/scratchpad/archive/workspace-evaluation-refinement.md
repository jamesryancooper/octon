# Evaluation & Refinement: Localized Agent Harness (`.workspace`)

## Context

You are evaluating the `.workspace` directory concept—a localized agent harness designed to provide AI agents with everything they need to work effectively on a specific area of a codebase.

**Core tension:** Agents operate in limited context windows. Every file, every section, every word in `.workspace` consumes tokens. The harness must be **compact but complete**—providing maximum effectiveness with minimum overhead.

---

## Token Budget (Claude Opus 4.5)

Claude Opus 4.5 has a 200K token context window, with optimal performance in the 20K-80K range per request. The workspace harness should be a small fraction of this, leaving ample room for actual work.

| Metric | Target | Maximum |
|--------|--------|---------|
| **Total harness size** | ~3,000 tokens | 5,000 tokens |
| **Any single file** | ~500 tokens | 1,000 tokens |
| **Boot sequence files** (START.md, scope.md) | ~1,500 tokens combined | 2,000 tokens |

**Rationale:** A 3,000-token harness leaves 197K tokens for code, tool outputs, and conversation—more than sufficient for complex tasks while forcing discipline about what's truly essential.

---

## Content Separation: Agents vs. Humans

### `.workspace/` — Agent-Facing (Compact, Actionable)

Content that agents need to take correct action. Every line should answer "what do I do?" not "why does this exist?"

| Directory/File | Purpose | Token Budget |
|----------------|---------|--------------|
| `START.md` | Boot sequence, prerequisites, first actions | 300-500 |
| `scope.md` | Boundaries, in/out of scope, decision authority | 300-500 |
| `conventions.md` | Style rules, glossary, formatting standards | 300-500 |
| `agents/` | Task-specific prompts and workflows | 200-400 per task |
| `progress/log.md` | What's been done (append-only) | Variable |
| `progress/tasks.json` | Structured task list with status | Variable |
| `checklists/complete.md` | Definition of done, quality gates | 300-500 |

**Content style:** Terse. Lists over prose. Imperatives over explanations. Examples only when patterns are non-obvious.

### `.humans/` — Human-Facing (Explanatory, Contextual)

Content that helps humans understand, onboard, or make decisions. Agents should NOT read this directory unless explicitly instructed.

| Directory/File | Purpose |
|----------------|---------|
| `README.md` | What this workspace is, why it exists, design rationale |
| `onboarding.md` | How to get started as a human contributor |
| `decisions/` | ADRs, decision logs, historical context |
| `rationale/` | Explanations of "why" behind conventions and structure |
| `references/` | External sources, research, prior art |
| `examples/` | Detailed examples and reference implementations |

**Content style:** Conversational. Explanations welcome. Context and history preserved.

### Decision Criteria: Agent vs. Human Content

Ask these questions to determine where content belongs:

| Question | If YES → | If NO → |
|----------|----------|---------|
| Does an agent need this to complete a task? | `.workspace/` | `.humans/` |
| Is this actionable in the next 5 minutes? | `.workspace/` | `.humans/` |
| Would removing this cause an agent to make a mistake? | `.workspace/` | `.humans/` |
| Is this explaining "why" rather than "what" or "how"? | `.humans/` | `.workspace/` |
| Is this onboarding or educational content? | `.humans/` | `.workspace/` |
| Is this historical context or institutional memory? | `.humans/` | `.workspace/` |

---

## Evaluation Criteria

For each element in the `.workspace` structure, ask:

1. **Essentiality:** Does an agent *need* this to work effectively, or is it merely *nice to have*?
2. **Token efficiency:** Can this information be conveyed more concisely without losing utility?
3. **Redundancy:** Is this duplicated elsewhere? Can it be consolidated or referenced instead of repeated?
4. **Actionability:** Does this directly enable an agent to take correct action, or is it explanatory padding?
5. **Failure prevention:** Does this prevent a specific, observed failure mode? Which one?

---

## Questions to Answer

**Structure:**

- Which directories/files are essential? Which could be eliminated or merged?
- Is the hierarchy too deep? Could agents find what they need faster with a flatter structure?
- What's the minimum viable `.workspace` that still enables effective agent work?

**Content:**

- For each file type (START.md, scope.md, etc.): What's the essential information? What's filler?
- Can structured formats (JSON, YAML) replace prose where appropriate for faster parsing?
- What can be inferred by agents vs. what must be explicit?

**Trade-offs:**

- Where does conciseness sacrifice clarity?
- Where does completeness create bloat?
- What's the right granularity for progress tracking (too detailed = token waste; too sparse = lost continuity)?

---

## Refinement Goals

Produce a revised `.workspace` specification that:

1. **Fits in ~3,000 tokens** when fully populated for a typical area (max 5,000)
2. **Enables cold-start effectiveness** — an agent reading `.workspace` for the first time can begin useful work within one context window
3. **Prevents the top 3 agent failure modes:** premature completion, scope creep, broken continuity
4. **Requires no redundant reading** — each file serves a distinct, non-overlapping purpose
5. **Separates concerns** — agent-facing content in `.workspace/`, human-facing content in `.humans/`

---

## Output

1. List elements to **keep** (with justification)
2. List elements to **cut or merge** (with justification)
3. List elements to **move to `.humans/`** (with justification)
4. Propose a **minimal viable structure** for both directories
5. Identify any **gaps** — essential elements currently missing
