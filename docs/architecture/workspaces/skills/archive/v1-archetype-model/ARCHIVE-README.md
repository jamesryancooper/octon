# Archived: v1 Two-Tiered Archetype Model

**Archived:** 2026-01-23
**Replaced by:** Capabilities + Skill Sets Model

---

## What This Archive Contains

This directory preserves the original skills documentation based on the **Two-Tiered Archetype Model**:

| File | Description |
|------|-------------|
| `README.md` | Overview and navigation |
| `architecture.md` | System architecture with archetype rationale |
| `comparison.md` | Decision guidance for archetype selection |
| `creation.md` | How to create skills (archetype-focused) |
| `design-conventions.md` | Naming and structural conventions |
| `discovery.md` | Skill discovery patterns |
| `execution.md` | Runtime behavior and lifecycle |
| `invocation.md` | How skills are triggered |
| `reference-artifacts.md` | Reference file organization by archetype |
| `skill-format.md` | SKILL.md structure |
| `specification.md` | Schema definitions |
| `workspace-resolution.md` | Workspace skill override rules |

---

## The Two-Tiered Archetype Model

Skills were classified into two documentation archetypes based on complexity:

### Atomic Archetype
- **Purpose:** Single-purpose utilities with obvious I/O
- **Documentation:** SKILL.md only (optionally with `examples.md`)
- **Reference files:** None required
- **Examples:** `format-json`, `count-tokens`

### Complex Archetype
- **Purpose:** Multi-phase workflows with state, phases, and decisions
- **Documentation:** SKILL.md plus mandatory reference files
- **Reference files:** `io-contract.md`, `safety.md`, `examples.md`, `behaviors.md`, `validation.md`
- **Optional files:** `errors.md`, `glossary.md`, domain-specific docs
- **Examples:** `refactor`, `refine-prompt`

---

## Why It Was Replaced

The Two-Tiered Archetype Model had several limitations:

1. **Binary classification forced artificial choices.** Skills often had characteristics of both archetypes (e.g., simple logic but complex safety requirements).

2. **Documentation needs don't map cleanly to two tiers.** A skill might need `safety.md` without needing `behaviors.md`, but the archetype model bundled them together.

3. **Patterns emerged that didn't fit.** Coordinator skills (managing external tasks), delegator skills (spawning agents), and integrator skills (pipeline components) all needed different documentation patterns.

4. **Reference file requirements were implicit.** The archetype determined which files were needed, but the connection between skill capabilities and documentation was unclear.

5. **No granular capability discovery.** Querying "find all skills with checkpointing" required reading each skill's files rather than a simple index lookup.

---

## The New Model: Capabilities + Skill Sets

The replacement model separates two orthogonal concerns:

- **Capabilities** (17 total): What a skill can do (phased, stateful, composable, etc.)
- **Skill Sets** (7 bundles): Pre-defined capability groupings (executor, coordinator, guardian, etc.)

### Key Improvements

| Old Model | New Model |
|-----------|-----------|
| Binary choice (atomic/complex) | Mix-and-match capabilities |
| Implicit reference requirements | Capability → reference mapping |
| Pattern-based file triggers | Declared capabilities drive validation |
| Archetype field in frontmatter | `skill_sets` + `capabilities` fields |

### Migration

- `archetype: atomic` → `skill_sets: []` with minimal capabilities
- `archetype: complex` → Appropriate skill set(s) based on exhibited behaviors

---

## See Also

- **New documentation:** `docs/architecture/workspaces/skills/`
- **Capabilities reference:** `docs/architecture/workspaces/skills/capabilities.md`
- **Skill sets reference:** `docs/architecture/workspaces/skills/skill-sets.md`
- **Migration guide:** `docs/architecture/workspaces/skills/migration-guide.md`
