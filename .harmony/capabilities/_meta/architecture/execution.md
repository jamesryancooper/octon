---
title: Skill Execution
description: Run logging, safety policies, and hierarchical scope enforcement.
---

# Skill Execution

This document covers what happens when a skill runs, including run logging, safety policies, and hierarchical scope enforcement.

---

## Run Logging

> **Note:** For skills with the `phased` capability, see [Design Conventions](../../practices/design-conventions.md) for the recommended log structure using `_ops/state/logs/{{skill-id}}/` with multi-level indexes.

Every skill execution produces a log. The log location follows this pattern:

```markdown
---
run_id: 2025-01-15T10-31-00Z-refine-prompt
skill_id: refine-prompt
skill_version: "2.1.1"
status: success  # success | partial | failed
started_at: 2025-01-15T10:31:00Z
ended_at: 2025-01-15T10:44:12Z

inputs:
  - "add caching to the api"
outputs:
  - .harmony/scaffolding/practices/prompts/20250115-refined.md
tools_used:
  - filesystem.read
  - filesystem.write
---

## Summary
- Refined prompt with codebase context
- Assigned Senior Backend Engineer persona

## Notes
- Flagged 2 ambiguities for user review
```

### Log Fields

| Field | Description |
|-------|-------------|
| `run_id` | Unique identifier (timestamp + skill name) |
| `skill_id` | Skill that was executed |
| `skill_version` | Version of the skill |
| `status` | Execution result: `success`, `partial`, `failed` |
| `started_at` | ISO 8601 timestamp of start |
| `ended_at` | ISO 8601 timestamp of completion |
| `inputs` | List of inputs provided |
| `outputs` | List of output file paths |
| `tools_used` | Tools invoked during execution |

### Status Values

| Status | Meaning |
|--------|---------|
| `success` | All phases completed, output valid |
| `partial` | Some phases completed, partial output produced |
| `failed` | Execution failed, no valid output |

---

## Safety Policies

Skills follow a **deny-by-default** tool policy.

### Tool Policy

| Level | Tools Allowed |
|-------|---------------|
| Read-only | `filesystem.read`, `filesystem.glob`, `filesystem.grep` |
| Write (scoped) | `filesystem.write.outputs`, `filesystem.write.logs` |
| Never | `filesystem.delete`, `filesystem.write.*` (arbitrary paths) |

### File Policy

Skills may only write to paths defined in their registry I/O mappings, validated against hierarchical scope. Skills produce two distinct artifact types with different permission models.

**Deliverables (Final Products):**

| Tier | Scope | Purpose |
|------|-------|---------|
| **Tier 1** | `.harmony/{{category}}/` | Standard deliverables (final destination) |
| **Tier 2** | `.harmony/**` | Custom harness locations (must declare) |
| **Tier 3** | `<harness-root>/**` | Project source locations (must declare) |

**Operational Artifacts (`.harmony/capabilities/runtime/skills/`):**

| Category | Path Pattern | Read/Write |
|----------|--------------|------------|
| `_ops/state/configs/` | `_ops/state/configs/{{skill-id}}/` | Read (skills), Write (user/setup) |
| `_ops/state/resources/` | `_ops/state/resources/{{skill-id}}/` | Read (skills), Write (user) |
| `_ops/state/runs/` | `_ops/state/runs/{{skill-id}}/{{run-id}}/` | Read/Write (skills) |
| `_ops/state/logs/` | `_ops/state/logs/{{skill-id}}/{{run-id}}.md` | Read/Write (skills) |

