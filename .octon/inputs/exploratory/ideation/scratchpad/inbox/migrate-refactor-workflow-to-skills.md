# Migration Planning: Refactor Workflow → Workflow Archetype Skill

## Objective

Plan the migration of `.octon/workflows/refactor/` to `.octon/skills/refactor/` following the workflow archetype pattern established in the workflows-vs-skills analysis. The goal is to consolidate this multi-phase procedural workflow into the production-ready skills infrastructure while preserving all critical functionality—especially the mandatory verification gate.

---

## Context Summary

### Source: Current Workflow Structure

```markdown

.octon/workflows/refactor/
├── 00-overview.md      # Core description, prerequisites, failure conditions
├── 01-define-scope.md  # Capture old/new patterns and variations
├── 02-audit.md         # Exhaustive search for all references
├── 03-plan.md          # Create manifest of required changes
├── 04-execute.md       # Make changes systematically
├── 05-verify.md        # MANDATORY GATE: Re-run audit, must return zero
└── 06-document.md      # Update continuity artifacts (append-only)

```

Key workflow characteristics:

- 6 sequential phases with clear completion criteria
- Mandatory verification gate (Phase 5) that loops back if failed
- Idempotency markers and checkpoint support
- Append-only rules for continuity artifacts
- Explicit failure conditions that halt execution

### Target: Skills Infrastructure

```markdown

.octon/skills/refactor/
├── SKILL.md                    # Core skill definition
└── references/
    ├── behaviors.md            # Phase-by-phase instructions
    ├── io-contract.md          # Inputs, outputs, dependencies
    ├── safety.md               # Tool policies, boundaries
    ├── validation.md           # Acceptance criteria
    └── examples.md             # Usage examples

```

Required integration points:

- `.octon/skills/manifest.yml` — Add skill entry with triggers
- `.octon/skills/registry.yml` — Add extended metadata (parameters, outputs, version)
- `.workspace/skills/registry.yml` — Define local output paths

### Analysis Recommendations (from workflows-vs-skills-analysis.md)

1. **Archetype designation:** Use `metadata.archetype: workflow` in frontmatter
2. **Verification gate:** Encode as agent-interpreted instruction with explicit loop-back
3. **Checkpoints:** Can be implemented via output paths and resume patterns
4. **I/O contracts:** Define explicit inputs (scope definition) and outputs (process report, execution log)
5. **Tool permissions:** Scope writes to outputs and logs directories
6. **Audit logging:** Required for every run in `logs/runs/`

---

## Planning Requirements

### 1. SKILL.md Structure Design

Design the main SKILL.md file:

- **Frontmatter requirements:**
  - `name: refactor`
  - `description:` (preserve the "exhaustive audit + mandatory verification" value proposition)
  - `allowed-tools:` (what tools does this skill need? Consider: Read, Glob, Grep, Write, Shell for git operations)
  - `metadata.archetype: workflow`
  - `metadata.checkpoints: true`

- **Core workflow section:**
  - Compress 6 phases into scannable overview (1-2 sentences each)
  - Emphasize the verification gate as non-negotiable

- **When to Use triggers:**
  - Derive from natural language patterns for refactoring tasks
  - Examples: "rename this module", "move these files", "refactor this pattern"

- **Boundaries:**
  - Migrate failure conditions from 00-overview.md
  - Add append-only rule for continuity artifacts
  - Define scope limits (what refactors are too large?)

- **Escalation conditions:**
  - When to stop and ask for human input
  - What verification failures require intervention

### 2. Reference File Mapping

Map workflow step files to skill reference files:

| Workflow File | Target Reference | Content Strategy |
|---------------|------------------|------------------|
| 01-define-scope.md | behaviors.md (Phase 1) | Include search variation checklist |
| 02-audit.md | behaviors.md (Phase 2) | Include search commands, result format |
| 03-plan.md | behaviors.md (Phase 3) | Include manifest template |
| 04-execute.md | behaviors.md (Phase 4) | Include execution rules table |
| 05-verify.md | behaviors.md (Phase 5) + validation.md | CRITICAL: Preserve the verification gate logic |
| 06-document.md | behaviors.md (Phase 6) | Include append-only rules |
| 00-overview.md | SKILL.md + io-contract.md | Split between main file and I/O contract |

### 3. I/O Contract Definition

Define explicit inputs and outputs:

**Inputs:**

- `scope_definition` — What is being refactored (old → new pattern)
- `file_types` — Optional override for file type list
- `exclusions` — Optional directories/patterns to skip

