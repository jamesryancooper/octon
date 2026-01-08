---
title: Workspace Examples
description: Reference patterns stored in .workspace/examples/ for study and learning
---

# Workspace Examples

Examples are **reference patterns** stored in `.workspace/examples/`. They demonstrate correct implementation of workspace concepts.

## Location

```text
.workspace/examples/
└── create-workspace-flow.md    # Example of workflow execution
```

---

## When to Use Examples

| Situation | Use Examples |
|-----------|--------------|
| Learning workspace patterns | ✅ Yes |
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

- `create-workspace-flow.md` — Shows a complete workflow execution trace

---

## Note on Scoped Workspace Examples

Complete workspace structure examples (for documentation areas, Node.js/TypeScript packages, etc.) have been moved to **scoped templates** in `.workspace/templates/`:

| Former Example | Now Template |
|----------------|--------------|
| `workspace-docs/` | `.workspace/templates/workspace-docs/` |
| `workspace-node-ts/` | `.workspace/templates/workspace-node-ts/` |

Scoped templates are more useful than static examples because they:

1. Inherit from the base `workspace/` template (stay in sync)
2. Can be directly used by `/create-workspace` workflow
3. Contain only scope-specific customizations

---

## See Also

- [Templates](./templates.md) — Boilerplate for new content
- [README.md](./README.md) — Canonical workspace structure
