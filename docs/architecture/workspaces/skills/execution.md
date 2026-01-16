---
title: Skill Execution
description: Run logging, safety policies, and hierarchical scope enforcement.
---

# Skill Execution

This document covers what happens when a skill runs, including run logging, safety policies, and hierarchical scope enforcement.

---

## Run Logging

Every skill execution produces a log at `.workspace/skills/logs/runs/`:

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
  - .workspace/skills/outputs/prompts/20250115-refined.md  # or projects/<project>/...
tools_used:
  - filesystem.read
  - filesystem.write.outputs
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

Skills may only write to paths defined in their registry I/O mappings, validated against hierarchical scope:

| Tier | Path | Declaration |
|------|------|-------------|
| **Tier 1** | `.workspace/skills/outputs/**` | None required (default) |
| **Tier 1** | `.workspace/skills/logs/**` | None required (always permitted) |
| **Tier 2** | `.workspace/**` | Must declare in registry |
| **Tier 3** | `<workspace-root>/**` | Must declare in registry |

### Hierarchical Scope Enforcement

All output paths (Tier 2 and 3) are validated against the workspace's hierarchical scope:

| Direction | Allowed | Example |
|-----------|---------|---------|
| **DOWN** (descendants) | ✓ | repo workspace → `flowkit/README.md` |
| **UP** (ancestors) | ✗ | flowkit workspace → `../README.md` |
| **SIDEWAYS** (siblings) | ✗ | docs workspace → `../packages/kits/x.md` |

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
- Scope is too large (e.g., >20 files)
- Domain expertise is needed
- Self-critique reveals major issues

---

## Output Management

### Output Locations

Output paths are defined in the skill's registry I/O mapping and validated against hierarchical scope.

**Tier 1 — Default (no declaration needed):**

| Category | Path Pattern |
|----------|--------------|
| Prompts | `.workspace/skills/outputs/prompts/<timestamp>-<name>.md` |
| Drafts | `.workspace/skills/outputs/drafts/<timestamp>-<name>.md` |
| Reports | `.workspace/skills/outputs/reports/<timestamp>-<name>.md` |
| Logs | `.workspace/skills/logs/runs/<timestamp>-<skill>.md` |

**Tier 2 & 3 — Custom Paths (must declare, scope-validated):**

```yaml
outputs:
  # Tier 2: Within .workspace/
  - path: "projects/<project>/synthesis.md"

  # Tier 3: Workspace root (within scope)
  - path: "docs/generated/<name>.md"

  # Tier 3: Descendant workspace (within scope)
  - path: "flowkit/README.md"
```

Custom paths must fall within the workspace's hierarchical scope (can write down, not up or sideways).

### Timestamp Format

Use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

Example: `2025-01-15T12:00:00Z`

For filenames, use compact format: `YYYYMMDD-HHMMSS`

Example: `20250115-120000-refined.md`

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
│     ├── Load behaviors.md for phase details                     │
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
│     └── Log to logs/runs/                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## See Also

- [Architecture](./architecture.md) — Hierarchical workspace model and scope authority
- [Registry](./registry.md) — Path declaration and scope validation rules
- [Reference Artifacts](./reference-artifacts.md) — The `safety.md` and `validation.md` files
- [Invocation](./invocation.md) — How execution is triggered
