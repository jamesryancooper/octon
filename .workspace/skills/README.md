# Skills

Workspace-specific skill outputs and configuration.

For full documentation, see `.harmony/skills/README.md` and `docs/architecture/workspaces/skills/`.

## Directory Structure

All operational categories follow the `{category}/{skill-id}/` pattern:

| Category | Path Pattern | Purpose | Read/Write |
|----------|--------------|---------|------------|
| `configs/` | `configs/{skill-id}/` | Configuration overrides | Read (skills), Write (user/setup) |
| `resources/` | `resources/{skill-id}/` | Input materials (notes, docs, data) | Read (skills), Write (user) |
| `runs/` | `runs/{skill-id}/{run-id}/` | Execution state for session recovery (checkpoints, manifests) | Read/Write (skills) |
| `logs/` | `logs/{skill-id}/{run-id}.md` | Execution history | Read/Write (skills) |

**Bounded top-level:** The top level has 6 fixed entries regardless of skill count: `manifest.yml`, `registry.yml`, `configs/`, `resources/`, `runs/`, `logs/`.

## Configuration Files

| Content | Purpose |
|---------|---------|
| `manifest.yml` | Workspace-specific skill index (extends shared) |
| `registry.yml` | I/O path mappings (single source of truth for paths) |

## Inherited Skills

This workspace inherits skills from `.harmony/skills/`:

- `refine-prompt` — Context-aware prompt refinement
- `synthesize-research` — Research synthesis
- `refactor` — Verified codebase refactoring
- `create-skill` — Skill scaffolding

## Validation

Run `.harmony/skills/scripts/validate-skills.sh` to detect drift issues.
