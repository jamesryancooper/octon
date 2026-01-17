---
title: Locality
description: Context lives close to where it's needed. Place guidance, configuration, and knowledge at the level where it's most relevant.
pillar: Focus, Continuity
status: Active
---

# Locality

> Context lives close to where it's needed. Place guidance, configuration, and knowledge at the level where it's most relevant.

## What This Means

Locality is an information architecture principle: knowledge, configuration, and guidance should be placed as close as possible to where they're used. Rather than centralizing everything in one location, distribute context to the domains, features, and workspaces where it applies.

This principle shapes Harmony's workspace architecture:
- Domain-specific `.workspace/` directories contain domain-specific guidance
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

- **Discoverable**: Look in the workspace for that domain's knowledge
- **Maintainable**: Domain experts own their domain's context
- **Relevant**: Context doesn't become stale because it's used regularly

### Token Efficiency

In agentic workflows, locality directly impacts performance:

```
Global context (everything loaded): ~50,000 tokens
Local context (workspace only):      ~2,000 tokens
```

Agents working in a specific domain load ~2,000 tokens of relevant context instead of ~50,000 tokens of everything. This leaves room for actual work.

## In Practice

### The Two-Layer Architecture

Harmony implements locality through two layers:

| Layer | Location | Scope | Content |
|-------|----------|-------|---------|
| Shared | `.harmony/` | All workspaces | Generic infrastructure, templates, shared skills |
| Local | `.workspace/` | Current domain | Project-specific context, progress, domain workflows |

Resolution rule: **Local overrides shared.** Agents check `.workspace/` first, then fall back to `.harmony/`.

### Hierarchical Workspace Model

Workspaces can nest at any level of the repository:

```
repo/
├── .harmony/              # Shared foundation
├── .workspace/            # Root workspace
├── packages/
│   └── auth/
│       └── .workspace/    # Auth-specific workspace
└── apps/
    └── web/
        └── .workspace/    # Web app workspace
```

### Scope Authority

Locality includes boundaries. Workspaces follow strict scope rules:

| Direction | Allowed | Example |
|-----------|---------|---------|
| Down (descendants) | ✅ Write | Root workspace can configure child workspaces |
| Up (ancestors) | ❌ Read only | Child cannot modify parent's context |
| Sideways (siblings) | ❌ No access | `packages/auth/` cannot access `packages/billing/` workspace |

### ✅ Do

**Place domain-specific guidance in domain workspaces:**

```
packages/billing/
├── .workspace/
│   ├── START.md           # Billing-specific orientation
│   ├── conventions.md     # Billing coding standards
│   ├── checklists/
│   │   └── payment-flow.md  # Billing-specific checklist
│   └── context/
│       └── glossary.md    # Billing terminology
└── src/
    └── ...
```

**Use inheritance for shared defaults:**

```yaml
# .harmony/templates/workspace/conventions.md (shared)
- Use TypeScript strict mode
- Format with Prettier

# packages/billing/.workspace/conventions.md (local override)
- Use TypeScript strict mode
- Format with Prettier
- Additional: All money values use Decimal.js  # Domain-specific
```

**Check for local workspace on directory entry:**

```markdown
<!-- Agent behavior -->
When entering a directory:
1. Check if .workspace/ exists
2. If yes, read START.md for orientation
3. If no, use nearest ancestor workspace
```

**Scope context to reduce noise:**

```yaml
# Good: Domain-specific skill configuration
# packages/auth/.workspace/skills/registry.yml
skills:
  - id: security-audit
    input_paths:
      - ./src/**/*.ts  # Only auth code
    output_path: ./.workspace/skills/outputs/
```

### ❌ Don't

**Don't centralize all configuration:**

```
# Bad: Everything in root
.workspace/
├── auth-conventions.md
├── billing-conventions.md
├── web-conventions.md
├── auth-checklists/
├── billing-checklists/
└── ...
```

