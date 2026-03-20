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
- Domain-specific guidance lives under repo-root `.octon/` paths
- Skills live near the code they operate on
- Configuration stays in canonical repo-root files, not parent/child harness chains
- Agents load only the context relevant to their current location
- Durable scope identity is authored once under `instance/locality/**` and
  compiled into `generated/effective/locality/**`

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
| Cognition | `instance/cognition/context/shared/` | Decisions, lessons, glossary, dependencies |
| Scoped Cognition | `instance/cognition/context/scopes/<scope-id>/` | Durable scope-local context bound to a declared scope |
| Continuity | `state/continuity/{repo/,scopes/<scope-id>/}` | Repo-wide plus scope-local progress log, tasks, entities, and next actions |
| Quality | `framework/assurance/` | Completion checklists, session-exit |
| Orchestration | `framework/orchestration/runtime/workflows/` plus `instance/orchestration/missions/` | Shared workflows plus repo-owned missions |
| Capabilities | `framework/capabilities/` and `instance/capabilities/runtime/` | Portable capabilities plus repo-native runtime capability surfaces |
| Scaffolding | `framework/scaffolding/` | runtime, governance, practices |

Portability is declared via `octon.yml` metadata — it specifies which paths are reusable framework assets vs. project-specific state.

### Root-Owned Scope Registry

Octon implements locality through one repo-owned scope registry:

```text
.octon/instance/locality/
  manifest.yml
  registry.yml
  scopes/<scope-id>/scope.yml
```

The scope registry is the only authored source of truth for locality.
Generated runtime-facing locality views live under
`generated/effective/locality/**`, and invalid scope state quarantines under
`state/control/locality/quarantine.yml`.

In v1:

- each `scope_id` has exactly one `root_path`
- a target path resolves to zero or one active scope
- overlapping active scopes are invalid
- missions may reference scopes, but they do not define locality

### Single-Root Harness Topology

Each repository gets one repo-root harness. Sibling repositories or workspaces may each have their own repo-root harness, but each ancestor chain may contain only one `.octon/`.

```
workspace/
├── api-repo/
│   └── .octon/
└── web-repo/
    └── .octon/
```

Unsupported:

```
repo/
├── .octon/
└── packages/
    └── auth/
        └── .octon/
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
├── instance/cognition/context/shared/
│   └── billing-glossary.md    # Billing terminology
├── framework/assurance/practices/
│   └── payment-flow.md        # Billing-specific checklist
└── framework/orchestration/runtime/workflows/billing/
    └── ...
```

**Check for the repo-root harness on directory entry:**

```markdown
<!-- Agent behavior -->
When entering a directory:
1. Resolve the repository root
2. Read `/.octon/instance/bootstrap/START.md` for orientation
3. Load domain-specific context from repo-root harness paths as needed
```

**Scope context to reduce noise:**

```yaml
# Good: Domain-specific skill configuration
# .octon/framework/capabilities/runtime/skills/registry.yml
skills:
  - id: security-audit
    input_paths:
      - packages/auth/src/**/*.ts
    output_path: .octon/framework/capabilities/runtime/skills/outputs/
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
import { billingContext } from '../../billing/.octon/instance/cognition/context/shared';

// Good: Keep domain-specific context under the repo-root harness
import { billingContext } from '../../../.octon/instance/cognition/context/shared/billing-glossary.md';
```

**Don't duplicate shared content across multiple repo-root files:**

```
# Bad: Same content copied everywhere
.octon/instance/cognition/context/shared/auth.md
.octon/instance/cognition/context/shared/billing.md
.octon/instance/cognition/context/shared/web.md

# Good: Keep domain-specific additions in distinct repo-root files
.octon/instance/cognition/context/shared/billing.md
```

## Implementation Patterns

### Harness Discovery

Agents discover the repo-root harness from the current repository:

```
Current: /repo/packages/auth/src/handlers/login.ts

Resolution chain:
1. Resolve repository root: /repo/
2. Load active harness: /repo/.octon/
3. Load `instance/locality/manifest.yml` and `instance/locality/registry.yml`
4. Resolve the applicable `scope_id`, if any
```

### Context Composition

Repo-root context composes shared and domain-specific files:

```yaml
# Effective context for packages/auth/
sources:
  - .octon/framework/cognition/runtime/context/reference/tools.md
  - .octon/framework/cognition/runtime/context/reference/compaction.md
  - .octon/instance/cognition/decisions/index.yml
  - .octon/instance/cognition/context/shared/auth-decisions.md
  - .octon/instance/cognition/context/shared/auth-glossary.md
```

Scope-local durable context is added from
`.octon/instance/cognition/context/scopes/<scope-id>/**` only when the active
scope registry resolves a matching `scope_id`.

### Progress Isolation

The root harness tracks progress for the repository and its domains:

```
.octon/state/continuity/repo/
├── log.md         # Repository session log
├── tasks.json     # Repository task list
├── entities.json  # Repository entity state
└── next.md        # Repository next actions

.octon/state/continuity/scopes/<scope-id>/
├── log.md         # Scope-local session log
├── tasks.json     # Scope-local task list
├── entities.json  # Scope-local entity state
└── next.md        # Scope-local next actions

.octon/instance/orchestration/missions/billing-hardening/
├── mission.yml    # Mission authority object
├── log.md         # Mission-specific session log
└── tasks.json     # Mission-specific task list
```

This enables parallel workstreams without pollution.

### Missions as Scoped Work

Missions inherit locality principles:

```
.octon/instance/orchestration/missions/
└── add-mfa/
    ├── mission.yml    # Mission authority object
    ├── mission.md     # Mission scope
    ├── log.md         # Mission-specific log
    ├── tasks.json     # Mission-specific tasks
    └── context/       # Mission-specific context
```

Missions may also reference one or more locality `scope_id` values, but that
reference never replaces the root-owned scope registry.

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Progressive Disclosure | Locality scopes what's disclosed; disclosure layers what's loaded |
| Single Source of Truth | Repo-root domain files reference shared sources, not duplicate them |
| Complexity Calibration | Locality reduces complexity by scoping context proportionally to actual work |
| Deny-by-Default | Scope boundaries enforce access control |

## When to Create a Separate Harness

Use the decision heuristic:

> *"Is this a separate repository or sibling workspace that needs its own repo-root harness?"*

**Create a separate harness when:**
- The work lives in a separate sibling repository or standalone workspace
- That sibling workspace needs its own governance, continuity, and operational state
- Teams need a clear repo boundary rather than a subdirectory-local convention

**Don't create a separate harness when:**
- The work is in a descendant directory of an existing repo-root harness
- One-off work in an area can use domain-specific repo-root files
- The current repo-root harness already covers the needed guidance

## Anti-Pattern: Global Soup

The primary failure mode of violating locality is **global soup** — all context mixed together, forcing agents to load everything to find anything.

Signs of global soup:
- Single massive `.octon/` at root with all domain content
- Agents loading 50,000+ tokens of context
- Domain-specific rules buried in generic files
- "Which conventions apply here?" confusion

Prevention:
- Create domain-specific files and missions inside the repo-root harness
- Keep the repo-root harness focused (~2,000 tokens target per loaded slice)
- Use namespaced files instead of duplication or multiple `.octon/` directories on one repo path

## Related Documentation

- [Harness Architecture](../../_meta/architecture/README.md) — Full harness specification
- [Focus Pillar](../pillars/focus.md) — Cognitive bandwidth through locality
- [Continuity Pillar](../pillars/continuity.md) — Durable, discoverable knowledge
- [Skills Architecture](../../../capabilities/_meta/architecture/architecture.md) — Locality in skill design
