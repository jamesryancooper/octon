---
title: Locality
description: Context lives close to where it's needed. Place guidance, configuration, and knowledge at the level where it's most relevant.
pillar: Focus, Continuity
status: Active
---

# Locality

> Context lives close to where it's needed. Place guidance, configuration, and knowledge at the level where it's most relevant.

## What This Means

Locality is an information architecture principle: knowledge, configuration, and guidance should be placed as close as possible to where they're used. Rather than centralizing everything in one location, distribute context to the domains, features, and harnesses where it applies.
Normative facts are declared once authoritatively; local copies are projections/derivations that must link to the source and must not restate norms.

This principle shapes Octon's harness architecture:
- Domain-specific `.octon/` directories contain domain-specific guidance
- Skills live near the code they operate on
- Configuration inherits from parent to child, not scattered globally
- Agents load only the context relevant to their current location

## Why It Matters

### Pillar Alignment: Focus through Absorbed Complexity

The Focus pillar promises "cognitive bandwidth freed for what matters." Locality delivers this by:

- **Reducing noise**: Agents and developers see only relevant context
- **Scoping decisions**: Domain-specific rules don't pollute other domains
- **Enabling specialization**: Each area can have tailored workflows, checklists, and conventions

### Pillar Alignment: Continuity through Institutional Memory

The Continuity pillar captures knowledge durably. Locality ensures this knowledge is:

- **Discoverable**: Look in the harness for that domain's knowledge
- **Maintainable**: Domain experts own their domain's context
- **Relevant**: Context doesn't become stale because it's used regularly

### Token Efficiency

In agentic workflows, locality directly impacts performance:

```
Global context (everything loaded): ~50,000 tokens
Local context (harness only):        ~2,000 tokens
```

Agents working in a specific domain load ~2,000 tokens of relevant context instead of ~50,000 tokens of everything. This leaves room for actual work.

## In Practice

### The Single-Root Architecture

Octon implements locality through a single `.octon/` directory organized by capability:

| Category | Path | Content |
| -------- | ---- | ------- |
| Cognition | `cognition/runtime/context/` | Decisions, lessons, glossary, dependencies |
| Continuity | `continuity/` | Progress log, tasks, entities |
| Quality | `assurance/` | Completion checklists, session-exit |
| Orchestration | `orchestration/` | Workflows, missions |
| Capabilities | `capabilities/` | Skills, commands |
| Scaffolding | `scaffolding/` | runtime, governance, practices |

Portability is declared via `octon.yml` metadata — it specifies which paths are reusable framework assets vs. project-specific state.

### Hierarchical Harness Model

Harnesses can nest at any level of the repository:

```
repo/
├── .octon/              # Root harness
├── packages/
│   └── auth/
│       └── .octon/      # Auth-specific harness
└── apps/
    └── web/
        └── .octon/      # Web app harness
```

### Scope Authority

Locality includes boundaries. The repo-root harness follows strict scope rules:

| Boundary | Allowed | Example |
|----------|---------|---------|
| Within repository | ✅ Write where policy allows | Root harness can maintain repo-wide context and declared outputs |
| Outside repository | ❌ No access | Harness artifacts do not write outside repo root |

### ✅ Do

**Place domain-specific guidance in the repo-root harness under domain-specific paths:**

```
.octon/
├── cognition/runtime/context/
│   └── billing-glossary.md    # Billing terminology
├── assurance/practices/
│   └── payment-flow.md        # Billing-specific checklist
└── orchestration/runtime/workflows/billing/
    └── ...
```

**Check for the repo-root harness on directory entry:**

```markdown
<!-- Agent behavior -->
When entering a directory:
1. Resolve the repository root
2. Read `/.octon/START.md` for orientation
3. Load domain-specific context from repo-root harness paths as needed
```

**Scope context to reduce noise:**

```yaml
# Good: Domain-specific skill configuration
# .octon/capabilities/runtime/skills/registry.yml
skills:
  - id: security-audit
    input_paths:
      - packages/auth/src/**/*.ts
    output_path: .octon/capabilities/runtime/skills/outputs/
```

