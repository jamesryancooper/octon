---
title: "ADR-010: Single-Root Capability-Organized Structure"
description: Consolidate .octon/ and .workspace/ into a single .octon/ root organized by cognitive capability
date: 2026-02-07
status: accepted
---

# ADR-010: Single-Root Capability-Organized Structure

## Status

Accepted

## Context

The workspace uses a two-root structure: `.octon/` for portable framework definitions and `.workspace/` for project-specific state. This split organizes by deployment boundary (portable vs local), but humans navigate by cognitive function ("where are decisions?" not "is this portable?").

Pain points with the two-root approach:

- Constant "is this in .octon or .workspace?" lookup overhead
- Capabilities split across roots (skills definitions in one, skills state in the other)
- The `.octon`/`.workspace` names don't communicate what's inside
- Portability — the primary reason for the split — is a rare operation (once per new repo) while navigation is constant

## Decision

Consolidate into a single `.octon/` root organized by capability category. Handle portability via a `octon.yml` manifest instead of directory structure.

```
.octon/
├── octon.yml          # Portability, autonomy, resolution rules
├── cognition/           # Memory & Knowledge
├── agency/              # Actors & Identity
├── capabilities/        # Skills, Commands, Tools
├── orchestration/       # Workflows, Missions
├── continuity/          # Progress, State
├── ideation/            # Human-Led Zones
├── assurance/             # Verification Gates
├── scaffolding/         # Templates, Prompts, Examples
└── output/              # Reports, Drafts, Artifacts
```

Key design choices:

- **Portability as metadata:** `octon.yml` declares portable paths explicitly, replacing the implicit two-root convention
- **Autonomy as metadata:** Human-led zones declared in `octon.yml` instead of separate `.globs` file
- **Single registry:** Skills manifest and registry merged into one (no `extends` pattern)
- **Flat where possible:** `continuity/` and `assurance/` contain files directly, no unnecessary subdirectories

## Consequences

### Benefits

- Top-level directories are self-documenting capability names
- One place to look per concept (no two-root lookup)
- The idea funnel reads naturally: `ideation/ → orchestration/ → cognition/`
- Portability is explicit and machine-readable via manifest
- Skills have a single registry (no split between definition and I/O)

### Tradeoffs

- Portability requires tooling (a `octon init` script) instead of simple directory copy
- ~339 files moved and ~3,895 path references updated
- External repos that adopted `.octon/` by copying will need migration guidance
- Deeper paths for some items (e.g., `.octon/capabilities/skills/` vs `.octon/capabilities/skills/`)

## Implementation

Migration executed in 4 commits on `refactor/single-root-capability-structure` branch.

| Commit | Scope |
|--------|-------|
| 1. Scaffold | Create `octon.yml`, new directories, this ADR |
| 2. Move | `git mv` all files to new locations |
| 3. Merge & Update | Merge registries, update all path references, fix symlinks/scripts/CI |
| 4. Cleanup | Remove `.workspace/`, empty old dirs, update templates |
