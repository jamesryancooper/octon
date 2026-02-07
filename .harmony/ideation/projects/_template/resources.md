# Project Resources: [topic]

Workspace resources useful for this project.

---

## Assistants

Invoke these specialists when you need focused help:

| Assistant | When to Use | Example |
|-----------|-------------|---------|
| `@reviewer` | Review findings for clarity, gaps, contradictions | `@reviewer Check my findings summary for logical gaps` |
| `@docs` | Organize notes into structured documentation | `@docs Help structure these raw notes` |
| `@refactor` | Restructure project files or consolidate notes | `@refactor Consolidate these overlapping notes` |

---

## Context References

Consult these for background knowledge:

| Resource | Why It's Relevant |
|----------|-------------------|
| `cognition/context/glossary.md` | Domain terminology definitions |
| `cognition/context/decisions.md` | Existing decisions to build on or challenge |
| `cognition/context/lessons.md` | Anti-patterns and failures to avoid |
| `cognition/context/constraints.md` | Non-negotiable boundaries |

---

## Skills

Composable capabilities with defined I/O contracts.

### Available Skills

| Skill | Command | Use For |
|-------|---------|---------|
| synthesize-research | `/synthesize-research` | Consolidate scattered notes into coherent findings |

### Invocation

**Direct command (recommended):**
```text
/synthesize-research projects/[this-project]/
```

### Skill Outputs

Skills write to `.harmony/capabilities/skills/outputs/`:

| Output Location | Content |
|-----------------|---------|
| `outputs/drafts/` | Initial synthesis documents |
| `outputs/refined/` | Processed/enhanced outputs |
| `logs/runs/` | Execution audit logs |

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
