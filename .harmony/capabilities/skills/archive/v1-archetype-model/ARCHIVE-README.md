# Archived: v1 Two-Tiered Archetype Model

**Archived:** 2026-01-23
**Replaced by:** Capabilities + Skill Sets Model

---

## What This Archive Contains

This directory preserves the original skills infrastructure files:

| File | Description |
|------|-------------|
| `README.md` | Skills directory overview with archetype selection matrix |
| `SKILL.md` | Template with archetype-based guidance |
| `template-references/` | All reference file templates |

---

## The Archetype Model

Skills were classified by documentation complexity:

- **Atomic:** SKILL.md only, no reference files
- **Complex:** SKILL.md + 5+ reference files (io-contract, safety, examples, behaviors, validation)

The selection matrix asked questions like:
- "Can you explain the skill in one sentence?" (Yes → Atomic)
- "Do phases need documentation?" (Yes → Complex)

---

## Why It Was Replaced

1. **Binary choice was too coarse.** Many skills needed 2-3 reference files, not 0 or 5+.
2. **Capabilities were implicit.** No way to query "skills with checkpointing" without reading files.
3. **Patterns didn't map to archetypes.** Coordinator, delegator, and integrator patterns all needed different docs.

---

## The New Model

Capabilities (what the skill can do) drive reference file requirements:

```yaml
# Old model
archetype: complex

# New model
skill_sets: [executor, guardian]
capabilities: [resumable]
```

Each capability maps to specific reference files. Validation checks that declared capabilities have corresponding documentation.

---

## See Also

- `docs/architecture/workspaces/skills/capabilities.md`
- `docs/architecture/workspaces/skills/skill-sets.md`
- `docs/architecture/workspaces/skills/migration-guide.md`
