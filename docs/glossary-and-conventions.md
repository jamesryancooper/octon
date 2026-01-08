---
title: Glossary and Conventions
description: Shared terminology and repository-wide conventions for names, branches/commits/PRs, flags, IDs, and docs — a single source of truth for Harmony vocabulary and style.
---

# Glossary and Conventions

Status: Draft stub (fill in project specifics)

## Two‑Dev Scope

- Keep this document short (≈1 page). Include only terms actively used in code, PRs, or docs.
- Update cadence: curate monthly or when confusion arises. One owner accountable for edits.
- Conventions must be repo‑wide and minimal; avoid team‑ or slice‑specific variants.

## Pillars Alignment

- Speed with Safety: Shared terms and conventions reduce review time, miscommunication, and integration errors across tiny PRs.
- Simplicity over Complexity: Minimal, repo‑wide rules (naming, flags, commits) avoid bespoke styles per slice.
- Quality through Determinism: Stable identifiers, error code formats, and commit/PR conventions make outcomes consistent and machine‑checkable.
- Guided Agentic Autonomy: Consistent vocabulary enables agents to generate correct diffs and references; humans remain final approvers.

See `docs/methodology/README.md` for Harmony’s five pillars.

## Purpose

- Create a concise, canonical reference for names and vocabulary used across Harmony.
- Reduce ambiguity for humans and agents by standardizing identifiers and formats.

## Key Terms (Harmony)

- Pillars: Speed with Safety; Simplicity over Complexity; Quality through Determinism; Guided Agentic Autonomy.
- Slice: A vertical feature module with ports/adapters boundaries. See `docs/architecture/slices-vs-layers.md`.
- Layer: Cross‑cutting governance/control plane concerns (quality gates, observability, kaizen). Not a runtime call layer.
- Thin Control Plane: Flags, policy gates, contracts, observability guardrails. See `docs/architecture/overview.md`.
- Knowledge Plane (KP): Unified, queryable engineering knowledge. See `docs/architecture/knowledge-plane.md`.
- Kaizen/Improve Layer: Autonomous hygiene PRs with HITL. See `docs/methodology/improve-layer.md`.

## Naming Conventions

- Packages and slices: `packages/<slice-name>/...` (kebab‑case). Public folders and exports prefer stable, descriptive names.
- Files: kebab‑case for markdown and configs; `PascalCase.tsx` for React components; `snake_case` for SQL migrations as applicable.
- Feature flags: `feature.<slice>.<capability>`; kill‑switches prefix `kill.<area>.<toggle>`; default OFF; fail‑closed.
- Environment variables: `SCREAMING_SNAKE_CASE`; document in app/README and link to this doc.
- IDs: Prefer ULIDs/UUIDv7; avoid sequential IDs for security. Encode ID type in variable name (e.g., `userId`, `orderId`).
- Error codes: `ERR_<AREA>_<CONDITION>` with human‑readable messages; centralize mapping in each slice.

## Branch, Commit, and PR Conventions

- Branches: `feat/<slice>-<short>`, `fix/<slice>-<short>`, `chore/<area>-<short>`.
- Commits: Conventional Commits preferred (`type(scope): summary`) to aid tooling; keep scopes aligned to slices.
- PRs: Small, reviewable; include risk level and rollback/flag notes. See `docs/architecture/governance-model.md` for required PR fields.

## API/HTTP Conventions (summary)

- Contract‑first with OpenAPI/JSON Schema. Prefer nouns for resources and verbs for actions: `/orders`, `/orders/{id}/cancel`.
- Pagination: `?page`, `?page_size` or `?cursor` (choose one repo‑wide; document here).
- Idempotency: Require `Idempotency-Key` on mutating endpoints; return prior result on repeat.
- Errors: Consistent envelope `{ error: { code, message, details? } }`.
- Timeouts/retries: Document per adapter; honor budget and surface 504s upstream.

## Documentation Conventions

- Frontmatter: `title`, `description` required. Use relative links to related docs.
- Diagrams: Prefer Mermaid for architecture sketches; keep simple and focused.
- Cross‑references: Link slices/layers and ADRs; include file paths when practical.

## Related Docs

- Architecture overview: `docs/architecture/overview.md`
- Slices vs layers: `docs/architecture/slices-vs-layers.md`
- Knowledge Plane: `docs/architecture/knowledge-plane.md`
- Governance model: `docs/architecture/governance-model.md`
- Repository blueprint: `docs/architecture/repository-blueprint.md`
- Methodology overview: `docs/methodology/README.md`
- Implementation guide: `docs/methodology/implementation-guide.md`
- Layers model: `docs/methodology/layers.md`
- Improve layer: `docs/methodology/improve-layer.md`
