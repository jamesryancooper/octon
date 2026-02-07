---
title: Skills Design Conventions
description: Cross-cutting design decisions and patterns for skill implementation.
---

# Skills Design Conventions

This document defines cross-cutting design decisions that apply to all skills, particularly **complex archetype** skills that manage execution state and produce audit logs.

> **Why this document exists:** Design decisions were originally scattered across multiple files. This consolidates authoritative patterns for log structure, checkpoints, progressive disclosure, and correlations—ensuring consistency across all skills.

---

## Workspace Skills Directory Structure

**Decision:** Use an artifact-centric categorical structure with bounded top-level directories.

### Target Structure

```markdown
.harmony/capabilities/skills/
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
| `.harmony/capabilities/skills/` | Skill-first | **Authoring** — work on one skill at a time |
| `.harmony/capabilities/skills/` | Artifact-first | **Operations** — debug, clean up, monitor across skills |

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
.harmony/capabilities/skills/logs/
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
| `logs/{{skill-id}}/index.yml` | **Recommended for complex archetypes** | Rich metadata for complex skills; optional for atomic skills |

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
.harmony/capabilities/skills/runs/refactor/2026-01-19-rename-scratch/
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
      current_item: ".harmony/orchestration/workflows/example.md"
  5_verify:
    status: pending
  6_document:
    status: pending

resume:
  phase: 4
  instruction: "Continue from item 8 in change-manifest.md"
  last_completed: ".harmony/START.md"

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

**Decision:** Complex archetype skills escalate to missions when scope exceeds thresholds.

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

### Why These Thresholds

These thresholds are based on practical constraints of agent sessions and human oversight needs:

| Threshold | Value | Rationale |
|-----------|-------|-----------|
| **Files to modify** | >50 | **Session context limits.** Agents operate within context windows. Modifying 50+ files typically exceeds what can be safely tracked in a single session. Beyond this point, the agent cannot reliably hold all changes in context, increasing risk of inconsistency or missed updates. |
| **Match count** | >200 | **Verification burden.** Each match requires verification. At 200+ matches, manual review becomes impractical, and automated verification cannot catch all edge cases. The risk of unintended changes increases non-linearly. |
| **Modules affected** | >3 | **Architectural impact.** Changes spanning 3+ modules typically have architectural implications—interface changes, dependency updates, or cross-cutting concerns. These require human design review, not just automated execution. |
| **External dependencies** | Any | **Coordination scope.** External dependencies (APIs, services, packages) introduce factors outside the skill's control—version compatibility, breaking changes, rate limits. These require explicit planning and often human coordination. |
| **Multi-session required** | Yes | **State management complexity.** When work cannot complete in one session, state must be persisted and restored. This introduces failure modes (corrupted state, stale context) that warrant mission-level tracking and checkpoints. |

### Tuning These Thresholds

**These are starting heuristics, not fixed rules.** The values above are derived from practical experience with typical codebases and agent context windows, but your situation may differ. Treat them as initial settings to tune based on your specific constraints.

**When to raise thresholds:**

| Scenario | Adjustment | Rationale |
|----------|------------|-----------|
| Monorepo with many small files | Files: 50 → 100+ | Small, focused files are easier to track |
| Highly modular codebase | Modules: 3 → 5 | Loose coupling means less cross-module impact |
| Strong test coverage | Match count: 200 → 300 | Tests catch errors, reducing manual verification burden |
| Experienced team | All thresholds +25% | Team can handle larger reviews efficiently |

**When to lower thresholds:**

| Scenario | Adjustment | Rationale |
|----------|------------|-----------|
| Mission-critical system | All thresholds -50% | Higher stakes warrant more caution |
| Tightly coupled code | Modules: 3 → 2 | Changes ripple unpredictably |
| Weak test coverage | Match count: 200 → 100 | Manual review is the only safety net |
| Junior team or new codebase | All thresholds -25% | More oversight needed while building familiarity |
| Compliance/audit requirements | External deps: Any → None | All external changes need documented approval |

**How to determine your thresholds:**

1. **Start with defaults** — Use the values in the table above
2. **Run a few skills** — Observe where escalation triggers feel premature or too late
3. **Adjust incrementally** — Change one threshold at a time, by 25-50%
4. **Document your settings** — Override in `.harmony/capabilities/skills/configs/defaults.yml`:

```yaml
# .harmony/capabilities/skills/configs/defaults.yml
scope_limits:
  files_to_modify: 75      # Raised: monorepo with small files
  match_count: 150         # Lowered: limited test coverage
  modules_affected: 4      # Raised: modular architecture
  external_deps: any       # Unchanged
  multi_session: true      # Unchanged
