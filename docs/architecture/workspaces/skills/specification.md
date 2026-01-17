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

## Tool Permissions: Single Source of Truth

Tool permissions are defined in the `allowed-tools` field in SKILL.md frontmatter. This is the **single source of truth** for what tools a skill may use, following the agentskills.io specification.

### Design Principle

```
allowed-tools in SKILL.md → SINGLE SOURCE OF TRUTH
                          ↓
           map_allowed_to_internal() function
                          ↓
              Internal format for routing
```

**Rationale:**

- **Spec compliance** — `allowed-tools` follows the agentskills.io specification
- **Portability** — Skills can be copied to other repositories and work standalone
- **No drift** — Single source eliminates synchronization issues
- **Derived data** — Internal format is generated on-demand via mapping function

### `allowed-tools` Format

The `allowed-tools` field in SKILL.md frontmatter uses space-delimited tool names:

```yaml
allowed-tools: Read Glob Grep Write(outputs/*) Write(logs/*)
```

### Tool Reference

| `allowed-tools` | Internal Format | Description |
|-----------------|-----------------|-------------|
| `Read` | `filesystem.read` | Read files |
| `Write(outputs/*)` | `filesystem.write.outputs` | Write to outputs directory |
| `Write(logs/*)` | `filesystem.write.logs` | Write to logs directory |
| `Glob` | `filesystem.glob` | Pattern matching for file discovery |
| `Grep` | `filesystem.grep` | Content search |
| `WebFetch` | `network.fetch` | HTTP requests (read-only) |
| `Shell` | `shell.execute` | Execute shell commands |
| `Task` | `agent.task` | Launch subagent tasks |

**Wildcard patterns:** `Write(path/*)` scopes write access to a specific directory.

### Mapping Function

The validation script includes a mapping function to convert `allowed-tools` to internal format:

```bash
# In validate-skills.sh
map_allowed_to_internal() {
    local allowed="$1"
    case "$allowed" in
        Read)                    echo "filesystem.read" ;;
        Write\(outputs/\*\))     echo "filesystem.write.outputs" ;;
        Write\(logs/\*\))        echo "filesystem.write.logs" ;;
        Glob)                    echo "filesystem.glob" ;;
        Grep)                    echo "filesystem.grep" ;;
        WebFetch)                echo "network.fetch" ;;
        Shell)                   echo "shell.execute" ;;
        Task)                    echo "agent.task" ;;
        *)                       echo "" ;;  # Unknown
    esac
}

# Get all tools for a skill in internal format
get_internal_tools_from_skill() {
    local skill_dir="$1"
    # Reads allowed-tools from SKILL.md and converts each to internal format
    ...
}
```

### Validation

Run the validation script to verify `allowed-tools` is present and valid:

```bash
.harmony/skills/scripts/validate-skills.sh
```

The script checks that:
- `allowed-tools` exists in SKILL.md frontmatter
- All tools are recognized (can be mapped to internal format)
- No unknown tool names are present

---

## Extensions Beyond Spec

This implementation extends the base specification with:

| Extension | Purpose |
|-----------|---------|
| Two-tier architecture | Separate shared skills from workspace I/O |
| Manifest and registry files | Centralized routing metadata for multiple skills |
| `display_name` field | Human-readable skill name for UI display |
| Reference file schemas | Standardized YAML frontmatter for machine parsing |
| Host adapter symlinks | Multi-agent discovery from single source |
| Pipelines | Compose multiple skills in sequence |
| Run logging | Auditable execution history |

### Two-Tier Architecture

**Why:** The agentskills.io spec defines skills as self-contained directories. However, in multi-workspace repositories, the same skill may be used with different I/O paths in different contexts. Separating skill logic from workspace-specific configuration enables:

- **Portability** — Skills can be shared across repositories without modification
- **Context-specific I/O** — Each workspace defines its own input/output paths
- **No duplication** — Skill logic lives in one place (`.harmony/skills/`)

**Implementation:**

| Tier | Location | Contains |
|------|----------|----------|
| **Shared** | `.harmony/skills/` | Skill definitions, behavior, instructions |
| **Workspace** | `.workspace/skills/` | I/O mappings, outputs, logs |

See [Architecture](./architecture.md) for details.

### Manifest and Registry Files

**Why:** The agentskills.io spec uses `name` + `description` from SKILL.md frontmatter (~100 tokens) for discovery. For repositories with many skills, loading every SKILL.md at session start is expensive. The manifest/registry split provides:

- **Token efficiency** — manifest.yml is ~50 tokens/skill vs ~100+ tokens reading SKILL.md frontmatter
- **Centralized routing** — All skill triggers and commands in one file for easy scanning
- **Separation of concerns** — SKILL.md contains identity and instructions; manifest/registry contains routing

**Trade-off acknowledged:** This adds complexity (two extra files). The benefit scales with skill count:

| Skill Count | Manifest/Registry Benefit |
|-------------|---------------------------|
| 1-3 skills | Marginal (consider skipping) |
| 4-10 skills | Worthwhile token savings |
| 10+ skills | Significant efficiency gain |

**Single source of truth principle:** To prevent drift, each piece of metadata lives in exactly one place:

