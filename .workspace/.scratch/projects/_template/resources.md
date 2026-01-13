# Research Resources: [topic]

Workspace resources useful for this research project.

---

## Assistants

Invoke these specialists when you need focused help:

| Assistant | When to Use | Example |
|-----------|-------------|---------|
| `@reviewer` | Review findings for clarity, gaps, contradictions | `@reviewer Check my findings summary for logical gaps` |
| `@docs` | Organize notes into structured documentation | `@docs Help structure these raw notes` |
| `@refactor` | Restructure project files or consolidate notes | `@refactor Consolidate these overlapping notes` |

---

## Prompts

Reference these prompts for common research tasks:

| Prompt | Purpose |
|--------|---------|
| `.workspace/prompts/research/synthesize-findings.md` | Consolidate scattered notes into coherent insights |
| `.workspace/prompts/research/analyze-sources.md` | Systematically extract insights from source materials |
| `.workspace/prompts/research/compare-alternatives.md` | Evaluate options against defined criteria |
| `.workspace/prompts/research/identify-gaps.md` | Find holes in current research coverage |
| `.workspace/prompts/research/prepare-promotion.md` | Ready findings for promotion to workspace |

---

## Context References

Consult these for background knowledge:

| Resource | Why It's Relevant |
|----------|-------------------|
| `.workspace/context/glossary.md` | Domain terminology definitions |
| `.workspace/context/decisions.md` | Existing decisions to build on or challenge |
| `.workspace/context/lessons.md` | Anti-patterns and failures to avoid |
| `.workspace/context/constraints.md` | Non-negotiable boundaries |

---

## Workflows

| Workflow | When to Use |
|----------|-------------|
| `.workspace/workflows/promote-from-scratch.md` | Promote mature findings to agent-facing locations |

---

## Skills

Composable capabilities with defined I/O contracts and audit trails.

### Available Skills

| Skill | Command | Research Phase | Use For |
|-------|---------|----------------|---------|
| [research-synthesizer](.workspace/skills/research-synthesizer/) | `/synthesize-research` | Synthesis | Consolidate scattered notes into coherent findings |

### Invocation

**Direct command (recommended):**
```text
/synthesize-research .scratch/projects/[this-project]/
```

**Generic invocation:**
```text
/use-skill research-synthesizer .scratch/projects/[this-project]/
```

### Skills vs Prompts

| Use Skills When | Use Prompts When |
|-----------------|------------------|
| Need structured, repeatable output | Need flexible, judgment-based guidance |
| Want audit trail (run logs) | One-off exploration |
| Chaining operations (pipelines) | Context-dependent decisions |
| Defined inputs → defined outputs | Variable inputs/outputs |

### Skill Outputs

Skills write to `.workspace/skills/outputs/`:

| Output Location | Content |
|-----------------|---------|
| `outputs/drafts/` | Initial synthesis documents |
| `outputs/refined/` | Processed/enhanced outputs |
| `logs/runs/` | Execution audit logs |

**Referencing skill outputs:**
After running a skill, reference outputs in your project log:
```markdown
## [Date]
**Skill run:** `/synthesize-research` on this project
**Output:** `.workspace/skills/outputs/drafts/[topic]-synthesis.md`
**Next:** Review synthesis and update findings
```

---

## Project-Specific Resources

*Add any topic-specific resources here as you discover them:*

### External References
- [Resource 1]
- [Resource 2]

### Related Codebase Areas
- [Path 1]
- [Path 2]

### Domain Experts / Contacts
- [Contact 1]