**Outputs:**

- `outputs/refactors/{timestamp}-{scope-slug}/`
  - `audit-manifest.md` — Pre-refactor audit results
  - `change-manifest.md` — Planned changes
  - `verification-report.md` — Post-refactor verification
  - `summary.md` — Process report with stats
- `logs/runs/{timestamp}-refactor.md` — Execution log

### 4. Verification Gate Implementation

The verification gate is the most critical element to preserve. Plan how to encode:

```markdown
## Phase 5: Verification Gate (MANDATORY)

**This phase MUST pass before the skill can complete.**

1. Re-run ALL audit searches from Phase 2
2. If ANY search returns results:
   - Document remaining references
   - **RETURN TO PHASE 4** — Do not proceed
   - Re-execute Phase 4 for remaining items
   - Re-run Phase 5
3. Repeat until all searches return zero results
4. Only then proceed to Phase 6

**Agent instruction:** You may NOT skip this phase. You may NOT declare completion if verification fails. The loop is mandatory.
```

### 5. Manifest and Registry Entries

**manifest.yml entry:**

```yaml
- id: refactor
  display_name: Refactor
  path: refactor/
  summary: "Execute verified codebase refactor with exhaustive audit."
  status: active
  tags:
    - refactor
    - rename
    - codebase
    - verification
  triggers:
    - "refactor this"
    - "rename across codebase"
    - "move and update references"
    - "systematic rename"
```

**registry.yml entry:**

```yaml
skill_mappings:
  refactor:
    version: "1.0.0"
    commands:
      - refactor
    parameters:
      - name: scope
        type: string
        required: true
        description: "What to refactor: 'old-pattern → new-pattern'"
      - name: file_types
        type: array
        required: false
        description: "File extensions to search (defaults to common types)"
      - name: dry_run
        type: boolean
        required: false
        default: false
        description: "Perform audit and plan without executing changes"
    outputs:
      - path: "outputs/refactors/"
        description: "Refactor artifacts (manifests, reports)"
    context:
      - ".workspace/conventions.md"
```

### 6. Migration Execution Plan

Define the steps to execute the migration:

1. **Create skill directory structure**
   - `.octon/skills/refactor/SKILL.md`
   - `.octon/skills/refactor/references/` (5 files)

2. **Write SKILL.md** — Core definition with phases overview

3. **Write references/behaviors.md** — Migrate all 6 phase instructions

4. **Write references/io-contract.md** — Define inputs, outputs, dependencies

5. **Write references/safety.md** — Tool policies, boundaries, append-only rules

6. **Write references/validation.md** — Acceptance criteria (verification gate!)

7. **Write references/examples.md** — Example refactor scenarios

8. **Update manifest.yml** — Add skill entry

9. **Update registry.yml** — Add extended metadata

10. **Test the skill** — Execute a real refactor to validate

11. **Deprecate workflow** — Mark `.octon/workflows/refactor/` for removal

---

## Deliverables

The migration plan should produce:

1. **SKILL.md draft** — Complete file ready for review
2. **Reference file outlines** — Structure and key content for each reference
3. **Manifest/registry entries** — Ready to add to YAML files
4. **Migration checklist** — Step-by-step execution plan with verification points
5. **Risk assessment** — What could go wrong, and how to mitigate

---

## Success Criteria

The migration is successful when:

- [ ] `refactor` skill executes the same 6-phase workflow
- [ ] Verification gate loop-back behavior is preserved
- [ ] Append-only continuity artifact rules are enforced
- [ ] I/O contracts are explicit and typed
- [ ] Audit logging captures every execution
- [ ] Natural language triggers route correctly
- [ ] Skill passes validation against agentskills.io spec
- [ ] Original workflow can be deprecated without loss of functionality

---

## Design Decisions

### 1. Checkpoint Storage

**Decision:** Use `.workspace/skills/outputs/refactors/{refactor-id}/` for intermediate state, with an explicit `checkpoint.yml` file as the source of truth for execution state.

**Rationale:**

- Skills own their outputs in `outputs/` — this is the established pattern
- `.workspace/progress/checkpoints/` was designed for the workflow primitive (now deprecated)
- Keeping all refactor artifacts together (audit, plan, verification) makes inspection easier
- The execution log goes to `logs/refactors/` (see Log Structure decision)
- An explicit checkpoint file supports progressive disclosure and faster resume

**Structure:**