### ❌ Don't

**Don't centralize all configuration:**

```
# Bad: Everything in root
.octon/
├── auth-conventions.md
├── billing-conventions.md
├── web-conventions.md
├── auth-assurance/
├── billing-assurance/
└── ...
```

**Don't invent alternate harness roots:**

```typescript
// Bad: Create ad hoc local harness files outside the repo root
import { billingContext } from '../../billing/.octon/cognition/runtime/context';

// Good: Keep domain-specific context under the repo-root harness
import { billingContext } from '../../../.octon/cognition/runtime/context/billing-glossary.md';
```

**Don't duplicate shared content in multiple local harness roots:**

```
# Bad: Same content copied everywhere
.octon/cognition/runtime/context/auth.md
.octon/cognition/runtime/context/billing.md
.octon/cognition/runtime/context/web.md

# Good: Keep domain-specific additions in distinct repo-root files
.octon/cognition/runtime/context/billing.md
```

## Implementation Patterns

### Harness Discovery

Agents discover the repo-root harness from the current repository:

```
Current: /repo/packages/auth/src/handlers/login.ts

Resolution chain:
1. Resolve repository root: /repo/
2. Load active harness: /repo/.octon/
```

### Context Composition

Repo-root context composes shared and domain-specific files:

```yaml
# Effective context for packages/auth/
sources:
  - .octon/cognition/runtime/context/tools.md
  - .octon/cognition/runtime/context/compaction.md
  - .octon/cognition/runtime/context/decisions.md
  - .octon/cognition/runtime/context/auth-decisions.md
  - .octon/cognition/runtime/context/auth-glossary.md
```

### Progress Isolation

The root harness tracks progress for the repository and its domains:

```
.octon/continuity/
├── log.md         # Repository session log
└── tasks.json     # Repository task list

packages/billing/.octon/continuity/
├── log.md         # Billing-specific session log
└── tasks.json     # Billing-specific task list
```

This enables parallel workstreams without pollution.

### Missions as Scoped Work

Missions inherit locality principles:

```
.octon/orchestration/runtime/missions/
└── add-mfa/
    ├── brief.md       # Mission scope
    ├── continuity/
    │   ├── log.md     # Mission-specific log
    │   └── tasks.json # Mission-specific tasks
    └── context/       # Mission-specific context
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Progressive Disclosure | Locality scopes what's disclosed; disclosure layers what's loaded |
| Single Source of Truth | Local harnesses reference shared sources, not duplicate them |
| Complexity Calibration | Locality reduces complexity by scoping context proportionally to actual work |
| Deny-by-Default | Scope boundaries enforce access control |

## When to Create a Harness

Use the decision heuristic:

> *"Will an agent work here across multiple sessions?"*

**Create a harness when:**
- Domain has unique conventions or terminology
- Multiple missions will operate in this area
- Domain experts need to capture institutional knowledge
- Different checklists or workflows apply

**Don't create a harness when:**
- One-off work in an area
- No domain-specific guidance needed
- Parent harness context is sufficient

## Anti-Pattern: Global Soup

The primary failure mode of violating locality is **global soup** — all context mixed together, forcing agents to load everything to find anything.

Signs of global soup:
- Single massive `.octon/` at root with all domain content
- Agents loading 50,000+ tokens of context
- Domain-specific rules buried in generic files
- "Which conventions apply here?" confusion

Prevention:
- Create domain harnesses for distinct areas
- Keep harnesses focused (~2,000 tokens target)
- Use inheritance instead of duplication

## Related Documentation

- [Harness Architecture](../../_meta/architecture/README.md) — Full harness specification
- [Focus Pillar](../pillars/focus.md) — Cognitive bandwidth through locality
- [Continuity Pillar](../pillars/continuity.md) — Durable, discoverable knowledge
- [Skills Architecture](../../../capabilities/_meta/architecture/architecture.md) — Locality in skill design
