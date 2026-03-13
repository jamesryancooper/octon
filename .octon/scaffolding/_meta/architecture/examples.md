---
title: Harness Examples
description: Reference patterns stored in .octon/scaffolding/practices/examples/ for study and learning
---

# Harness Examples

Examples are **reference patterns** stored in `.octon/scaffolding/practices/examples/`. They demonstrate correct implementation of harness concepts.

## Location

```text
.octon/scaffolding/practices/examples/
└── stack-profiles/           # Example reference profiles
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

### Stack Profile Examples

- `stack-profiles/nextjs-astro-vercel.md` — Example platform profile
- `stack-profiles/python-runtime-workspace.md` — Example runtime/workspace profile

---

## Note on Harness Examples

The root harness is the only supported harness form. Example coverage therefore focuses on:

1. The base `octon/` template under `.octon/scaffolding/runtime/templates/`
2. Stack profile examples under `.octon/scaffolding/practices/examples/stack-profiles/`
3. Repo-root customization after `/init`

---

## See Also

- [Templates](./templates.md) — Boilerplate for new content
- [README.md](./README.md) — Canonical harness structure
