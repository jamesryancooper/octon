# Octon Artifact Surface: Final Specification v1.0

This directory contains the complete specification for the Octon Artifact Surface (HAS) - a flat-file-first artifact compiler that validates, resolves, indexes, and transforms content files into a queryable Octon Artifact Graph and deterministic multi-destination outputs.

## Machine Discovery

- `index.yml` - canonical machine-readable index for artifact-surface architecture docs.

---

## Status

The **Artifact Plane is foundational** in Octon.
This directory defines the canonical **Artifact Surface architecture (HAS)** for
that plane. Runtime overlay layers remain optional.

## Position Relative to the Foundational Planes

The artifact surface implements the foundational Artifact Plane and integrates
with the other foundational planes:

```text
Ingress -> Orchestration -> Capability -> Service -> Execution Kernel
                                         |                 |
                                         v                 v
                                  Artifact Plane (HAS)  Runtime outcomes
                                         |                 |
                                         v                 v
                                      Assurance <------ Continuity
                                         |
                                         v
                                      Knowledge
```

**Related Foundational Surfaces:**
- [Foundational Planes Integration](../../../../continuity/_meta/architecture/three-planes-integration.md) — Cross-plane contract
- [Execution Kernel](../../../../engine/runtime/) — Runtime dispatch entrypoint
- [Services](../../../../capabilities/runtime/services/) — Typed runtime interfaces
- [Commands (Ingress)](../../../../capabilities/runtime/commands/) — Human intent intake
- [Skills (Capability)](../../../../capabilities/runtime/skills/) — Atomic execution units
- [Workflows (Orchestration)](../../../../orchestration/runtime/workflows/) — Multi-step sequencing
- [Assurance](../../../../assurance/runtime/) — Gate and validation profiles
- [Continuity Plane](../../../../continuity/_meta/architecture/continuity-plane.md) — Active operational memory
- [Knowledge Plane](../../../runtime/knowledge/knowledge.md) — Durable context/decision/evidence indexing

---

## Document Structure

| File | Description |
|------|-------------|
| [overview.md](./overview.md) | Overview, key decisions, and what HAS enables/avoids |
| [problem-severity-matrix.md](./problem-severity-matrix.md) | Analysis of core problems and their severity for Octon |
| [architecture-overview.md](./architecture-overview.md) | Core design principles, boundaries, hybrid model, and synthesis notes |
| [architecture-diagram.md](./architecture-diagram.md) | Visual architecture diagrams (Mermaid) including runtime layers |
| [technical-specification.md](./technical-specification.md) | Full technical spec: terminology, layout, modeling, schemas, refs, build pipeline, governance, queries, collaboration, multi-destination publishing |
| [runtime-artifact-layer.md](./runtime-artifact-layer.md) | **Runtime artifact layer**: canonical vs runtime artifacts, hybrid model, storage choices, tiered architecture |
| [pillar-convivial-alignment.md](./pillar-convivial-alignment.md) | Alignment with Octon pillars and convivial design principles |
| [implementation-roadmap.md](./implementation-roadmap.md) | Phased implementation roadmap including runtime layer phases |
| [tool-recommendations.md](./tool-recommendations.md) | Tool recommendations by category |
| [boundary-conditions.md](./boundary-conditions.md) | Quantitative thresholds, warning signs, escalation paths, and runtime layer decision matrix |
| [open-questions.md](./open-questions.md) | Open questions for validation |
| [appendices.md](./appendices.md) | Example files, schemas, queries, and CI workflow |

## Quick Summary

**Name:** Octon Artifact Surface (HAS)

**One sentence:** A flat-file-first artifact compiler that validates, resolves, indexes, and transforms content files into a queryable Octon Artifact Graph and deterministic multi-destination outputs.

### What HAS IS

- A **toolchain** (CLI + library) that compiles content into stable artifacts
- A **schema registry** for content types (Zod) with migrations
- A **build-time "content database"** (SQLite) that is regenerated deterministically
- A **dependency graph** enabling impact analysis ("blast radius")
- A shared infrastructure for **public, internal, and agent continuity** content
- An **extensible architecture** that supports optional runtime layers when boundary conditions are crossed

### What HAS IS NOT

- A hosted CMS or a multi-user editorial product
- A real-time collaborative editor (by default—runtime layer is optional)
- A workflow engine (draft/review/publish state machines beyond simple metadata)
- A runtime content mutation API with auth/RBAC (unless you explicitly cross boundaries and adopt the runtime layer—see [runtime-artifact-layer.md](./runtime-artifact-layer.md))

### Content Classification

| Type | Location | Owner Surface | Description |
|------|----------|---------------|-------------|
| **Canonical Content** | `content/` | Artifact surface | Source of truth: public, internal, and agent-facing content |
| **Continuity Artifacts** | `.octon/continuity/` | [Continuity Plane](../../../../continuity/_meta/architecture/continuity-plane.md) | Active tasks, entities, handoff-ready next actions, and progress history |
| **Runtime Artifacts** | Server DB (optional) | Artifact runtime extension | Live overrides, personalization, session state |

> **Note**: Continuity artifacts (`.octon/continuity/`) are managed by the Continuity Plane with specialized lifecycle rules. Durable decision records are managed by the Knowledge Plane under `/.octon/cognition/runtime/decisions/`.

## Sources & Influences (non-normative)

- Lee Robinson's migration illustrates how CMS abstraction boundaries impede agents and how much complexity (auth, previews, i18n, CDN costs) a CMS integration can hide.
- Knut Melvær's critique highlights the non-deletable problems: content/page trap, semantic collaboration issues, and grep ≠ query—directly motivating build-time indexing and references.
- v1/v2/v3 converge on a compiler pipeline with schemas, indexes, and guardrails rather than a CMS product.
