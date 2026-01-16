---
title: Skills Architecture
description: Hierarchical workspace model with scoped authority and progressive disclosure.
---

# Skills Architecture

This document describes the architectural design of the skills system, including the hierarchical workspace model, scope authority, and progressive disclosure.

---

## Workspace Definition

A `.workspace/` directory designates its **parent directory** as a workspace root. Workspaces can be nested at any level, creating a hierarchy.

```
repo/                              ← Root workspace (scope: repo/**)
├── .workspace/
├── src/
├── docs/                          ← Docs workspace (scope: docs/**)
│   ├── .workspace/
│   └── guides/
└── packages/
    └── kits/                      ← Kits workspace (scope: kits/**)
        ├── .workspace/
        ├── shared/
        └── flowkit/               ← FlowKit workspace (scope: flowkit/**)
            ├── .workspace/
            └── src/
```

---

## Workspace Resolution

When a skill is invoked, the system must determine which workspace context to use. This follows the **nearest ancestor** model, similar to how git finds the repository root.

### Resolution Algorithm

```
RESOLVE_WORKSPACE(cwd, input_paths, explicit_workspace):
  1. If explicit_workspace provided → use it
  2. Else if input_paths provided → find nearest .workspace/ ancestor of first input
  3. Else → find nearest .workspace/ ancestor of cwd
  4. If none found → error: "No workspace context"
```

### Resolution Priority

| Priority | Method | Description |
|----------|--------|-------------|
| 1 | Explicit flag | `--workspace=path/to/ws` overrides all |
| 2 | Input path | Nearest `.workspace/` ancestor of input files |
| 3 | Current directory | Nearest `.workspace/` ancestor of CWD |

### Finding the Nearest Workspace

Walk up from the starting directory until a `.workspace/` is found:

```
Starting: /repo/packages/kits/flowkit/src/
         ↑ check for .workspace/ → not found
         /repo/packages/kits/flowkit/
         ↑ check for .workspace/ → FOUND

Active workspace: flowkit
Workspace root: /repo/packages/kits/flowkit/
Scope: flowkit/**
```

### Examples

```bash
# CWD-based resolution (most common)
cd /repo/packages/kits/flowkit/src
/refine-prompt "add caching"
# → Resolves to flowkit workspace

# Input-based resolution
cd /repo
/research-synthesizer packages/kits/flowkit/notes/
# → Resolves to flowkit workspace (based on input path)

# Explicit override
cd /repo/packages/kits/flowkit/src
/refine-prompt --workspace=/repo "add caching"
# → Resolves to repo workspace (explicit override)
```

### Agent Harness Implementation

Agent harnesses should:

1. **Track CWD** — Maintain awareness of current working directory
2. **Resolve workspace** — Apply the resolution algorithm before skill execution
3. **Provide context** — Pass workspace root and scope to the skill
4. **Display status** — Optionally show active workspace in prompt/status

```
# Example status line showing active workspace
[flowkit] > /refine-prompt "add caching"
    ↑
    active workspace indicator
```

### No Workspace Found

If no `.workspace/` is found walking up from the starting point:

- **Error state** — Skills requiring workspace context cannot execute
- **Fallback** — Some read-only operations may proceed without workspace context
- **User action** — Create a `.workspace/` directory or specify `--workspace` explicitly

---

## Hierarchical Scope

Each workspace's scope includes its parent directory and **all descendants**, including directories that contain their own `.workspace/`.

### Scope Authority Rules

| Direction | Allowed | Description |
|-----------|---------|-------------|
| **DOWN** | ✓ | Can write into descendant workspaces |
| **UP** | ✗ | Cannot write into ancestor workspaces |
| **SIDEWAYS** | ✗ | Cannot write into sibling workspaces |

### Write Permission Matrix

| Workspace | Can Write To |
|-----------|--------------|
| **repo** | `repo/**` (includes `docs/**`, `kits/**`, `flowkit/**`) |
| **docs** | `docs/**` only |
| **kits** | `kits/**` (includes `flowkit/**`) |
| **flowkit** | `flowkit/**` only |

### Example: Who Can Write `flowkit/src/generated.ts`?

| Workspace | Permission | Reason |
|-----------|------------|--------|
| repo | ✓ | flowkit is a descendant |
| kits | ✓ | flowkit is a descendant |
| flowkit | ✓ | within own scope |
| docs | ✗ | flowkit is not a descendant of docs |

---

## Output Permission Tiers

Within each workspace, output locations follow a tiered permission model:

| Tier | Location | Declaration Required |
|------|----------|---------------------|
| **Tier 1** | `.workspace/skills/outputs/**` | None (always allowed) |
| **Tier 2** | `.workspace/**` | Registry declaration |
| **Tier 3** | `<workspace-root>/**` | Registry declaration |

**Default behavior:** Without explicit declaration, skills write to Tier 1:
```
.workspace/skills/outputs/<category>/<timestamp>-<name>.md
```

Custom paths (Tier 2 and 3) require registry declaration and are validated against the workspace's hierarchical scope.

---

## Skill Definition Tiers