> **Note:** All `.harmony/capabilities/runtime/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern. Skills typically read from `_ops/state/configs/` and `_ops/state/resources/`, and write to `_ops/state/runs/` and `_ops/state/logs/`.

### Hierarchical Scope Enforcement

All output paths (Tier 2 and 3) are validated against the harness's hierarchical scope:

| Direction | Allowed | Example |
|-----------|---------|---------|
| **DOWN** (descendants) | ✓ | repo harness → `flowkit/README.md` |
| **UP** (ancestors) | ✗ | flowkit harness → `../README.md` |
| **SIDEWAYS** (siblings) | ✗ | docs harness → `../packages/kits/x.md` |

**Enforcement points:**
1. **Registry load** — Validate declared paths are within scope
2. **Execution time** — Re-validate before write; block out-of-scope writes

### Destructive Actions

**Policy:** Never permitted.

Skills must not:
- Delete files
- Overwrite source code
- Modify files outside designated output paths

---

## Behavioral Boundaries

Every skill should define boundaries in its `safety.md` reference file. Common boundaries include:

### Must Do

- State all assumptions explicitly
- Reference only files that exist
- Write only to designated output paths
- Log every execution

### Must Not

- Change the core intent of user input
- Execute external commands without explicit request
- Access network resources without declaration
- Modify source code directly

### Escalation Triggers

Skills must escalate to the user when:

- Unresolvable contradictions in input
- Intent is completely unclear
- Referenced files don't exist
- Request conflicts with constraints
- Scope is too large (>50 files)
- Domain expertise is needed
- Self-critique reveals major issues

---

## Output Management

### Output Locations

Output paths are defined in the skill's registry I/O mapping. Skills produce two types of artifacts:

**Deliverables (Final Products):**

| Category | Path Pattern |
|----------|--------------|
| Prompts | `.harmony/scaffolding/practices/prompts/{{timestamp}}-{{name}}.md` |
| Drafts | `.harmony/output/drafts/{{timestamp}}-{{name}}.md` |
| Reports | `.harmony/output/reports/analysis/{{timestamp}}-{{name}}.md` |

**Operational Artifacts (`.harmony/capabilities/runtime/skills/`):**

All operational categories follow the `{{category}}/{{skill-id}}/` pattern:

| Category | Path Pattern | Read/Write |
|----------|--------------|------------|
| Configs | `_ops/state/configs/{{skill-id}}/` | Read (skills), Write (user/setup) |
| Resources | `_ops/state/resources/{{skill-id}}/` | Read (skills), Write (user) |
| Checkpoints | `_ops/state/runs/{{skill-id}}/{{run-id}}/checkpoint.yml` | Read/Write (skills) |
| Manifests | `_ops/state/runs/{{skill-id}}/{{run-id}}/*.md` | Read/Write (skills) |
| Logs | `_ops/state/logs/{{skill-id}}/{{run-id}}.md` | Read/Write (skills) |

**Tier 2 & 3 — Custom Paths (must declare, scope-validated):**

```yaml
outputs:
  # Tier 2: Within .harmony/
  - path: "projects/{{project}}/synthesis.md"

  # Tier 3: Harness root (within scope)
  - path: "docs/generated/{{name}}.md"

  # Tier 3: Descendant harness (within scope)
  - path: "flowkit/README.md"
```

Custom paths must fall within the harness's hierarchical scope (can write down, not up or sideways).

### Timestamp Format

Use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

Example: `2025-01-15T12:00:00Z`

For filenames, use compact format: `YYYYMMDD-HHMMSS`

Example: `20250115-120000-refined.md`

---

## Placeholder Resolution

Output and input paths in registry.yml may contain placeholders that are resolved at runtime. This section documents the resolution rules.

### Placeholder Syntax

> **Convention Standardization:** All placeholders across templates and documentation use double curly braces `{{name}}`. This was chosen for consistency with industry-standard templating systems (Handlebars, Mustache, Jinja2) and to avoid collisions with shell variables, regex patterns, and JSON/YAML syntax.

Placeholders use **double curly braces with snake_case** names:

```
{{placeholder_name}}
```

**Convention:**
- Use `{{snake_case}}` format (double curly braces, snake_case names)
- This distinguishes placeholders from literal text
- Consistent with template systems (Jinja2, Mustache, etc.)
- Avoids collision with shell `${var}`, Python f-strings `{var}`, and regex `{n,m}`

**Examples:**
- `{{timestamp}}` — Not `<timestamp>` or `{timestamp}`
- `{{project_name}}` — Not `<project-name>` or `{{projectName}}`
- `{{skill_id}}` — Not `<skill>` or `{{skillId}}`

### Placeholder Usage Contexts

The `{{snake_case}}` format is used consistently across **three contexts**:

| Context | Purpose | Example |
|---------|---------|---------|
| **Path interpolation** | Runtime path resolution in registry | `.harmony/{{category}}/{{timestamp}}-{{name}}.md` |
| **Template fill-ins** | Skill authoring placeholders | `{{skill_name}}`, `{{Description}}` |
| **Output format examples** | Document structure in documentation | `**Generated:** {{timestamp}}` |

**Path interpolation:** Placeholders in `registry.yml` paths that are resolved at execution time. The agent substitutes actual values (e.g., `{{topic}}` becomes `api-design`). Note that `{{category}}` and `{{skill-id}}` are structural placeholders that represent fixed directory names (e.g., `configs`, `logs`, `refine-prompt`), while `{{timestamp}}`, `{{topic}}`, and `{{name}}` are runtime values resolved during execution.

**Template fill-ins:** Placeholders in `_scaffold/template/` files and reference file templates that skill authors replace with actual content when creating a new skill.

**Output format examples:** Placeholders in documentation showing what generated output documents will contain. These appear in SKILL.md "Output Format" sections and io-contract.md output structure examples to indicate where dynamic content appears.

**Why consistency matters:**
- Single format to learn and recognize
- Validation scripts can detect deprecated formats (`<placeholder>`, `[placeholder]`)
- Clear visual distinction from literal text and markdown syntax

### Standard Placeholders

| Placeholder | Resolution | Example |
|-------------|------------|---------|
| `{{timestamp}}` | ISO 8601 compact format: `YYYYMMDDTHHMMSSZ` | `20250115T103100Z` |
| `{{date}}` | Date portion only: `YYYY-MM-DD` | `2025-01-15` |
| `{{project}}` | User-provided parameter or inferred from input path | `auth-patterns` |
| `{{topic}}` | Derived from input folder name or user-provided | `api-design` |
| `{{name}}` | Skill output name or user-provided identifier | `refined` |
| `{{skill_id}}` | Skill ID being executed | `synthesize-research` |
| `{{category}}` | Output category (prompts, drafts, reports) | `drafts` |

### Resolution Rules

1. **User-provided values take precedence** — If a parameter matches a placeholder name, use the parameter value
2. **Infer from input** — Derive `{{project}}` or `{{topic}}` from input folder name if not explicitly provided
3. **Default to skill context** — Use skill ID for `{{skill_id}}`, execution category for `{{category}}`
4. **Timestamp at execution start** — All `{{timestamp}}` placeholders use the same value within a single execution

### Resolution Order

```
1. Explicit parameter (e.g., --project=auth)     → Use parameter value
2. Infer from input path (e.g., projects/auth/)  → Extract "auth" as project
3. Skill-defined default (from registry)         → Use registry default
4. Fail with clear error                         → "Cannot resolve {{placeholder}}"
```

### Examples

**Registry definition:**

```yaml
outputs:
  - path: "../../drafts/{{topic}}-synthesis.md"
```

**Invocation:**

```bash
/synthesize-research _ops/state/resources/synthesize-research/api-design/
```

**Resolution:**

| Placeholder | Source | Resolved Value |
|-------------|--------|----------------|
| `{{topic}}` | Inferred from input path (`api-design/`) | `api-design` |

**Result:** `.harmony/output/drafts/api-design-synthesis.md`

### Placeholder Validation

At execution time, validate that:

1. All placeholders in output paths can be resolved
2. Resolved paths remain within hierarchical scope
3. No unresolved `{{placeholder}}` patterns remain in final paths

If resolution fails, report the specific placeholder and suggest how to provide the value.

### Template Placeholders

Skill templates (e.g., `_scaffold/template/SKILL.md`) use the same `{{snake_case}}` convention for authoring placeholders:

| Template Placeholder | Purpose |
|---------------------|---------|
| `{{skill_name}}` | Skill identifier (matches directory name) |
| `{{skill_display_name}}` | Human-readable name (Title Case) |
| `{{skill_description}}` | Full description for SKILL.md |
| `{{skill_one_liner}}` | Single sentence value proposition |
| `{{author_name}}` | Skill author |
| `{{created_date}}` | Creation date (YYYY-MM-DD) |
| `{{updated_date}}` | Last update date (YYYY-MM-DD) |

When creating a new skill, replace all `{{placeholder}}` values with actual content.

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Skill Execution Flow                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. VALIDATE INPUT                                              │
│     ├── Check required parameters present                       │
│     ├── Validate input types                                    │
│     └── Verify file references exist                            │
│                                                                 │
│  2. CHECK SAFETY & SCOPE                                        │
│     ├── Verify tool permissions                                 │
│     ├── Validate output paths against hierarchical scope        │
│     │   ├── Can write DOWN (descendants): ✓                     │
│     │   ├── Cannot write UP (ancestors): ✗ BLOCK                │
│     │   └── Cannot write SIDEWAYS (siblings): ✗ BLOCK           │
│     └── Apply behavioral boundaries                             │
│                                                                 │
│  3. EXECUTE PHASES                                              │
│     ├── Load phases.md for phase details                        │
│     ├── Execute each phase in sequence                          │
│     └── Log progress                                            │
│                                                                 │
│  4. VALIDATE OUTPUT                                             │
│     ├── Check acceptance criteria                               │
│     ├── Verify output format                                    │
│     └── Run quality checklist                                   │
│                                                                 │
│  5. WRITE OUTPUT (scope-validated)                              │
│     ├── Re-validate path is within hierarchical scope           │
│     ├── Save to declared output path                            │
│     └── Log to _ops/state/logs/{{skill-id}}/{{run-id}}.md                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## See Also

- [Design Conventions](../../practices/design-conventions.md) — Log structure, checkpoints, and cross-cutting patterns
- [Architecture](./architecture.md) — Hierarchical harness model and scope authority
- [Discovery](./discovery.md) — Path declaration and scope validation rules
- [Reference Artifacts](./reference-artifacts.md) — The `safety.md` and `validation.md` files
- [Invocation](./invocation.md) — How execution is triggered
