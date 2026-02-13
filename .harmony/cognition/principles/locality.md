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

This principle shapes Harmony's harness architecture:
- Domain-specific `.harmony/` directories contain domain-specific guidance
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

Harmony implements locality through a single `.harmony/` directory organized by capability:

| Category | Path | Content |
| -------- | ---- | ------- |
| Cognition | `cognition/context/` | Decisions, lessons, glossary, dependencies |
| Continuity | `continuity/` | Progress log, tasks, entities |
| Quality | `quality/` | Completion checklists, session-exit |
| Orchestration | `orchestration/` | Workflows, missions |
| Capabilities | `capabilities/` | Skills, commands |
| Scaffolding | `scaffolding/` | Templates, prompts, examples |

Portability is declared via `harmony.yml` metadata — it specifies which paths are reusable framework assets vs. project-specific state.

### Hierarchical Harness Model

Harnesses can nest at any level of the repository:

```
repo/
├── .harmony/              # Root harness
├── packages/
│   └── auth/
│       └── .harmony/      # Auth-specific harness
└── apps/
    └── web/
        └── .harmony/      # Web app harness
```

### Scope Authority

Locality includes boundaries. Harnesses follow strict scope rules:

| Direction | Allowed | Example |
|-----------|---------|---------|
| Down (descendants) | ✅ Write | Root harness can configure child harnesses |
| Up (ancestors) | ❌ Read only | Child cannot modify parent's context |
| Sideways (siblings) | ❌ No access | `packages/auth/` cannot access `packages/billing/` harness |

### ✅ Do

**Place domain-specific guidance in domain harnesses:**

```
packages/billing/
├── .harmony/
│   ├── START.md           # Billing-specific orientation
│   ├── conventions.md     # Billing coding standards
│   ├── quality/
│   │   └── payment-flow.md  # Billing-specific checklist
│   └── cognition/context/
│       └── glossary.md    # Billing terminology
└── src/
    └── ...
```

**Use inheritance for shared defaults:**

```yaml
# .harmony/scaffolding/templates/harmony/conventions.md (shared)
- Use TypeScript strict mode
- Format with Prettier

# packages/billing/.harmony/conventions.md (local override)
- Use TypeScript strict mode
- Format with Prettier
- Additional: All money values use Decimal.js  # Domain-specific
```

**Check for local harness on directory entry:**

```markdown
<!-- Agent behavior -->
When entering a directory:
1. Check if .harmony/ exists
2. If yes, read START.md for orientation
3. If no, use nearest ancestor harness
```

**Scope context to reduce noise:**

```yaml
# Good: Domain-specific skill configuration
# packages/auth/.harmony/capabilities/skills/registry.yml
skills:
  - id: security-audit
    input_paths:
      - ./src/**/*.ts  # Only auth code
    output_path: ./.harmony/capabilities/skills/outputs/
```

### ❌ Don't

**Don't centralize all configuration:**

```
# Bad: Everything in root
.harmony/
├── auth-conventions.md
├── billing-conventions.md
├── web-conventions.md
├── auth-quality/
├── billing-quality/
└── ...
```

**Don't reach across harness boundaries:**

```typescript
// Bad: Cross-harness access
import { billingContext } from '../../billing/.harmony/cognition/context';

// Good: Request through proper channels or shared foundation
import { sharedContext } from '../../../.harmony/cognition/context';
```

**Don't duplicate shared content in every harness:**

```
# Bad: Same content copied everywhere
packages/auth/.harmony/conventions.md      # Copy of shared
packages/billing/.harmony/conventions.md   # Copy of shared
packages/web/.harmony/conventions.md       # Copy of shared

# Good: Inherit shared, override only what's different
packages/auth/.harmony/conventions.md      # "Extends shared, plus: ..."
```

## Implementation Patterns

### Harness Discovery

Agents discover harnesses using nearest-ancestor resolution (like git finding `.git/`):

```
Current: /repo/packages/auth/src/handlers/login.ts

Resolution chain:
1. /repo/packages/auth/src/handlers/.harmony/ → not found
2. /repo/packages/auth/src/.harmony/ → not found
3. /repo/packages/auth/.harmony/ → FOUND, use this
4. (fallback) /repo/.harmony/
```

### Context Composition

Local context composes with shared context:

```yaml
# Effective context for packages/auth/
sources:
  - .harmony/cognition/context/tools.md           # Shared tools knowledge
  - .harmony/cognition/context/compaction.md      # Shared compaction rules
  - .harmony/cognition/context/decisions.md     # Root decisions
  - packages/auth/.harmony/cognition/context/decisions.md  # Auth decisions (overrides)
  - packages/auth/.harmony/cognition/context/glossary.md   # Auth-specific terms
```

### Progress Isolation

Each harness tracks its own progress:

```
packages/auth/.harmony/continuity/
├── log.md         # Auth-specific session log
└── tasks.json     # Auth-specific task list

packages/billing/.harmony/continuity/
├── log.md         # Billing-specific session log
└── tasks.json     # Billing-specific task list
```

This enables parallel workstreams without pollution.

### Missions as Scoped Work

Missions inherit locality principles:

```
.harmony/orchestration/missions/
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
| Simplicity Over Complexity | Locality reduces complexity by scoping context |
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
- Single massive `.harmony/` at root with all domain content
- Agents loading 50,000+ tokens of context
- Domain-specific rules buried in generic files
- "Which conventions apply here?" confusion

Prevention:
- Create domain harnesses for distinct areas
- Keep harnesses focused (~2,000 tokens target)
- Use inheritance instead of duplication

## Related Documentation

- [Harness Architecture](../architecture/harness/README.md) — Full harness specification
- [Focus Pillar](../pillars/focus.md) — Cognitive bandwidth through locality
- [Continuity Pillar](../pillars/continuity.md) — Durable, discoverable knowledge
- [Skills Architecture](../architecture/harness/skills/architecture.md) — Locality in skill design