```
┌─────────────────────────────────────────────────────────────────┐
│  .harmony/skills/              Shared Foundation                 │
│  ├── registry.yml              Skill catalog for routing        │
│  ├── _template/                Scaffolding for new skills       │
│  ├── refine-prompt/            Shared skill definition          │
│  │   ├── SKILL.md              Core instructions (<500 lines)   │
│  │   └── references/           Progressive disclosure content   │
│  └── research-synthesizer/                                      │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ I/O paths defined in
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  .workspace/skills/            Workspace I/O                     │
│  ├── registry.yml              I/O mappings (scope-validated)   │
│  ├── outputs/                  Default output location (Tier 1) │
│  ├── logs/runs/                Execution audit logs             │
│  └── sources/                  Input files                      │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ exposed via symlinks
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Host Adapters                 Agent Access                      │
│  .claude/skills/   .cursor/skills/   .codex/skills/             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Shared Foundation (`.harmony/skills/`)

Portable skill definitions that work across workspaces:

| Content | Purpose |
|---------|---------|
| `registry.yml` | Skill metadata for routing (no workspace-specific paths) |
| `_template/` | Scaffolding for new skills |
| `<skill-name>/SKILL.md` | Core skill instructions (required) |
| `<skill-name>/references/` | Detailed documentation (progressive disclosure) |
| `<skill-name>/scripts/` | Executable helpers (optional) |
| `<skill-name>/assets/` | Static resources (optional) |

---

## Workspace I/O (`.workspace/skills/`)

Workspace-specific configuration and outputs:

| Content | Purpose |
|---------|---------|
| `registry.yml` | Extends shared registry, adds I/O path mappings |
| `outputs/` | Default output location (Tier 1, always allowed) |
| `logs/runs/` | Execution audit logs |
| `sources/` | Input files for skills |

### Output Paths

Output paths are declared in `registry.yml` and validated against the workspace's hierarchical scope.

| Path Type | Example | Validation |
|-----------|---------|------------|
| **Default (Tier 1)** | `outputs/<category>/<file>` | Always allowed |
| **Workspace internal (Tier 2)** | `.workspace/projects/<project>/<file>` | Must be declared |
| **Workspace root (Tier 3)** | `src/generated/<file>` | Must be declared, scope-validated |
| **Descendant workspace** | `flowkit/docs/api.md` | Must be declared, scope-validated |

**Scope validation:** Paths are checked to ensure they fall within the workspace's hierarchical scope (can write down, not up or sideways).

---

## Host Adapters (Symlinks)

Symlinks expose shared skills to different agent hosts:

```bash
.claude/skills/refine-prompt -> ../../.harmony/skills/refine-prompt
.cursor/skills/refine-prompt -> ../../.harmony/skills/refine-prompt
.codex/skills/refine-prompt  -> ../../.harmony/skills/refine-prompt
```

**Setup:** Run `.harmony/skills/scripts/setup-harness-links.sh` to create symlinks, or create them manually:

```bash
# Manual symlink creation
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a skill to all harnesses
ln -s ../../.harmony/skills/refine-prompt .claude/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .codex/skills/refine-prompt
```

**Why symlinks?** Agent products discover skills in their own directories (`.claude/skills/`, `.cursor/skills/`, etc.). Symlinks allow multiple agents to share the same canonical skill definition while maintaining expected directory structures.

---

## Progressive Disclosure

Skills follow a **three-tier disclosure model** for token efficiency, as defined in the [agentskills.io specification](https://agentskills.io/what-are-skills):

| Tier | Content | When Loaded | Token Budget |
|------|---------|-------------|--------------|
| **Tier 1** | `name` + `description` (from registry or frontmatter) | Always (routing/discovery) | ~100 tokens |
| **Tier 2** | Full `SKILL.md` body | When skill activated | <5000 tokens |
| **Tier 3** | `references/`, `scripts/`, `assets/` | When specific detail needed | On demand |

### Loading Sequence

1. **Discovery** — Agent scans skill directories, parses frontmatter only
2. **Matching** — Agent matches user task to skill descriptions
3. **Activation** — User invokes skill (explicit or trigger), agent loads full `SKILL.md`
4. **Detail** — Agent loads reference files only when specific information needed

This approach keeps agents fast while giving them access to more context on demand.

---

## Design Principles

### Hierarchical Authority

- Parent workspaces can orchestrate across descendant workspaces
- Child workspaces remain focused and contained
- Sibling workspaces are independent

### Separation of Concerns

| Layer | Contains | Does NOT Contain |
|-------|----------|------------------|
| Shared (`.harmony/`) | Skill logic, behaviors, constraints | Workspace paths, local config |
| Workspace (`.workspace/`) | I/O paths, outputs, logs | Skill logic |
| Host Adapters | Symlinks only | Any actual content |

### Portability

Skills in `.harmony/skills/` can be:
- Copied to other repositories
- Shared via git submodules
- Published to skill registries

### Auditability

Every skill execution produces:
- Output artifacts (default or custom paths within scope)
- Run logs in `logs/runs/`
- Timestamped entries for traceability

---

## Path Validation

Output paths declared in the registry are validated at two points:

| Point | Action |
|-------|--------|
| **Registry load** | Validate paths are within hierarchical scope |
| **Execution time** | Re-validate before write; block out-of-scope writes |

### Validation Logic

```
VALIDATE_PATH(declared_path, workspace_root):
  1. Resolve path relative to workspace_root
  2. Normalize to absolute path
  3. Check: resolved_path starts with workspace_root
     - True: ✓ Valid (within scope)
     - False: ✗ Reject (outside hierarchical scope)
```

### Invalid Path Examples

```yaml
# In docs/.workspace/skills/registry.yml (scope: docs/**)
skill_mappings:
  generate-guide:
    outputs:
      - path: "../README.md"           # ✗ REJECTED: ancestor (repo)
      - path: "../packages/kits/x.md"  # ✗ REJECTED: sibling path
      - path: "guides/quickstart.md"   # ✓ Valid: within scope
```

---

## See Also

- [Registry](./registry.md) — Registry format and path declaration
- [Execution](./execution.md) — Run logging and scope enforcement
- [Reference Artifacts](./reference-artifacts.md) — Progressive disclosure content
