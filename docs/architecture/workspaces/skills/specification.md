---
title: Specification Compliance
description: Conformance to agentskills.io specification, extensions, and validation.
---

# Specification Compliance

This document describes how the Harmony skills implementation relates to the [agentskills.io specification](https://agentskills.io/specification), including conformance, extensions, and validation.

---

## Spec Compliance

This implementation follows [agentskills.io/specification](https://agentskills.io/specification):

| Spec Requirement | Implementation |
|------------------|----------------|
| Required frontmatter: `name`, `description` | ✓ In `SKILL.md` |
| Optional: `license`, `compatibility`, `metadata`, `allowed-tools` | ✓ In `SKILL.md` |
| Directory structure: `references/`, `scripts/`, `assets/` | ✓ Per spec |
| `SKILL.md` < 500 lines | ✓ Details in `references/` |
| Name matches directory | ✓ Enforced by `create-skill` workflow |
| Progressive disclosure | ✓ Three-tier model |

---

## Extensions Beyond Spec

This implementation extends the base specification with:

| Extension | Purpose |
|-----------|---------|
| Two-tier architecture | Separate shared skills from workspace I/O |
| Registry files | Centralized routing metadata for multiple skills |
| Reference file schemas | Standardized YAML frontmatter for machine parsing |
| Host adapter symlinks | Multi-agent discovery from single source |
| Pipelines | Compose multiple skills in sequence |
| Run logging | Auditable execution history |

### Two-Tier Architecture

The spec defines skills as self-contained directories. Harmony extends this with:

- **Tier 1 (`.harmony/skills/`)** — Shared, portable skill definitions
- **Tier 2 (`.workspace/skills/`)** — Workspace-specific I/O paths and outputs

See [Architecture](./architecture.md) for details.

### Registry Files

The spec doesn't define a registry format. Harmony adds:

- `registry.yml` for centralized skill metadata
- Routing rules for trigger matching
- Pipeline definitions for skill composition

See [Registry](./registry.md) for details.

### Reference File Schemas

The spec suggests `references/` for additional documentation. Harmony standardizes:

- YAML frontmatter for machine parsing
- Defined schemas for each reference file type
- Classification (universal, partial, recommended)

See [Reference Artifacts](./reference-artifacts.md) for details.

---

## Validation

### Using skills-ref

Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library to validate skills:

```bash
# Validate a skill directory
skills-ref validate ./path/to/skill

# Generate XML for agent prompts
skills-ref to-prompt ./path/to/skill
```

### Manual Validation Checklist

Validate a skill manually:

#### Structure

- [ ] `SKILL.md` exists in skill directory
- [ ] `name` in frontmatter matches directory name
- [ ] `description` is 1-1024 characters
- [ ] Body is under 500 lines

#### Naming

- [ ] Name is 1-64 characters
- [ ] Only lowercase letters, numbers, hyphens
- [ ] Does not start or end with hyphen
- [ ] No consecutive hyphens

#### References (if present)

- [ ] All reference files have YAML frontmatter
- [ ] All reference files have markdown body
- [ ] `io-contract.md` defines inputs and outputs
- [ ] `safety.md` defines tool and file policies
- [ ] `triggers.md` defines invocation patterns
- [ ] `examples.md` has at least one worked example
- [ ] `behaviors.md` documents execution phases
- [ ] `validation.md` defines acceptance criteria

#### Registry

- [ ] Skill is listed in `.harmony/skills/registry.yml`
- [ ] `id` matches directory name
- [ ] `commands` includes at least one slash command
- [ ] `summary` is present for routing

#### Execution

- [ ] Skill produces output in `outputs/` directory
- [ ] Skill creates run log in `logs/runs/`
- [ ] Output matches format in `io-contract.md`
- [ ] All acceptance criteria are met

---

## See Also

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification
- [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) — Agent integration guide
- [Architecture](./architecture.md) — Implementation architecture
- [Reference Artifacts](./reference-artifacts.md) — Reference file schemas
- [Creation](./creation.md) — Creating new skills