```markdown
.workspace/skills/outputs/refactors/2026-01-19-rename-scratch-to-scratchpad/
├── checkpoint.yml        # Execution state (source of truth for resume)
├── scope.md              # Phase 1 output
├── audit-manifest.md     # Phase 2 output
├── change-manifest.md    # Phase 3 output
├── execution-log.md      # Phase 4 tracking (append-only during execution)
├── verification-report.md # Phase 5 output
└── summary.md            # Phase 6 final summary
```

**Checkpoint File Schema:**

```yaml
# checkpoint.yml - Source of truth for execution state
skill: refactor
version: "1.0.0"
refactor_id: "2026-01-19-rename-scratch-to-scratchpad"
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
      current_item: ".octon/workflows/example.md"
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

**Progressive Disclosure Tiers:**

| Tier | What to Read | Tokens | Use Case |
|------|--------------|--------|----------|
| 1 | `checkpoint.yml` | ~50 | Quick state check, resume decision |
| 2 | Phase outputs (scope.md, audit-manifest.md, etc.) | ~200-500 each | Understand specific phase results |
| 3 | `execution-log.md` | Variable | Debug partial execution, find exact stopping point |

**Benefits over file-presence inference:**

- Agent reads one file (~50 tokens) to understand full state
- Explicit `resume.instruction` eliminates guesswork
- Partial phase progress tracked (`4_execute.progress.completed_items: 7/13`)
- Execution metadata preserved (timestamps, parameters, metrics)
- Supports future tooling (status dashboards, cleanup scripts)

---

### 2. Log Structure

**Decision:** Use `logs/{skill-id}/` for skill-specific logs with multi-level indexes for progressive disclosure.

**Rationale:**

- Mirrors `outputs/{category}/` pattern for consistency
- Skill-specific grouping enables "show me all refactors" queries
- Log filename matches output directory for trivial correlation
- Multi-level indexes support both chronological and skill-specific queries

**Structure:**

```markdown
.workspace/skills/logs/
├── index.yml                          # Top-level: recent runs across ALL skills
├── refactors/
│   ├── index.yml                      # Skill-level: ALL refactor runs with rich metadata
│   ├── 2026-01-19-rename-scratch.md
│   └── 2026-01-20-move-utils.md
└── refine-prompt/
    ├── index.yml                      # (optional for simple skills)
    └── 2026-01-19T14-32-00.md
```

**Top-level Index Schema (`logs/index.yml`):**

```yaml
# logs/index.yml - Cross-skill chronological index (~50-100 tokens)
updated: "2026-01-20T10-15-00Z"

recent_runs:  # Last N runs across all skills
  - timestamp: "2026-01-20T10-00-00Z"
    skill: refactor
    id: "2026-01-20-move-utils"
    status: completed
    log: refactors/2026-01-20-move-utils.md

  - timestamp: "2026-01-19T14-45-00Z"
    skill: refactor
    id: "2026-01-19-rename-scratch"
    status: completed
    log: refactors/2026-01-19-rename-scratch.md

  - timestamp: "2026-01-19T14-32-00Z"
    skill: refine-prompt
    id: "2026-01-19T14-32-00"
    status: completed
    log: refine-prompt/2026-01-19T14-32-00.md

summary:
  total_runs: 47
  by_skill:
    refactor: 12
    refine-prompt: 30
    synthesize-research: 5
```

**Skill-level Index Schema (`logs/refactors/index.yml`):**

```yaml
# logs/refactors/index.yml - All refactor runs with rich metadata
skill: refactor
updated: "2026-01-20T10-15-00Z"

runs:
  - id: "2026-01-20-move-utils"
    scope: "utils/ → lib/utils/"
    status: completed
    timestamp: "2026-01-20T10-00-00Z"
    duration_seconds: 145
    metrics:
      files_audited: 45
      files_changed: 23
      verification_passed: true
    log: 2026-01-20-move-utils.md
    outputs: ../outputs/refactors/2026-01-20-move-utils/

  - id: "2026-01-19-rename-scratch"
    scope: ".scratch/ → .scratchpad/"
    status: completed
    timestamp: "2026-01-19T14-45-00Z"
    duration_seconds: 87
    metrics:
      files_audited: 28
      files_changed: 12
      verification_passed: true
    log: 2026-01-19-rename-scratch.md
    outputs: ../outputs/refactors/2026-01-19-rename-scratch/

# Quick lookup for "was X already refactored?"
scopes_completed:
  - ".scratch/ → .scratchpad/"
  - "utils/ → lib/utils/"
