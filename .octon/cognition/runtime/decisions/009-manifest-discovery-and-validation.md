---
title: "ADR-009: Manifest-Based Discovery and Validation Tooling"
status: accepted
date: 2026-01-17
mutability: append-only
---

# ADR-009: Manifest-Based Discovery and Validation Tooling

## Status

Accepted

## Superseding Links (Framing Terminology)

- Superseded by: `040-principles-charter-successor-v2026-02-24.md`
- Canonical principle: `/.octon/cognition/governance/principles/complexity-calibration.md`
- Scope of supersession: legacy principle label only; manifest/validation decisions remain accepted.

## Context

The skills system needed improvements in three areas:

1. **Discovery efficiency** - Reading every SKILL.md frontmatter (~100 tokens each) at session start was expensive for repositories with many skills
2. **Validation gaps** - No automated way to verify skills followed the agentskills.io spec, check for drift between files, or enforce token budgets
3. **Undocumented principles** - Octon's design principles were implicit rather than documented

Additionally, the system had Octon-specific extensions beyond the agentskills.io spec that needed documentation:
- `display_name` field in manifest
- Placeholder syntax in workspace registry paths

## Decision

Implement a four-tier progressive disclosure model with comprehensive validation tooling and formal principles documentation.

### Decisions Made

| ID | Decision | Choice |
|----|----------|--------|
| D033 | Four-tier progressive disclosure | manifest.yml (~50 tokens) → registry.yml (~50 tokens) → SKILL.md (<5000 tokens) → references/ (on-demand) |
| D034 | Manifest as Tier 1 discovery | Centralized index with id, name, summary, triggers for fast routing |
| D035 | Validation tooling | validate-skills.sh with 21 automated checks |
| D036 | Principles documentation | Formal docs/principles/ directory with 8 principle definitions |
| D037 | display_name extension | Human-readable name derived from id via Title Case convention |
| D038 | Placeholder validation | `{{snake_case}}` format enforced; deprecated formats detected |
| D039 | CI integration | skills-validation job in pr.yml with tiktoken for accurate token counting |

## Implementation

### Four-Tier Progressive Disclosure

| Tier | Source | Content | When Loaded | Token Budget |
|------|--------|---------|-------------|--------------|
| **1** | manifest.yml | id, name, summary, triggers | Always (discovery) | ~50 tokens |
| **2** | registry.yml | commands, requires, depends_on | After skill matched | ~50 tokens |
| **3** | SKILL.md | Full skill instructions | When skill activated | <5000 tokens |
| **4** | references/ | Detailed docs, scripts, assets | When specific detail needed | On demand |

### Validation Checks (21 total)

The `validate-skills.sh` script checks:

1. Directory exists
2. SKILL.md exists
3. SKILL.md name matches directory name
4. Skill is in manifest
5. Skill is in registry
5b. display_name is present and valid
6. No version in SKILL.md (should be in registry)
7. No requires.tools in io-contract.md (drift prevention)
8. No allowed tools in safety.md (drift prevention)
9-11. No duplicated tables in SKILL.md/io-contract.md/safety.md
12. No deprecated top-level outputs in skills registry (use `skills.<id>.io.outputs`)
13. I/O mappings exist in skills registry
14. allowed-tools in SKILL.md is valid (single source of truth)
15. Output paths within workspace scope
16. Token budgets respected
17. Description/summary alignment
18. Reference file content matches registry
19. Cross-reference validation (manifest ↔ registry sync)
20. Examples use correct commands
21. Placeholder formats valid (`{{snake_case}}`)

### Principles Documentation

Created `docs/principles/` with 8 formal definitions:

| Principle | Summary |
|-----------|---------|
| Progressive Disclosure | Load context in tiers; minimize upfront token cost |
| Single Source of Truth | Each datum defined in exactly one location |
| Locality | Context lives close to where it's needed |
| Simplicity Over Complexity | Minimum necessary complexity for current requirements |
| Deny by Default | Explicit allowlists for permissions; no implicit access |
| Determinism | Same inputs produce same outputs; no hidden state |
| Autonomous Control Points | Policy-gated controls for irreversible or high-impact actions |
| Reversibility | Prefer reversible over irreversible actions |

### Extensions Documentation

Added to `docs/architecture/workspaces/skills/specification.md`:

**display_name extension:**
```yaml
# In manifest.yml
skills:
  - id: synthesize-research          # Machine-readable
    display_name: Synthesize Research  # Human-readable (Title Case)
```

**Placeholder format:**
```yaml
# Valid: {{snake_case}}
outputs/{{category}}/{{timestamp}}-result.md

# Invalid: <placeholder>, {single_brace}, {{ spaces }}
```

## Consequences

### Positive

- Discovery cost reduced from ~100 to ~50 tokens per skill
- Automated drift detection prevents inconsistencies
- Token budgets enforced at CI time
- Principles are explicit and referenceable
- Extensions are documented for contributors

### Negative

- Two extra files (manifest.yml, validate-skills.sh) to maintain
- Complexity justified only at scale (10+ skills)
- Principles documentation requires updates as framework evolves

## Related

- `.octon/capabilities/skills/manifest.yml` - Tier 1 discovery index
- `.octon/capabilities/skills/registry.yml` - Tier 2 extended metadata
- `.octon/capabilities/skills/scripts/validate-skills.sh` - Validation tooling
- `docs/principles/` - Principle definitions
- `docs/architecture/workspaces/skills/specification.md` - Extensions documentation
- `infra/ci/pr.yml` - CI integration
