---
title: Skills Design Conventions
description: Cross-cutting design decisions and patterns for skill implementation.
---

# Skills Design Conventions

This document defines cross-cutting design decisions that apply to all skills, particularly **workflow archetype** skills that manage execution state and produce audit logs.

> **Why this document exists:** Design decisions were originally scattered across multiple files. This consolidates authoritative patterns for log structure, checkpoints, progressive disclosure, and correlations—ensuring consistency across all skills.

---

## Workspace Skills Directory Structure

**Decision:** Use an artifact-centric categorical structure with bounded top-level directories.

### Target Structure

```markdown
.workspace/skills/
├── manifest.yml              # Workspace skill index (extends .harmony)
├── registry.yml              # Workspace I/O mappings
├── configs/                  # Per-skill configuration overrides
│   └── {{skill-id}}/
├── resources/                # Per-skill input resources
│   └── {{skill-id}}/
├── runs/                     # Per-skill execution state
│   └── {{skill-id}}/{{run-id}}/
└── logs/                     # Per-skill execution logs
    ├── index.yml
    └── {{skill-id}}/
        ├── index.yml
        └── {{run-id}}.md
```

### Categorical Organization

All operational categories follow the `{{category}}/{{skill-id}}/` pattern:

| Category | Path Pattern | Purpose | Read/Write |
|----------|--------------|---------|------------|
| `configs/` | `configs/{{skill-id}}/` | Configuration overrides | Read (skills), Write (user/setup) |
| `resources/` | `resources/{{skill-id}}/` | Input materials (notes, docs, data) | Read (skills), Write (user) |
| `runs/` | `runs/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) | Read/Write (skills) |
| `logs/` | `logs/{{skill-id}}/{{run-id}}.md` | Execution history | Read/Write (skills) |

### Rationale

**Authoring vs. Operations distinction:**

| Directory | Organization | Primary Purpose |
|-----------|--------------|-----------------|
| `.harmony/skills/` | Skill-first | **Authoring** — work on one skill at a time |
| `.workspace/skills/` | Artifact-first | **Operations** — debug, clean up, monitor across skills |

This intentional difference optimizes each directory for its primary use case.

**Bounded top-level for scalability:**

| Skill Count | Top-Level Entries |
|-------------|-------------------|
| 5 skills | 6 entries |
| 50 skills | 6 entries |
| 100 skills | 6 entries |

The top-level remains fixed at 6 entries (manifest, registry, configs, resources, runs, logs) regardless of skill count.

**Cross-skill operational queries:**

| Query | Command |
|-------|---------|
| All recent runs | `cat logs/index.yml` |
| All logs across skills | `ls logs/` |
| All refactor artifacts | `ls */refactor/` |
| Disk usage by category | `du -sh configs/ resources/ runs/ logs/` |
| Clean old runs | `find runs/ -maxdepth 2 -name "2025-*" -type d` |

### Permission Patterns

Declarative, category-based permissions:

```yaml
allowed-tools: >
  Read
  Glob
  Grep
  Write(runs/*)       # execution state
  Write(logs/*)       # execution logs
```

Skills typically read from `configs/` and `resources/`, and write to `runs/` and `logs/`. However, this is not always the case—some skills may also read from `runs/` or `logs/` to determine current state or progress.

---

## Log Structure

**Decision:** Use `logs/{{skill-id}}/` for skill-specific logs with multi-level indexes.

### Directory Structure

```markdown
.workspace/skills/logs/
├── index.yml                          # Top-level: recent runs across ALL skills
├── refactor/
│   ├── index.yml                      # Skill-level: ALL refactor runs with metadata
│   ├── 2026-01-19-rename-scratch.md
│   └── 2026-01-20-move-utils.md
├── create-skill/
│   ├── index.yml                      # Skill-level: ALL create-skill runs
│   └── 2026-01-20-analyze-codebase.md
└── refine-prompt/
    ├── index.yml                      # Optional for simple skills
    └── 2026-01-19T14-32-00.md
```

### Rationale

- **Skill-specific grouping** enables queries like "show me all refactors"
- **Log filename matches runs directory** for trivial correlation
- **Multi-level indexes** support both chronological and skill-specific queries
- **Mirrors `runs/{{skill-id}}/`** pattern for consistency

### Top-Level Index Schema

```yaml
# logs/index.yml - Cross-skill chronological index (~50-100 tokens)
updated: "2026-01-20T10:15:00Z"

recent_runs:  # Last N runs across all skills
  - timestamp: "2026-01-20T10:00:00Z"
    skill: refactor
    id: "2026-01-20-move-utils"
    status: completed
    log: refactor/2026-01-20-move-utils.md

  - timestamp: "2026-01-19T14:45:00Z"
    skill: refactor
    id: "2026-01-19-rename-scratch"
    status: completed
    log: refactor/2026-01-19-rename-scratch.md

summary:
  total_runs: 47
  by_skill:
    refactor: 12
    create-skill: 5
    refine-prompt: 30
```

### Skill-Level Index Schema

```yaml
# logs/refactor/index.yml - All refactor runs with rich metadata
skill: refactor
updated: "2026-01-20T10:15:00Z"

runs:
  - id: "2026-01-20-move-utils"
    scope: "utils/ → lib/utils/"
    status: completed
    timestamp: "2026-01-20T10:00:00Z"
    duration_seconds: 145
    metrics:
      files_audited: 45
      files_changed: 23
      verification_passed: true
    log: 2026-01-20-move-utils.md
    artifacts: ../runs/refactor/2026-01-20-move-utils/

# Quick lookup for "was X already done?"
scopes_completed:
  - ".scratch/ → .scratchpad/"
  - "utils/ → lib/utils/"
```

### Index Requirements

| Index | Requirement | Rationale |
|-------|-------------|-----------|
| `logs/index.yml` | **Required** | All skills update this; enables cross-skill queries |
| `logs/{{skill-id}}/index.yml` | **Recommended for workflow archetypes** | Rich metadata for complex skills; optional for simple utilities |

### Key Benefits

- **Quick state discovery:** "Was X already done?" → Check `scopes_completed` in skill index
- **Skill-specific metrics:** Track verification status, files changed, etc.
- **Top-level stays small:** Only recent N runs, not entire history
- **Correlation:** `runs/refactor/2026-01-19-rename-scratch/` pairs with `logs/refactor/2026-01-19-rename-scratch.md`

---

## Checkpoint Storage

**Decision:** Use `runs/{{skill-id}}/{{run-id}}/checkpoint.yml` as the source of truth for execution state.

### Directory Structure

```markdown
.workspace/skills/runs/refactor/2026-01-19-rename-scratch/
├── checkpoint.yml        # Execution state (source of truth for resume)
├── scope.md              # Phase 1 output
├── audit-manifest.md     # Phase 2 output
├── change-manifest.md    # Phase 3 output
├── execution-log.md      # Phase 4 tracking (append-only during execution)
├── verification-report.md # Phase 5 output
└── summary.md            # Phase 6 final summary
```

### Rationale

- **Skills write execution state** to `runs/` — keeps checkpoints and manifests separate from deliverables
- **Keeping all artifacts together** makes inspection easier
- **Explicit checkpoint file** supports progressive disclosure and faster resume
- **Correlates with log files** via matching `{{skill-id}}/{{run-id}}`

### Checkpoint File Schema

```yaml
# checkpoint.yml - Source of truth for execution state
skill: refactor
version: "1.0.0"
run_id: "2026-01-19-rename-scratch"
scope: ".scratch/ → .scratchpad/"

status: in_progress  # pending | in_progress | completed | failed

current_phase: 4
phases:
  1_define_scope:
    status: completed
    completed_at: "2026-01-19T14:32:00Z"
    output: scope.md
  2_audit:
    status: completed
    completed_at: "2026-01-19T14:33:15Z"
    output: audit-manifest.md
    metrics:
      files_found: 12
      total_matches: 47
  3_plan:
    status: completed
    completed_at: "2026-01-19T14:34:02Z"
    output: change-manifest.md
  4_execute:
    status: in_progress
    started_at: "2026-01-19T14:34:10Z"
    output: execution-log.md
    progress:
      total_items: 13
      completed_items: 7
      current_item: ".harmony/workflows/example.md"
  5_verify:
    status: pending
  6_document:
    status: pending

resume:
  phase: 4
  instruction: "Continue from item 8 in change-manifest.md"
  last_completed: ".workspace/START.md"

parameters:
  dry_run: false
  auto_commit: false
  file_types: [md, yml, yaml, json, ts]
```

### Checkpoint Update Rules

- Update at the **START** of each phase (set `status: in_progress`)
- Update at the **END** of each phase (set `status: completed`, add `completed_at`)
- During long phases, update `progress.*` fields after each item
- On failure, set `status: failed` with error details in `resume.instruction`

---

## Progressive Disclosure Tiers

**Decision:** Use tiered state discovery to minimize token usage when checking execution state.

### Tier Model

| Tier | What to Read | Tokens | Question Answered |
|------|--------------|--------|-------------------|
| 1 | `logs/index.yml` | ~50 | "What ran recently across all skills?" |
| 2 | `logs/{{skill-id}}/index.yml` | ~100 | "What {{skill}} runs have been done? Was X already done?" |
| 3 | `checkpoint.yml` | ~50 | "What's the state of this specific run?" |
| 4 | Phase outputs (scope.md, etc.) | ~200-500 each | "What were the results of phase N?" |
| 5 | `execution-log.md` | Variable | "Debug partial execution, find exact stopping point" |

### Benefits

- Agent reads **one file (~50 tokens)** to understand full state
- Explicit `resume.instruction` eliminates guesswork
- Partial phase progress tracked without parsing logs
- Execution metadata preserved (timestamps, parameters, metrics)

---

## Runs-Log Correlation

**Decision:** Execution state directory names MUST match log file names for easy correlation.

### Pattern

```markdown
runs/{{skill-id}}/{{run-id}}/       ← Execution state (checkpoint, manifests) for session recovery
logs/{{skill-id}}/{{run-id}}.md     ← Execution log
```

### Examples

| Skill | Run ID | Artifacts | Log |
|-------|--------|-----------|-----|
| refactor | `2026-01-20-move-utils` | `runs/refactor/2026-01-20-move-utils/` | `logs/refactor/2026-01-20-move-utils.md` |
| create-skill | `2026-01-20-analyze-codebase` | `runs/create-skill/2026-01-20-analyze-codebase/` | `logs/create-skill/2026-01-20-analyze-codebase.md` |

### Run ID Format

```markdown
{{timestamp}}-{{identifier}}
```

Where:

- `{{timestamp}}` = `YYYY-MM-DD` (date only for most skills)
- `{{identifier}}` = scope slug, skill name, or other unique identifier

Examples:

- `2026-01-20-rename-scratch` (refactor scope)
- `2026-01-20-analyze-codebase` (created skill name)
- `2026-01-20T14-32-00` (timestamp only for simple skills)

---

## Scope Limits

**Decision:** Workflow archetype skills escalate to missions when scope exceeds thresholds.

### Thresholds

| Metric | Threshold | Action |
|--------|-----------|--------|
| Files to modify | >50 | Escalate to mission |
| Match count | >200 | Escalate to mission |
| Modules affected | >3 | Warn user, offer escalation |
| External deps | Any | Escalate to mission |
| Multi-session required | Yes | Escalate to mission |

### Implementation

After audit/discovery phase, evaluate scope:

```markdown
## Scope Check Gate

If escalation needed:
1. Save artifacts to runs/{{skill-id}}/{{run-id}}/
2. Report: "This task exceeds skill scope. Recommend creating a mission."
3. Provide mission template pre-filled with audit data
4. STOP — do not proceed to execution phase
```

### Rationale

- **50 files** is a natural session boundary
- **3 modules** indicates architectural impact requiring human oversight
- **External dependencies** require coordination beyond single-skill scope

---

## Git Integration

**Decision:** Skills do NOT auto-commit. Git operations are left to the user.

### Rationale

- **User control:** Users may want to review changes before committing
- **Commit granularity:** Users may want one commit or multiple
- **Commit messages:** Users have their own conventions
- **Branch strategy:** User decides if this is on main, a feature branch, etc.
- **Safety:** Auto-commits can't be easily undone if something goes wrong

### What Skills SHOULD Do

1. **Generate a suggested commit message** with summary of changes
2. **Save commit message** to `runs/{{skill-id}}/{{run-id}}/commit-message.txt`
3. **Inform user:** "Changes are unstaged. Suggested commit message saved."
4. **Do NOT** run `git add` or `git commit`

### Exception

If the user explicitly passes `--commit` or `auto_commit: true`, the skill MAY create a commit. But this is **opt-in, not default**.

---

## Dry-Run Mode

**Decision:** `dry_run: true` executes discovery/planning phases only, then stops with a report.

### Behavior

| Phase Type | dry_run: false | dry_run: true |
|------------|----------------|---------------|
| Discovery (scope, audit) | ✓ Execute | ✓ Execute |
| Planning (manifest) | ✓ Execute | ✓ Execute |
| Execution (changes) | ✓ Execute | ⏹ SKIP |
| Verification | ✓ Execute | ⏹ SKIP |
| Documentation | ✓ Execute | ⏹ SKIP (partial) |

### Dry-Run Output

```markdown
## Dry Run Complete

**Scope:** {scope description}

**Discovery Summary:**
- X files contain references
- Y total matches
- Z items to change

**Change Manifest:**
- [full manifest in runs/{{skill-id}}/{{run-id}}/change-manifest.md]

**Next steps:**
- Review the change manifest
- Run `/{{skill}} {{args}}` (without dry_run) to execute
```

### Artifact Preservation

Dry-run artifacts remain in `runs/` so a subsequent real run can detect them and offer to resume from the planning phase.

---

## Failure Recovery

**Decision:** Resume by reading `checkpoint.yml` to determine execution state and resume point.

### Resume Algorithm

```markdown
On skill invocation, check for existing checkpoint:

1. Look for `runs/{{skill-id}}/*{{identifier}}*/checkpoint.yml`
2. If found, read checkpoint.yml (~50 tokens)
3. Check `status` field and `current_phase`
4. Check `resume.instruction` for explicit guidance

Resume decision matrix:

| checkpoint.status | current_phase | Action |
|-------------------|---------------|--------|
| completed | final | "Already complete. Start new run?" |
| failed | any | "Previous attempt failed at Phase {N}. Retry?" |
| in_progress | early | Resume from current_phase |
| in_progress | mid-execution | Read progress.* for exact item |
| in_progress | verification | "Verification in progress. Continue?" |
```

### User Prompt

```markdown
Found existing run in progress:
  Run ID: {{run-id}}
  Status: {status}
  Phase: {current_phase}

Resume from Phase {N}? [Y/n]
```

---

## Continuity Artifact Detection

> **Terminology Note:** This section describes **workspace continuity files**—historical records (progress logs, ADRs, decisions) that preserve project history and require append-only protection during skill execution. For **skill execution state** (checkpoints, manifests) stored in `runs/{{skill-id}}/{{run-id}}/`, see [Checkpoint Storage](#checkpoint-storage) above. The two concepts serve different purposes: workspace continuity files preserve *project history*, while skill execution state enables *session recovery*.

**Decision:** Use convention-based allowlist with explicit configuration override.

### Default Patterns

```yaml
continuity_patterns:
  - "**/progress/log.md"
  - "**/progress/*.md"
  - "**/decisions/*.md"
  - "**/context/decisions.md"
  - "**/CHANGELOG.md"
  - "**/HISTORY.md"
  - "**/.history/**"
  - "**/ADR-*.md"
  - "**/adr-*.md"
```

### Detection Algorithm

During planning phase, for each file in the change manifest:

1. Check against `continuity_patterns` (default list above)
2. Check against `.workspace/context/continuity.md` if it exists
3. If match found:
   - Mark file as `continuity: true` in manifest
   - Add to "Continuity Artifacts (APPEND ONLY)" section
   - Include instructions: "Add new entry; do NOT modify existing entries"
4. If uncertain, flag for user confirmation

### Continuity Artifact Rules

- **APPEND ONLY** during skill execution
- Never modify or delete existing entries
- Add new entries documenting the change
- Preserve historical record integrity

---

## Naming Conventions

### Skill IDs

- **Format:** `lowercase-with-hyphens` (kebab-case)
- **Pattern:** `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- **Length:** 1-64 characters
- **Convention:** Verb-noun (action-oriented)

**Good:** `refine-prompt`, `analyze-codebase`, `generate-report`
**Bad:** `prompt-refiner`, `codebase-analyzer`, `ReportGenerator`

### Run IDs

- **Format:** `{{timestamp}}-{{identifier}}`
- **Timestamp:** `YYYY-MM-DD` or `YYYY-MM-DDTHH-MM-SS`
- **Identifier:** Scope slug, skill name, or unique descriptor

**Examples:**

- `2026-01-20-rename-scratch`
- `2026-01-20-analyze-codebase`
- `2026-01-20T14-32-00-refined`

### Output Locations

Skills produce two distinct artifact types with different storage patterns:

#### Deliverables (Final Products)

Deliverables go directly to their **final destination** in `.workspace/{{category}}/`:

| Category | Purpose | Example Path |
|----------|---------|--------------|
| `prompts` | Refined prompts | `.workspace/prompts/` |
| `drafts` | Document drafts | `.workspace/drafts/` |
| `reports` | Analysis reports | `.workspace/reports/` |
| `analyses` | Code/data analyses | `.workspace/analyses/` |
| `scaffolds` | Generated scaffolds | Target directory |

#### Custom Destinations

Skills can write deliverables to custom locations beyond the standard categories. The `.workspace/` directory designates its **parent directory** as the workspace root (see [Architecture](./architecture.md#workspace-definition)), enabling three tiers of output locations:

| Tier | Scope | Example Path | Use Case |
|------|-------|--------------|----------|
| **Tier 1** | `.workspace/{{category}}/` | `.workspace/prompts/refined.md` | Standard deliverables |
| **Tier 2** | `.workspace/**` | `.workspace/custom/exports/data.json` | Custom workspace locations |
| **Tier 3** | `<workspace-root>/**` | `src/generated/api-client.ts` | Project source locations |

**Declaring custom destinations in `registry.yml`:**

```yaml
skills:
  generate-client:
    outputs:
      # Tier 1: Standard category
      - path: ".workspace/reports/{{{run-id}}}-generation.md"
        type: deliverable
      
      # Tier 2: Custom workspace location
      - path: ".workspace/exports/{{client-name}}.json"
        type: deliverable
      
      # Tier 3: Workspace root (parent of .workspace/)
      - path: "src/generated/{{client-name}}-client.ts"
        type: deliverable
```

**Scope validation:** All paths are validated against the workspace's hierarchical scope—skills can write **down** into descendant workspaces but never **up** to ancestors or **sideways** to siblings.

**Permission requirements:** Tier 3 paths (workspace root locations) require explicit declaration in `registry.yml`. Skills should document why project-level writes are necessary.

#### Operational Artifacts (`.workspace/skills/`)

Operational artifacts use the categorical `{{category}}/{{skill-id}}/` pattern:

| Category | Path Pattern | Purpose |
|----------|--------------|---------|
| `configs/` | `configs/{{skill-id}}/` | Per-skill configuration overrides |
| `resources/` | `resources/{{skill-id}}/` | Per-skill input materials |
| `runs/` | `runs/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `logs/` | `logs/{{skill-id}}/{{run-id}}.md` | Execution history |

**Correlation pattern:** `logs/{{skill-id}}/{{run-id}}.md` pairs with `runs/{{skill-id}}/{{run-id}}/`

---

## Design Decision Summary

| Topic | Decision |
|-------|----------|
| **Directory structure** | Artifact-centric categorical structure with bounded top-level |
| **Category pattern** | All categories follow `{{category}}/{{skill-id}}/` pattern |
| **Log structure** | `logs/{{skill-id}}/` with multi-level indexes |
| **Checkpoint storage** | `runs/{{skill-id}}/{{run-id}}/checkpoint.yml` as source of truth |
| **Deliverables** | Write to `.workspace/{{category}}/` (final destination) |
| **Operational artifacts** | Write to `configs/`, `resources/`, `runs/`, `logs/` |
| **Progressive disclosure** | Tiered state discovery (index → checkpoint → phase outputs) |
| **Runs-log correlation** | `runs/{{skill-id}}/{{run-id}}/` pairs with `logs/{{skill-id}}/{{run-id}}.md` |
| **Scope limits** | >50 files or >3 modules → escalate to mission |
| **Git integration** | No auto-commit; provide suggested commit message |
| **Dry-run mode** | Execute discovery/planning phases only |
| **Failure recovery** | Resume via checkpoint.yml with explicit instructions |
| **Continuity detection** | Convention-based patterns + project config |

---

## See Also

- [Execution](./execution.md) — Run logging format and safety policies
- [Architecture](./architecture.md) — Hierarchical workspace model
- [Reference Artifacts](./reference-artifacts.md) — Archetype system and file purposes
- [Discovery](./discovery.md) — Manifest and registry structure