```

**The guiding principle:** Escalate when the agent can no longer verify correctness independently. If a human couldn't reasonably review the changes in one sitting, the task is too large for a single skill execution. Trust your judgment—these heuristics exist to prompt that judgment, not replace it.

### Async and Long-Running Work

**Decision:** Skills execute synchronously within a single session. Async, long-running, and multi-session work is handled by **Missions**, not skills.

| Work Pattern | Handled By | Rationale |
|--------------|------------|-----------|
| Single-session, bounded scope | **Skill** | Agent maintains context throughout |
| Multi-session, requires coordination | **Mission** | Explicit state management, human checkpoints |
| Background/async execution | **Mission** | Session may disconnect; needs durable state |
| Parallel workstreams | **Mission** | Coordinates multiple skills/agents |

**Why skills are synchronous:**

1. **Context coherence** — Skills assume the agent maintains full context from start to finish
2. **Verification immediacy** — Output validation happens in the same session as execution
3. **User presence** — Skills may prompt for clarification; async breaks this assumption
4. **Simplicity** — No need for job queues, polling, or notification systems

**When to escalate to Mission:**

- Task cannot complete in one session (>30 minutes typical)
- Task requires human review between major phases
- Task spans multiple days or involves waiting for external input
- Task needs to survive session disconnection

**Mission handoff:** When a skill determines work exceeds session scope, it should:

1. Save current state to `runs/{{skill-id}}/{{run-id}}/`
2. Generate a mission template pre-filled with audit data
3. Report: "This task exceeds skill scope. Recommend creating a mission."
4. Provide the mission template path for user to review and initiate

See `.harmony/orchestration/workflows/` for mission templates and orchestration patterns.

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

**Decision:** Resume by reading `checkpoint.yml` to determine execution state and resume point. The agent always prompts the user before resuming.

### Resume Algorithm

```markdown
On skill invocation, check for existing checkpoint:

1. Look for `runs/{{skill-id}}/*{{identifier}}*/checkpoint.yml`
2. If found, read checkpoint.yml (~50 tokens)
3. Check `status` field and `current_phase`
4. Check `resume.instruction` for explicit guidance
5. ALWAYS prompt user before resuming (never auto-resume)

Resume decision matrix:

| checkpoint.status | current_phase | Action |
|-------------------|---------------|--------|
| completed | final | "Already complete. Start new run?" |
| failed | any | "Previous attempt failed at Phase {N}. Retry from failed phase or restart?" |
| in_progress | early (1-2) | "Resume from Phase {N}?" |
| in_progress | mid-execution | "Resume from {current_item} in Phase {N}?" |
| in_progress | late (verify/doc) | "Resume verification/documentation?" |
```

### Stale Checkpoint Detection

A checkpoint is considered **stale** when external state has changed since checkpoint creation:

| Staleness Signal | Detection | Action |
|------------------|-----------|--------|
| Files modified since checkpoint | Compare `checkpoint.started_at` with file mtimes in scope | Warn user: "Source files changed since checkpoint. Re-run audit phase?" |
| Checkpoint older than 24 hours | Compare `checkpoint.started_at` with current time | Warn user: "Checkpoint is {N} days old. Start fresh?" |
| Git commits since checkpoint | Compare HEAD with checkpoint's recorded commit (if tracked) | Warn user: "Repository has new commits. Re-run from audit?" |

**Staleness handling:**
- Agent always informs user of staleness concerns
- User decides: resume anyway, re-run affected phases, or start fresh
- Never silently resume with stale state

### User Prompt Templates

**Standard resume prompt:**

```markdown
Found existing run in progress:
  Run ID: {{run-id}}
  Status: {{status}}
  Phase: {{current_phase}} of {{total_phases}}
  Last activity: {{checkpoint.updated_at}}