| Metadata | Source of Truth | NOT Duplicated In |
|----------|-----------------|-------------------|
| `name`, `description` | SKILL.md frontmatter | — |
| `allowed-tools` (tool permissions) | SKILL.md frontmatter | registry.yml (derived via mapping function) |
| `summary`, `triggers`, `tags`, `display_name` | `.harmony/skills/manifest.yml` | SKILL.md |
| `version`, `commands`, `parameters`, `depends_on` | `.harmony/skills/registry.yml` | SKILL.md, io-contract.md |
| **Input/output paths** | **`.workspace/skills/registry.yml`** | SKILL.md (summary only), io-contract.md (summary only) |

**Tool Permissions:** `allowed-tools` in SKILL.md is the single source of truth. The internal format is derived on-demand using the mapping function in `validate-skills.sh`. See [Tool Permissions](#tool-permissions-single-source-of-truth) above.

**Validation:** Run `.harmony/skills/scripts/validate-skills.sh` to detect issues.

See [Discovery](./discovery.md) for details.

### `display_name` Field

**Why:** The agentskills.io spec uses `name` (kebab-case, directory-matching) as the skill identifier. However, user interfaces benefit from human-readable display names. Adding `display_name` provides:

- **Readability** — "Research Synthesizer" is clearer than "research-synthesizer" in UI
- **Consistency** — Title Case derived from `id` via convention
- **Separation** — Machine-readable `id` vs human-readable `display_name`

**Implementation:**

```yaml
# In manifest.yml
skills:
  - id: research-synthesizer          # Machine-readable (matches directory)
    display_name: Research Synthesizer # Human-readable (Title Case)
```

**Convention:** `display_name` should be derived from `id` using Title Case transformation:

```
id: research-synthesizer → display_name: Research Synthesizer
id: refine-prompt       → display_name: Refine Prompt
```

**Validation:** The validation script checks that `display_name` follows this convention:

```bash
# In validate-skills.sh
id_to_title_case() {
    local skill_id="$1"
    echo "$skill_id" | sed 's/-/ /g' | \
        awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
}
```

**Trade-off:** This field is technically redundant (derivable at runtime). We include it because:

1. **Explicit over implicit** — No runtime derivation needed
2. **Override capability** — Allows non-standard display names if needed (e.g., "AI Code Review" instead of "Ai Code Review")
3. **Token cost is minimal** — ~3 tokens per skill

### Reference File Schemas

**Why:** The spec suggests `references/` for additional documentation but doesn't define structure. Harmony standardizes reference files to enable:

- **Machine parsing** — YAML frontmatter allows agents to extract structured data
- **Consistent expectations** — Skill authors know what files to create
- **Progressive disclosure** — Detailed content loads only when needed

**Implementation:**

| File | Purpose | Classification |
|------|---------|----------------|
| `io-contract.md` | Inputs, outputs, command-line usage | Universal |
| `safety.md` | Tool and file policies | Universal |
| `examples.md` | Worked examples | Universal |
| `behaviors.md` | Phase-by-phase execution | Partial (structure universal, content custom) |
| `validation.md` | Acceptance criteria | Partial (structure universal, content custom) |

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

### Using validate-skills.sh

The Harmony validation script provides additional checks:

```bash
# Validate all skills
.harmony/skills/scripts/validate-skills.sh

# Validate specific skill
.harmony/skills/scripts/validate-skills.sh my-skill

# Auto-scaffold missing entries
.harmony/skills/scripts/validate-skills.sh --fix

# Strict mode (treat trigger duplicates as errors)
.harmony/skills/scripts/validate-skills.sh --strict
```

**Token Validation:** For accurate token budget validation, install tiktoken:

```bash
pip install tiktoken
```

Without tiktoken, word count approximation is used (±20% variance). CI environments should install tiktoken for consistent validation.

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
- [ ] `io-contract.md` defines inputs, outputs, and command-line usage
- [ ] `safety.md` defines tool and file policies
- [ ] `examples.md` has at least one worked example
- [ ] `behaviors.md` documents execution phases
- [ ] `validation.md` defines acceptance criteria

#### Manifest and Registry

- [ ] Skill is listed in `.harmony/skills/manifest.yml` (Tier 1 discovery)
- [ ] `id` matches directory name and SKILL.md `name`
- [ ] `display_name` is present (human-readable name)
- [ ] `summary` is present for routing
- [ ] `triggers` are defined (if using natural language activation)
- [ ] Skill entry exists in `.harmony/skills/registry.yml` (extended metadata)
- [ ] `version` is defined in shared registry (not in SKILL.md)
- [ ] `commands` includes at least one slash command
- [ ] `allowed-tools` in SKILL.md lists all required tools (single source of truth)
- [ ] All tools in `allowed-tools` are recognized (can be mapped to internal format)
- [ ] No `outputs` in `.harmony/skills/registry.yml` (I/O paths go in workspace registry)
- [ ] I/O mappings exist in `.workspace/skills/registry.yml`

#### Execution

- [ ] Skill produces output in `outputs/` directory
- [ ] Skill creates run log in `logs/runs/`
- [ ] Output matches format defined in `.workspace/skills/registry.yml`
- [ ] All acceptance criteria are met

---

## See Also

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification
- [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) — Agent integration guide
- [Architecture](./architecture.md) — Implementation architecture
- [Reference Artifacts](./reference-artifacts.md) — Reference file schemas
- [Creation](./creation.md) — Creating new skills
