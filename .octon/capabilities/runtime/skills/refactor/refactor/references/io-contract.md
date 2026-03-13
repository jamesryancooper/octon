---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Write(_ops/state/runs/*) Write(_ops/state/logs/*) Bash(mv) Bash(mkdir)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the refactor skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `scope` | text | Yes | — | What to refactor: `'old-pattern → new-pattern'` |
| `file_types` | text | No | `md,yml,yaml,json,ts,js` | Comma-separated file extensions |
| `dry_run` | boolean | No | `false` | Execute phases 1-3 only (audit and plan) |
| `exclusions` | text | No | `node_modules,.git,dist` | Patterns to skip |

## Output Structure

All execution state artifacts are written to `.octon/capabilities/runtime/skills/_ops/state/runs/refactor/{{refactor-id}}/` for session recovery:

```
_ops/state/runs/refactor/{{refactor-id}}/
├── checkpoint.yml        # Execution state (source of truth for resume)
├── scope.md              # Phase 1: Scope definition
├── audit-manifest.md     # Phase 2: Audit results
├── change-manifest.md    # Phase 3: Planned changes
├── execution-log.md      # Phase 4: Execution tracking
├── verification-report.md # Phase 5: Verification results
├── summary.md            # Phase 6: Final summary
└── commit-message.txt    # Suggested git commit message
```

## Checkpoint File Schema

The checkpoint file is the source of truth for execution state:

```yaml
# checkpoint.yml
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
      current_item: ".octon/orchestration/runtime/workflows/example.md"
  5_verify:
    status: pending
  6_document:
    status: pending

resume:
  phase: 4
  instruction: "Continue from item 8 in change-manifest.md"
  last_completed: ".octon/START.md"

parameters:
  dry_run: false
  file_types: [md, yml, yaml, json, ts]
  exclusions: [node_modules, .git, dist]
```

## Log Structure

Logs are written to `.octon/capabilities/runtime/skills/_ops/state/logs/refactor/`:

```
_ops/state/logs/refactor/
├── index.yml                    # Skill-level index with metadata
└── {{refactor-id}}.md             # Individual run log
```

### Log Index Schema

```yaml
# _ops/state/logs/refactor/index.yml
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

# Quick lookup for "was X already refactored?"
scopes_completed:
  - ".scratch/ → .scratchpad/"
  - "utils/ → lib/utils/"
```

## Progressive Disclosure Tiers

| Tier | What to Read | Tokens | Question Answered |
|------|--------------|--------|-------------------|
| 1 | `checkpoint.yml` | ~50 | "What's the current state?" |
| 2 | Phase outputs | ~200-500 each | "What happened in this phase?" |
| 3 | `execution-log.md` | Variable | "What exactly changed?" |

## Dry-Run Mode

When `dry_run: true`, only phases 1-3 execute:

| Phase | dry_run: false | dry_run: true |
|-------|----------------|---------------|
| 1. Define Scope | ✓ Execute | ✓ Execute |
| 2. Audit | ✓ Execute | ✓ Execute |
| 3. Plan | ✓ Execute | ✓ Execute |
| 4. Execute | ✓ Execute | ⏹ SKIP |
| 5. Verify | ✓ Execute | ⏹ SKIP |
| 6. Document | ✓ Execute | ⏹ SKIP |

Dry-run output:

```markdown
## Dry Run Complete

**Scope:** `.scratch/` → `.scratchpad/`

**Audit Summary:**
- 12 files contain references
- 47 total matches
- 1 directory to rename

**Change Manifest:**
See _ops/state/runs/refactor/{{id}}/change-manifest.md

**Next steps:**
- Review the change manifest
- Run `/refactor ".scratch/ → .scratchpad/"` (without dry_run) to execute
```

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter:

- **Read** — Read files for audit and execution
- **Glob** — Pattern matching for file discovery
- **Grep** — Content search for pattern matching
- **Edit** — Modify source files to replace references
- **Write(_ops/state/runs/*)** — Write execution state (session recovery)
- **Write(_ops/state/logs/*)** — Write execution logs
- **Bash(mv)** — Rename/move files and directories
- **Bash(mkdir)** — Create output directories

No external dependencies required.

---

## Command-Line Usage

### Basic Invocation

```bash
/refactor ".scratch/ → .scratchpad/"
```

### With Options

```bash
# Dry run (audit and plan only)
/refactor "utils/ → lib/utils/" --dry_run

# Custom file types
/refactor "OLD → NEW" --file_types="md,yml,json,py"

# Custom exclusions
/refactor "OLD → NEW" --exclusions="node_modules,.git,dist,vendor"

# Combined options
/refactor "helpers.ts → utils/helpers.ts" --dry_run --file_types="ts,tsx,js"
```

### Resume Interrupted Refactor

```bash
# Will detect existing checkpoint and offer to resume
/refactor ".scratch/ → .scratchpad/"
```
