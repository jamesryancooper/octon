---
title: Specification Compliance
description: Conformance to agentskills.io specification, extensions, and validation.
spec_refs:
  - OCTON-SPEC-201
  - OCTON-SPEC-003
  - OCTON-SPEC-004
---

# Specification Compliance

This document describes how the Octon skills implementation relates to the [agentskills.io specification](https://agentskills.io/specification), including conformance, extensions, and validation.

---

## Spec Compliance

This implementation follows [agentskills.io/specification](https://agentskills.io/specification):

| Spec Requirement | Implementation |
|------------------|----------------|
| Required frontmatter: `name`, `description` | ✓ In `SKILL.md` |
| Optional: `license`, `compatibility`, `metadata`, `allowed-tools` | ✓ In `SKILL.md` |
| Capability declaration: `skill_sets`, `capabilities` | ✓ In `SKILL.md` and `manifest.yml` |
| Directory structure: `references/`, `scripts/`, `assets/` | ✓ Per spec |
| `SKILL.md` < 500 lines | ✓ Details in `references/` |
| Name matches skill `id` | ✓ Enforced; grouped directory variance documented below |
| Progressive disclosure | ✓ Four-tier model |

---

## Naming Policy

Octon uses globally unique skill IDs and grouped directories:

- Skill identity is the `id` (for example, `react-best-practices`).
- Filesystem layout may nest by domain (for example, `foundations/react/best-practices/`).
- Validation requires `SKILL.md` `name` to match the skill `id`; parent-directory mismatch is treated as an intentional grouped-directory variance when the manifest path is grouped.

This intentionally deviates from the strict agentskills.io parent-directory match rule while preserving unique, stable IDs for routing and cross-artifact alignment.

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
allowed-tools: Read Glob Grep Write(../prompts/*) Write(_ops/state/logs/*)
```

### Tool Reference

| `allowed-tools` | Internal Format | Description |
|-----------------|-----------------|-------------|
| `Read` | `filesystem.read` | Read files |
| `Write(_ops/state/runs/*)` | `filesystem.write.runs` | Write execution state |
| `Write(../{{category}}/*)` | `filesystem.write.deliverables` | Write deliverables to final destination |
| `Write(_ops/state/logs/*)` | `filesystem.write.logs` | Write to logs directory |
| `Glob` | `filesystem.glob` | Pattern matching for file discovery |
| `Grep` | `filesystem.grep` | Content search |
| `WebFetch` | `network.fetch` | HTTP requests (read-only) |
| `Shell` | `shell.execute` | Execute shell commands |
| `Task` | `agent.task` | Launch subagent tasks |

**Wildcard patterns:** `Write(path/*)` scopes write access to a specific directory.

### External Dependency Boundary

For active skills, non-minimal Bash scopes (anything beyond `mkdir`, `cp`, `mv`,
`ln`) must be accompanied by an explicit capability declaration:

- `external-dependent` for external runtime/toolchain dependencies
- `external-output` for external system side effects (deployments, remote state)

This keeps dependency assumptions explicit and auditable in manifest metadata.

### Mapping Function

The validation script includes a mapping function to convert `allowed-tools` to internal format:

```bash
# In validate-skills.sh
map_allowed_to_internal() {
    local allowed="$1"
    case "$allowed" in
        Read)                    echo "filesystem.read" ;;
        Write\(_ops/state/runs/\*\))        echo "filesystem.write.runs" ;;
        Write\(_ops/state/logs/\*\))        echo "filesystem.write.logs" ;;
        Write\(../*\))           echo "filesystem.write.deliverables" ;;
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
.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh
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
| Progressive disclosure | Layered skill discovery (manifest → registry → SKILL.md → references/) |
| Manifest and registry files | Centralized routing metadata for multiple skills |
| `display_name` field | Human-readable skill name for UI display |
| Reference file schemas | Standardized YAML frontmatter for machine parsing |
| Host adapter symlinks | Multi-agent discovery from single source |
| Pipelines | Compose multiple skills in sequence |
| Run logging | Auditable execution history |

### Progressive Disclosure

**Why:** The agentskills.io spec defines skills as self-contained directories. Octon extends this with a layered discovery model so agents load only what they need, minimizing token overhead:

- **Minimal discovery** — `manifest.yml` provides skill index without loading full definitions
- **On-demand detail** — `registry.yml` adds I/O mappings and extended metadata
- **Full instructions** — `SKILL.md` loaded only when a skill is activated
- **Deep reference** — `references/` loaded only when specific guidance is needed

**Implementation:**

| Layer | File | Contains |
|-------|------|----------|
| **Tier 1** | `manifest.yml` | Skill index (id, name, summary, triggers) |
| **Tier 2** | `registry.yml` | Extended metadata, I/O mappings, composition |
| **Tier 3** | `SKILL.md` | Full skill definition, behavior, instructions |
| **Tier 4** | `references/` | Phase details, safety, validation, examples |

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
| `summary`, `triggers`, `tags`, `display_name` | `.octon/capabilities/runtime/skills/manifest.yml` | SKILL.md |
| `version`, `commands`, `parameters`, `composition` | `.octon/capabilities/runtime/skills/registry.yml` | SKILL.md, io-contract.md |
| **Input/output paths** | **`.octon/capabilities/runtime/skills/registry.yml`** | SKILL.md (summary only), io-contract.md (summary only) |

**Tool Permissions:** `allowed-tools` in SKILL.md is the single source of truth. The internal format is derived on-demand using the mapping function in `validate-skills.sh`. See [Tool Permissions](#tool-permissions-single-source-of-truth) above.

**Validation:** Run `.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh` to detect issues.

See [Discovery](./discovery.md) for details.

### `display_name` Field

**Why:** The agentskills.io spec uses `name` (kebab-case, directory-matching) as the skill identifier. However, user interfaces benefit from human-readable display names. Adding `display_name` provides:

- **Readability** — "Synthesize Research" is clearer than "synthesize-research" in UI
- **Consistency** — Title Case derived from `id` via convention
- **Separation** — Machine-readable `id` vs human-readable `display_name`

**Implementation:**

```yaml
# In manifest.yml
skills:
  - id: synthesize-research          # Machine-readable (matches directory)
    display_name: Synthesize Research  # Human-readable (Title Case)
```

**Convention:** `display_name` should be derived from `id` using Title Case transformation:

```
id: synthesize-research → display_name: Synthesize Research
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

**Why:** The spec suggests `references/` for additional documentation but doesn't define structure. Octon standardizes reference files to enable:

- **Machine parsing** — YAML frontmatter allows agents to extract structured data
- **Consistent expectations** — Skill authors know what files to create
- **Progressive disclosure** — Detailed content loads only when needed

**Implementation:**

| File               | Archetype                                 | Purpose                        |
|--------------------|-------------------------------------------|--------------------------------|
| `io-contract.md`   | Complex (when: non-trivial I/O)           | Inputs, outputs, CLI usage     |
| `phases.md`        | Complex (when: distinct phases)           | Phase-by-phase execution       |
| `safety.md`        | Complex (when: tool/file policies)        | Tool and file policies         |
| `examples.md`      | Atomic (optional), Complex (when needed)  | Worked examples                |
| `validation.md`    | Complex (when: quality gates)             | Acceptance criteria            |
| `errors.md`        | Atomic (optional), Complex (optional)     | Error handling                 |
| `glossary.md`      | Atomic (optional), Complex (optional)     | Terminology                    |

> **Note:** Complex skills must have at least one pattern-triggered reference file. Add files based on exhibited patterns rather than following a fixed mandatory list.

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

The Octon validation script provides additional checks:

```bash
# Validate all skills
.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh

# Validate specific skill
.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh my-skill

# Auto-scaffold missing entries
.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --fix

# Strict mode (treat trigger duplicates as errors)
.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
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
- [ ] `phases.md` documents execution phases
- [ ] `validation.md` defines acceptance criteria

#### Manifest and Registry

- [ ] Skill is listed in `.octon/capabilities/runtime/skills/manifest.yml` (Tier 1 discovery)
- [ ] `id` matches directory name and SKILL.md `name`
- [ ] `display_name` is present (human-readable name)
- [ ] `summary` is present for routing
- [ ] `triggers` are defined (if using natural language activation)
- [ ] Skill entry exists in `.octon/capabilities/runtime/skills/registry.yml` (extended metadata)
- [ ] `version` is defined in `.octon/capabilities/runtime/skills/registry.yml` (not in SKILL.md)
- [ ] `commands` includes at least one slash command
- [ ] `allowed-tools` in SKILL.md lists all required tools (single source of truth)
- [ ] All tools in `allowed-tools` are recognized (can be mapped to internal format)
- [ ] I/O mappings exist in `.octon/capabilities/runtime/skills/registry.yml`

#### Execution

- [ ] Skill produces output in designated location (deliverables to `.octon/{{category}}/`, execution state to `_ops/state/runs/{{skill-id}}/`)
- [ ] Skill creates run log in `_ops/state/logs/{{skill-id}}/{{run-id}}.md`
- [ ] Output matches format defined in `.octon/capabilities/runtime/skills/registry.yml`
- [ ] All acceptance criteria are met

---

## See Also

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification
- [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) — Agent integration guide
- [Architecture](./architecture.md) — Implementation architecture
- [Reference Artifacts](./reference-artifacts.md) — Reference file schemas
- [Creation](./creation.md) — Creating new skills