```

**Progressive Disclosure Tiers:**

| Tier | What to Read | Tokens | Question Answered |
|------|--------------|--------|-------------------|
| 1 | `logs/index.yml` | ~50 | "What ran recently across all skills?" |
| 2 | `logs/refactors/index.yml` | ~100 | "What refactors have been done? Was X refactored?" |
| 3 | Specific log file | ~200+ | "What exactly happened during this refactor?" |

**Index Requirements:**

| Index | Requirement | Rationale |
|-------|-------------|-----------|
| `logs/index.yml` | **Required** | All skills update this; enables cross-skill queries |
| `logs/{skill-id}/index.yml` | **Recommended for workflow archetypes** | Rich metadata for complex skills; optional for simple utilities |

**Key Benefits:**

- **"Was X already refactored?"** — Check `scopes_completed` in skill index without reading logs
- **Skill-specific metrics** — Refactor index tracks verification status, files changed
- **Top-level stays small** — Only recent N runs, not entire history
- **Correlation** — `outputs/refactors/2026-01-19-rename-scratch/` pairs with `logs/refactors/2026-01-19-rename-scratch.md`

---

### 3. Scope Limits

**Decision:** Escalate to a mission when:

- **>50 files** need modification
- **>3 distinct systems/modules** are affected
- **External dependencies** must be coordinated (APIs, databases, other repos)
- **ACP policy gates** are required at promotion boundaries (not just at start)
- **Execution will span multiple sessions** (too large to complete in one sitting)

**Implementation:**

```markdown
## Phase 2 Gate: Scope Check

After audit completes, evaluate:

| Metric | Threshold | Action |
|--------|-----------|--------|
| Files to modify | >50 | Escalate to mission |
| Match count | >200 | Escalate to mission |
| Modules affected | >3 | Warn user, offer escalation |
| External deps | Any | Escalate to mission |

If escalation needed:
1. Save audit manifest to outputs/
2. Report: "This refactor exceeds skill scope. Recommend creating a mission."
3. Provide mission template pre-filled with audit data
4. STOP — do not proceed to Plan phase
```

**Why 50 files?** The `refine-prompt` skill escalates at 20 files for prompt scope. Refactoring is more mechanical (search-replace), so a higher threshold is reasonable. 50 is a natural session boundary.

---

### 4. Git Integration

**Decision:** Do NOT auto-commit. Leave git operations to the user.

**Rationale:**

- **User control:** Users may want to review changes before committing
- **Commit granularity:** Users may want one commit or multiple
- **Commit messages:** Users have their own conventions
- **Branch strategy:** User decides if this is on main, a feature branch, etc.
- **Safety:** Auto-commits can't be easily undone if something goes wrong

**What the skill SHOULD do:**

````markdown
## Phase 6: Document

After verification passes:

1. Generate a suggested commit message:

   ```markdown
   refactor: rename `.scratch/` to `.scratchpad/`

    - Updated 47 references across 12 files
    - Renamed directory `.workspace/.scratch/` → `.workspace/.scratchpad/`
    - Verification: all audit searches return zero results
   ```

2. Inform user:
   "Refactor complete. Changes are unstaged. Suggested commit message saved to
   outputs/refactors/{id}/commit-message.txt"

3. Do NOT run `git add` or `git commit`

````

**Exception:** If the user explicitly passes `--commit` or `auto_commit: true`, the skill MAY create a commit. But this should be opt-in, not default.

---

### 5. Dry-Run Mode

**Decision:** `dry_run: true` executes **Phases 1-3 only** (Define Scope → Audit → Plan), then stops with a report.

**Behavior:**

| Phase | dry_run: false | dry_run: true |
|-------|----------------|---------------|
| 1. Define Scope | ✓ Execute | ✓ Execute |
| 2. Audit | ✓ Execute | ✓ Execute |
| 3. Plan | ✓ Execute | ✓ Execute |
| 4. Execute | ✓ Execute | ⏹ SKIP |
| 5. Verify | ✓ Execute | ⏹ SKIP |
| 6. Document | ✓ Execute | ⏹ SKIP (partial) |

**Dry-run output:**

```markdown
## Dry Run Complete

**Scope:** `.scratch/` → `.scratchpad/`

**Audit Summary:**
- 12 files contain references
- 47 total matches
- 1 directory to rename

**Change Manifest:**
- Phase 1: Rename `.workspace/.scratch/`
- Phase 2: Update 12 files
- [full manifest in outputs/refactors/{id}/change-manifest.md]

