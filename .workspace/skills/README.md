# Skills

Workspace-specific skill outputs and configuration.

For full documentation, see `.harmony/skills/README.md` and `docs/architecture/workspaces/skills/`.

## This Directory

| Content | Purpose |
|---------|---------|
| `manifest.yml` | Workspace-specific skill index (extends shared) |
| `registry.yml` | I/O path mappings (single source of truth for paths) |
| `outputs/` | All skill outputs |
| `logs/runs/` | Execution audit logs |
| `sources/` | Input sources for skills |

## Inherited Skills

This workspace inherits skills from `.harmony/skills/`:

- `refine-prompt` — Context-aware prompt refinement
- `research-synthesizer` — Research synthesis

## Validation

Run `.harmony/skills/scripts/validate-skills.sh` to detect drift issues.