**Don't reach across workspace boundaries:**

```typescript
// Bad: Cross-workspace access
import { billingContext } from '../../billing/.workspace/context';

// Good: Request through proper channels or shared foundation
import { sharedContext } from '../../../.harmony/context';
```

**Don't duplicate shared content in every workspace:**

```
# Bad: Same content copied everywhere
packages/auth/.workspace/conventions.md      # Copy of shared
packages/billing/.workspace/conventions.md   # Copy of shared
packages/web/.workspace/conventions.md       # Copy of shared

# Good: Inherit shared, override only what's different
packages/auth/.workspace/conventions.md      # "Extends shared, plus: ..."
```

## Implementation Patterns

### Workspace Discovery

Agents discover workspaces using nearest-ancestor resolution (like git finding `.git/`):

```
Current: /repo/packages/auth/src/handlers/login.ts

Resolution chain:
1. /repo/packages/auth/src/handlers/.workspace/ → not found
2. /repo/packages/auth/src/.workspace/ → not found
3. /repo/packages/auth/.workspace/ → FOUND, use this
4. (fallback) /repo/.workspace/
5. (fallback) /repo/.harmony/
```

### Context Composition

Local context composes with shared context:

```yaml
# Effective context for packages/auth/
sources:
  - .harmony/context/tools.md           # Shared tools knowledge
  - .harmony/context/compaction.md      # Shared compaction rules
  - .workspace/context/decisions.md     # Root decisions
  - packages/auth/.workspace/context/decisions.md  # Auth decisions (overrides)
  - packages/auth/.workspace/context/glossary.md   # Auth-specific terms
```

### Progress Isolation

Each workspace tracks its own progress:

```
packages/auth/.workspace/progress/
├── log.md         # Auth-specific session log
└── tasks.json     # Auth-specific task list

packages/billing/.workspace/progress/
├── log.md         # Billing-specific session log
└── tasks.json     # Billing-specific task list
```

This enables parallel workstreams without pollution.

### Missions as Scoped Work

Missions inherit locality principles:

```
.workspace/missions/
└── add-mfa/
    ├── brief.md       # Mission scope
    ├── progress/
    │   ├── log.md     # Mission-specific log
    │   └── tasks.json # Mission-specific tasks
    └── context/       # Mission-specific context
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Progressive Disclosure | Locality scopes what's disclosed; disclosure layers what's loaded |
| Single Source of Truth | Local workspaces reference shared sources, not duplicate them |
| Simplicity Over Complexity | Locality reduces complexity by scoping context |
| Deny-by-Default | Scope boundaries enforce access control |

## When to Create a Workspace

Use the decision heuristic:

> *"Will an agent work here across multiple sessions?"*

**Create a workspace when:**
- Domain has unique conventions or terminology
- Multiple missions will operate in this area
- Domain experts need to capture institutional knowledge
- Different checklists or workflows apply

**Don't create a workspace when:**
- One-off work in an area
- No domain-specific guidance needed
- Parent workspace context is sufficient

## Anti-Pattern: Global Soup

The primary failure mode of violating locality is **global soup** — all context mixed together, forcing agents to load everything to find anything.

Signs of global soup:
- Single massive `.workspace/` at root with all domain content
- Agents loading 50,000+ tokens of context
- Domain-specific rules buried in generic files
- "Which conventions apply here?" confusion

Prevention:
- Create domain workspaces for distinct areas
- Keep workspaces focused (~2,000 tokens target)
- Use inheritance instead of duplication

## Related Documentation

- [Workspace Architecture](../architecture/workspaces/README.md) — Full workspace specification
- [Focus Pillar](../pillars/focus.md) — Cognitive bandwidth through locality
- [Continuity Pillar](../pillars/continuity.md) — Durable, discoverable knowledge
- [Skills Architecture](../architecture/workspaces/skills/architecture.md) — Locality in skill design