**Next steps:**
- Review the change manifest
- Run `/refactor ".scratch/ → .scratchpad/"` (without dry_run) to execute
```

The dry-run artifacts remain in `outputs/` so a subsequent real run can detect them and offer to resume from the plan phase.

---

### 6. Failure Recovery

**Decision:** Resume by reading `checkpoint.yml` to determine execution state and resume point.

**Algorithm:**

```markdown
## Resumption Logic

On skill invocation, check for existing checkpoint:

1. Look for `outputs/refactors/*{scope-slug}*/checkpoint.yml`
2. If found, read checkpoint.yml (~50 tokens):
   - Check `status` field (pending | in_progress | completed | failed)
   - Check `current_phase` for where execution stopped
   - Check `resume.instruction` for explicit resume guidance

3. Resume decision matrix:

| checkpoint.status | current_phase | Action |
|-------------------|---------------|--------|
| completed | 6 | "Refactor already complete. Start new refactor?" |
| failed | any | "Previous attempt failed at Phase {N}. Retry?" |
| in_progress | 1-3 | Resume from current_phase |
| in_progress | 4 | Read `phases.4_execute.progress` for exact item |
| in_progress | 5 (failed verify) | "Verification failed. Return to Phase 4?" |
| in_progress | 5 (passed) | Resume at Phase 6 |

4. For mid-Phase 4 resume:
   - Read `phases.4_execute.progress.completed_items` (e.g., 7)
   - Read `phases.4_execute.progress.current_item` (e.g., ".octon/workflows/example.md")
   - Resume from item 8 in change-manifest.md

5. Prompt user: "Found existing refactor in progress. Resume from Phase {N}? [Y/n]"
```

**Key insight:** The `checkpoint.yml` file is the source of truth for execution state. It provides:

- Explicit `resume.instruction` field for unambiguous guidance
- Partial phase progress (`completed_items: 7/13`) without parsing logs
- Execution metadata (timestamps, parameters) for debugging
- Single-file state discovery (~50 tokens vs. scanning multiple files)

**Checkpoint update rules:**

- Update `checkpoint.yml` at the START of each phase (set `status: in_progress`)
- Update again at the END of each phase (set `status: completed`, add `completed_at`)
- During Phase 4, update `progress.completed_items` after each file
- On failure, set `status: failed` with error details in `resume.instruction`

---

### 7. Continuity Artifact Detection

**Decision:** Use a convention-based allowlist with explicit configuration override.

**Default continuity patterns:**

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

**Detection algorithm:**

```markdown
## Continuity Artifact Detection

During Phase 3 (Plan), for each file in the change manifest:

1. Check against `continuity_patterns` (default list above)
2. Check against `.workspace/context/continuity.md` if it exists (project-specific overrides)
3. If match found:
   - Mark file as `continuity: true` in manifest
   - Add to "Phase 4: Continuity Artifacts (APPEND ONLY)" section
   - Include specific instructions: "Add new entry documenting the refactor; do NOT modify existing entries"

4. If uncertain (e.g., a file named `history.md` in an unexpected location):
   - Flag for user confirmation
   - Ask: "Is `docs/feature/history.md` a continuity artifact (append-only)?"
```

**Project-specific configuration** (optional):

```markdown
<!-- .workspace/context/continuity.md -->
# Continuity Artifacts

Files in this list should be treated as append-only during refactors.

## Explicit Inclusions
- `docs/release-notes/*.md`
- `internal/audit-trail.md`

## Explicit Exclusions (NOT continuity despite pattern match)
- `scripts/decisions/` — These are code, not historical records
```

**Why this approach?**

- Convention-based detection catches most cases automatically
- Explicit configuration handles project-specific needs
- Flagging uncertain cases prevents silent mistakes
- The append-only rule is enforced in Phase 4 instructions, not just detection

---

## Design Decisions Summary

| Question | Decision |
|----------|----------|
| Checkpoint storage | `outputs/refactors/{id}/` with `checkpoint.yml` as source of truth |
| Log structure | `logs/{skill-id}/` with multi-level indexes for progressive disclosure |
| Scope limits | >50 files OR >3 modules OR external deps → escalate to mission |
| Git integration | No auto-commit; provide suggested commit message |
| Dry-run mode | Execute Phases 1-3 only; save artifacts for potential resume |
| Failure recovery | Read `checkpoint.yml` to determine phase; resume from last complete |
| Continuity detection | Convention-based patterns + project config + user confirmation for edge cases |
