# Harmony Content Plane: Final Specification v1.0

This directory contains the complete specification for the Harmony Content Plane (HCP) - a flat-file-first content compiler that validates, resolves, indexes, and transforms content files into a queryable Harmony Content Graph and deterministic multi-destination outputs.

---

## Position in the Three-Plane Architecture

The Content Plane is one of three architectural planes in Harmony:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        THE THREE PLANES OF HARMONY                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐          │
│   │  CONTENT PLANE  │   │ CONTINUITY PLANE│   │ KNOWLEDGE PLANE │          │
│   │  ◄── You are    │   │                 │   │                 │          │
│   │      here       │   │  "What we       │   │  "What the      │          │
│   │                 │   │   decided"      │   │   system is"    │          │
│   │  "What we       │   │                 │   │                 │          │
│   │   publish"      │   │  • Decisions    │   │  • Specs        │          │
│   │                 │   │  • Handoffs     │   │  • Contracts    │          │
│   │  • Docs         │   │  • Progress     │   │  • Code refs    │          │
│   │  • Entities     │   │  • Backlogs     │   │  • Tests        │          │
│   │  • Pages        │   │                 │   │  • Traces       │          │
│   │  • Prompts      │   │                 │   │  • SBOM         │          │
│   └─────────────────┘   └─────────────────┘   └─────────────────┘          │
│                                                                             │
│   See: Three Planes Integration for cross-plane architecture                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Related Planes:**
- [Continuity Plane](../../../continuity/architecture/continuity-plane.md) — Process knowledge (decisions, handoffs)
- [Knowledge Plane](../../../cognition/knowledge-plane/knowledge-plane.md) — System knowledge (specs, code, tests)
- [Three Planes Integration](../../../continuity/architecture/three-planes-integration.md) — Cross-plane architecture

---

## Document Structure

| File | Description |
|------|-------------|
| [overview.md](./overview.md) | Overview, key decisions, and what HCP enables/avoids |
| [problem-severity-matrix.md](./problem-severity-matrix.md) | Analysis of core problems and their severity for Harmony |
| [architecture-overview.md](./architecture-overview.md) | Core design principles, boundaries, hybrid model, and synthesis notes |
| [architecture-diagram.md](./architecture-diagram.md) | Visual architecture diagrams (Mermaid) including runtime layers |
| [technical-specification.md](./technical-specification.md) | Full technical spec: terminology, layout, modeling, schemas, refs, build pipeline, governance, queries, collaboration, multi-destination publishing |
| [runtime-content-layer.md](./runtime-content-layer.md) | **Runtime content layer**: canonical vs runtime content, hybrid model, storage choices, tiered architecture |
| [pillar-convivial-alignment.md](./pillar-convivial-alignment.md) | Alignment with Harmony pillars and convivial design principles |
| [implementation-roadmap.md](./implementation-roadmap.md) | Phased implementation roadmap including runtime layer phases |
| [tool-recommendations.md](./tool-recommendations.md) | Tool recommendations by category |
| [boundary-conditions.md](./boundary-conditions.md) | Quantitative thresholds, warning signs, escalation paths, and runtime layer decision matrix |
| [open-questions.md](./open-questions.md) | Open questions for validation |
| [appendices.md](./appendices.md) | Example files, schemas, queries, and CI workflow |

## Quick Summary

**Name:** Harmony Content Plane (HCP)

**One sentence:** A flat-file-first content compiler that validates, resolves, indexes, and transforms content files into a queryable Harmony Content Graph and deterministic multi-destination outputs.

### What HCP IS

- A **toolchain** (CLI + library) that compiles content into stable artifacts
- A **schema registry** for content types (Zod) with migrations
- A **build-time "content database"** (SQLite) that is regenerated deterministically
- A **dependency graph** enabling impact analysis ("blast radius")
- A shared infrastructure for **public, internal, and agent continuity** content
- An **extensible architecture** that supports optional runtime layers when boundary conditions are crossed

### What HCP IS NOT

- A hosted CMS or a multi-user editorial product
- A real-time collaborative editor (by default—runtime layer is optional)
- A workflow engine (draft/review/publish state machines beyond simple metadata)
- A runtime content mutation API with auth/RBAC (unless you explicitly cross boundaries and adopt the runtime layer—see [runtime-content-layer.md](./runtime-content-layer.md)

### Content Classification

| Type | Location | Plane | Description |
|------|----------|-------|-------------|
| **Canonical Content** | `content/` | Content Plane | Source of truth: public, internal, and agent-facing content |
| **Continuity Artifacts** | `.continuity/` | [Continuity Plane](../../../continuity/architecture/continuity-plane.md) | Backlog, plans, handoffs, decisions with lifecycle rules |
| **Runtime Content** | Server DB (optional) | Content Plane (runtime) | Live overrides, personalization, session state |

> **Note**: Continuity artifacts (`.continuity/`) are managed by the Continuity Plane with specialized lifecycle rules. See [Continuity Plane](../../../continuity/architecture/continuity-plane.md) for details on decision records, handoffs, and progress tracking.

## Sources & Influences (non-normative)

- Lee Robinson's migration illustrates how CMS abstraction boundaries impede agents and how much complexity (auth, previews, i18n, CDN costs) a CMS integration can hide.
- Knut Melvær's critique highlights the non-deletable problems: content/page trap, semantic collaboration issues, and grep ≠ query—directly motivating build-time indexing and references.
- v1/v2/v3 converge on a compiler pipeline with schemas, indexes, and guardrails rather than a CMS product.
