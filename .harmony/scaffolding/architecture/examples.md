---
title: Harness Examples
description: Reference patterns stored in .harmony/scaffolding/examples/ for study and learning
---

# Harness Examples

Examples are **reference patterns** stored in `.harmony/scaffolding/examples/`. They demonstrate correct implementation of harness concepts.

## Location

```text
.harmony/scaffolding/examples/
└── create-harness-flow.md    # Example of workflow execution
```

---

## When to Use Examples

| Situation | Use Examples |
|-----------|--------------|
| Learning harness patterns | ✅ Yes |
| Understanding correct structure | ✅ Yes |
| Creating new content | ❌ No (use templates instead) |
| Executing procedures | ❌ No (use workflows instead) |

---

## Example Principles

1. **Minimal and complete** — Show the essential pattern, nothing extra
2. **Realistic content** — Use plausible values, not lorem ipsum
3. **Self-contained** — Each example should work independently
4. **Annotated where non-obvious** — Brief comments explaining key choices

---

## Example vs Template

| Type | Purpose | Action |
|------|---------|--------|
| **Example** | Study and understand | Read, learn, reference |
| **Template** | Create new content | Copy, customize, use |

Examples demonstrate *how things should look*. Templates are *starting points for new work*.

---

## Available Examples

### Workflow Execution Examples

- `create-harness-flow.md` — Shows a complete workflow execution trace

---

## Note on Scoped Harness Examples

Complete harness structure examples (for documentation areas, Node.js/TypeScript packages, etc.) have been moved to **scoped templates** in `.harmony/scaffolding/templates/`:

| Former Example | Now Template |
|----------------|--------------|
| `harmony-docs/` | `.harmony/scaffolding/templates/harmony-docs/` |
| `harmony-node-ts/` | `.harmony/scaffolding/templates/harmony-node-ts/` |

Scoped templates are more useful than static examples because they:

1. Inherit from the base `harmony/` template (stay in sync)
2. Can be directly used by `/create-harness` workflow
3. Contain only scope-specific customizations

---

## See Also

- [Templates](./templates.md) — Boilerplate for new content
- [README.md](./README.md) — Canonical harness structure
