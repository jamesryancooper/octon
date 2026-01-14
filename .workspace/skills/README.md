# Skills

Shared skills and the skills framework live in `.harmony/skills/`.

Project-specific skills are created here.

## Inherited from `.harmony/`

- `_template/` - Template for creating new skills
- `research-synthesizer/` - Synthesize research notes into coherent findings
- `scripts/setup-harness-links.sh` - Create harness symlinks

## Local Directories

- `outputs/` - All skill outputs write here (always local)
- `logs/` - Execution logs (always local)
- `sources/` - Input sources (always local)

## Registry Pattern

- `.harmony/skills/registry.yml` - Skill definitions (shared)
- `.workspace/skills/registry.yml` - Project-specific input/output mappings

See CLAUDE.md for the progressive disclosure pattern.