Resume from Phase {{N}}? [Y/n/restart]
```

**Resume with staleness warning:**

```markdown
Found existing run in progress:
  Run ID: {{run-id}}
  Phase: {{current_phase}} of {{total_phases}}

⚠️  Warning: {{staleness_reason}}

Options:
  [R] Resume anyway (use existing checkpoint)
  [A] Re-run audit phase (refresh file discovery)
  [S] Start fresh (discard checkpoint)

Choice:
```

**Failed run prompt:**

```markdown
Found failed run:
  Run ID: {{run-id}}
  Failed at: Phase {{N}} ({{phase_name}})
  Error: {{resume.instruction}}

Options:
  [R] Retry from Phase {{N}}
  [S] Start fresh
  [I] Inspect checkpoint details

Choice:
```

---

## Continuity Artifact Detection

> **Terminology Note:** This section describes **workspace continuity files**—historical records (progress logs, ADRs, decisions) that preserve project history and require append-only protection during skill execution. For **skill execution state** (checkpoints, manifests) stored in `runs/{{skill-id}}/{{run-id}}/`, see [Checkpoint Storage](#checkpoint-storage) above. The two concepts serve different purposes: workspace continuity files preserve *project history*, while skill execution state enables *session recovery*.

**Decision:** Use convention-based allowlist with explicit configuration override.

### Default Patterns

```yaml
continuity_patterns:
  - "**/continuity/log.md"
  - "**/continuity/*.md"
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
2. Check against `.harmony/cognition/context/continuity.md` if it exists
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

Deliverables go directly to their **final destination** in `.harmony/{{category}}/`:

| Category | Purpose | Example Path |
|----------|---------|--------------|
| `prompts` | Refined prompts | `.harmony/scaffolding/prompts/` |
| `drafts` | Document drafts | `.harmony/output/drafts/` |
| `reports` | Analysis reports | `.harmony/output/reports/` |
| `analyses` | Code/data analyses | `.harmony/cognition/analyses/` |
| `scaffolds` | Generated scaffolds | Target directory |

#### Custom Destinations

Skills can write deliverables to custom locations beyond the standard categories. The `.harmony/` directory designates its **parent directory** as the workspace root (see [Architecture](./architecture.md#workspace-definition)), enabling three tiers of output locations:

| Tier | Scope | Example Path | Use Case |
|------|-------|--------------|----------|
| **Tier 1** | `.harmony/{{category}}/` | `.harmony/scaffolding/prompts/refined.md` | Standard deliverables |
| **Tier 2** | `.harmony/**` | `.harmony/custom/exports/data.json` | Custom workspace locations |
| **Tier 3** | `<workspace-root>/**` | `src/generated/api-client.ts` | Project source locations |

**Declaring custom destinations in `registry.yml`:**

```yaml
skills:
  generate-client:
    outputs:
      # Tier 1: Standard category
      - path: ".harmony/output/reports/{{{run-id}}}-generation.md"
        type: deliverable
      
      # Tier 2: Custom workspace location
      - path: ".harmony/exports/{{client-name}}.json"
        type: deliverable

      # Tier 3: Workspace root (parent of .harmony/)
      - path: "src/generated/{{client-name}}-client.ts"
        type: deliverable
```

**Scope validation:** All paths are validated against the workspace's hierarchical scope—skills can write **down** into descendant workspaces but never **up** to ancestors or **sideways** to siblings.

**Permission requirements:** Tier 3 paths (workspace root locations) require explicit declaration in `registry.yml`. Skills should document why project-level writes are necessary.

#### Operational Artifacts (`.harmony/capabilities/skills/`)

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
| **Deliverables** | Write to `.harmony/{{category}}/` (final destination) |
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
