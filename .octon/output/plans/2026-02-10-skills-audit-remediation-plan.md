# Skills Audit Remediation Plan

Date: 2026-02-10
Source: `.octon/output/reports/analysis/2026-02-10-skills-subsystem-audit.md`

## Context

The 14-dimension audit produced 11 findings (1 critical, 5 important, 3 minor, 2 informational). This plan addresses all findings across three batches in dependency order. The user has decided to **register** the 12 unregistered Python API and Swift macOS child skills (not archive).

## Decisions

- **D1-1 disposition:** Register all 12 child skills as first-class manifest/registry entries.
- **Child skill ID convention:** Prefix with parent foundation to avoid collisions (e.g., `python-scaffold-package`, `swift-scaffold-package`), matching the existing pattern where `react-best-practices` is the child skill under `foundations/react/best-practices/`.
- **Scaffolding Write scope:** Foundation child skills write to user-specified project directories, so unscoped `Write` is acceptable with documented justification (same as `build-mcp-server` after remediation). `Bash` must be scoped to specific commands.

---

## Batch A: Security and Integrity

### A1. Scope `build-mcp-server` tool permissions (D7-1, critical)

**Why first:** Only critical finding. Unscoped `Write` and `Bash` in an active skill violates deny-by-default.

**File:** `.octon/capabilities/skills/meta/build-mcp-server/SKILL.md`

**Current (line 18):**

```
allowed-tools: Read Glob Grep Edit Write Bash Write(logs/*)
```

**Change to:**

```
allowed-tools: Read Glob Grep Edit Write Bash(npm) Bash(npx) Bash(mkdir) Bash(cp) Bash(node) Write(logs/*)
```

**Rationale:**

- `Write` remains unscoped because this skill scaffolds MCP server projects into user-specified directories — the output path is a parameter (`{{output_dir}}/{{name}}/`). Scoping `Write` to a fixed path would break the skill's purpose.
- `Bash` is scoped to the specific commands the skill needs: `npm` (install dependencies), `npx` (MCP inspector), `mkdir` (create directories), `cp` (copy templates), `node` (run validation).
- The existing duplicate `Write(logs/*)` is now redundant with unscoped `Write` — remove it for clarity, or keep it to signal intent. Recommend keeping for readability.
- Update the comment on line 17 to document the scoping rationale.

**Updated comment (line 17):**

```
# Write is intentionally unscoped: scaffolds into user-specified output_dir. Bash scoped to npm/npx/mkdir/cp/node.
```

### A2. Add missing output schema fields (D2-1, important)

**Why:** Registry schema requires `format` and `determinism` on all outputs. Two directory-kind outputs omit them.

**File:** `.octon/capabilities/skills/registry.yml`

**Change 1 — `create-skill` output `skill_directory` (lines 654-657):**

Current:

```yaml
        - name: skill_directory
          path: "{{group}}/{{skill_name}}/"
          kind: directory
          description: "The created skill directory (deliverable)"
```

Change to:

```yaml
        - name: skill_directory
          path: "{{group}}/{{skill_name}}/"
          kind: directory
          format: mixed
          determinism: stable
          description: "The created skill directory (deliverable)"
```

`format: mixed` because the directory contains markdown, YAML, and potentially scripts. `determinism: stable` because the same inputs produce the same directory structure.

**Change 2 — `build-mcp-server` output `mcp_server_project` (lines 908-911):**

Current:

```yaml
        - name: mcp_server_project
          path: "{{output_dir}}/{{name}}/"
          kind: directory
          description: "The created MCP server project directory"
```

Change to:

```yaml
        - name: mcp_server_project
          path: "{{output_dir}}/{{name}}/"
          kind: directory
          format: mixed
          determinism: stable
          description: "The created MCP server project directory"
```

### A3. Register 12 foundation child skills (D1-1, D2-2, D7-2, D13-1)

**Why:** These directories contain SKILL.md files and are advertised as invocable commands by their parent foundations, but are invisible to routing (no manifest/registry entries) and have incomplete frontmatter.

**Scope:** 6 Python API children + 6 Swift macOS children.

#### A3a. Add `skill_sets` to all 12 SKILL.md frontmatter files

All 12 files currently have:

```yaml
allowed-tools: Read Grep Glob Bash Write Edit
disable-model-invocation: true
```

All 12 need `skill_sets: [executor]` added (they are phased scaffolding workflows). Also scope `Bash` to commands appropriate for each stack.

**Python API children** (6 files under `foundations/python-api/`):

| Child | File | Bash scope |
|-------|------|-----------|
| scaffold-package | `scaffold-package/SKILL.md` | `Bash(mkdir) Bash(uv)` |
| contract-first-api | `contract-first-api/SKILL.md` | `Bash(mkdir)` |
| test-harness | `test-harness/SKILL.md` | `Bash(mkdir) Bash(uv)` |
| dev-toolchain | `dev-toolchain/SKILL.md` | `Bash(mkdir) Bash(just) Bash(pre-commit)` |
| infra-manifest | `infra-manifest/SKILL.md` | `Bash(mkdir) Bash(docker) Bash(alembic)` |
| contributor-guide | `contributor-guide/SKILL.md` | `Bash(mkdir)` |

**For each Python child, change frontmatter to:**

```yaml
name: <name>
description: >
  <existing description>
skill_sets: [executor]
capabilities: []
# Write is intentionally unscoped: scaffolds into user project directories.
allowed-tools: Read Grep Glob Edit Write Bash(<scoped commands>)
```

Remove `disable-model-invocation: true` — this is not part of the current schema.

**Swift macOS children** (6 files under `foundations/swift-macos-app/`):

| Child | File | Bash scope |
|-------|------|-----------|
| scaffold-package | `scaffold-package/SKILL.md` | `Bash(mkdir) Bash(swift)` |
| data-layer | `data-layer/SKILL.md` | `Bash(mkdir)` |
| cli-interface | `cli-interface/SKILL.md` | `Bash(mkdir)` |
| daemon-service | `daemon-service/SKILL.md` | `Bash(mkdir)` |
| test-harness | `test-harness/SKILL.md` | `Bash(mkdir) Bash(swift)` |
| contributor-guide | `contributor-guide/SKILL.md` | `Bash(mkdir)` |

Same frontmatter pattern as Python children, with stack-appropriate Bash scopes.

#### A3b. Add 12 entries to `manifest.yml`

Insert after the existing `swift-macos-app` entry (line 190) and `python-api` entry (line 171) respectively. Follow existing child-skill pattern (e.g., `react-best-practices`).

**Python API children (6 entries):**

```yaml
  - id: python-scaffold-package
    display_name: Python Scaffold Package
    group: foundations
    path: foundations/python-api/scaffold-package/
    summary: "Scaffold a Python API package with pyproject.toml, typed config, and health endpoints."
    status: active
    tags: [python, scaffold, package, fastapi]
    triggers:
      - "scaffold python package"
      - "create python api project structure"
      - "python pyproject setup"
    skill_sets: [executor]
    capabilities: []

  - id: python-contract-first-api
    display_name: Python Contract First Api
    group: foundations
    path: foundations/python-api/contract-first-api/
    summary: "Generate OpenAPI spec, Pydantic models, contract tests, and JSON fixtures from a domain description."
    status: active
    tags: [python, openapi, pydantic, contracts]
    triggers:
      - "generate python api contracts"
      - "contract first api setup"
      - "openapi pydantic models"
    skill_sets: [executor]
    capabilities: []

  - id: python-test-harness
    display_name: Python Test Harness
    group: foundations
    path: foundations/python-api/test-harness/
    summary: "Generate pytest infrastructure: conftest fixtures, contract tests, unit stubs, integration scaffolding."
    status: active
    tags: [python, pytest, testing, fixtures]
    triggers:
      - "set up python test harness"
      - "generate pytest fixtures"
      - "python test scaffolding"
    skill_sets: [executor]
    capabilities: []

  - id: python-dev-toolchain
    display_name: Python Dev Toolchain
    group: foundations
    path: foundations/python-api/dev-toolchain/
    summary: "Configure justfile, pre-commit hooks, ruff/mypy, .gitignore, and .env.local.example."
    status: active
    tags: [python, tooling, ruff, pre-commit]
    triggers:
      - "set up python dev toolchain"
      - "configure python linting"
      - "python pre-commit setup"
    skill_sets: [executor]
    capabilities: []

  - id: python-infra-manifest
    display_name: Python Infra Manifest
    group: foundations
    path: foundations/python-api/infra-manifest/
    summary: "Generate docker-compose.local.yml and Alembic migration setup for declared infrastructure."
    status: active
    tags: [python, docker, alembic, infrastructure]
    triggers:
      - "generate python infrastructure"
      - "docker compose for python api"
      - "alembic migration setup"
    skill_sets: [executor]
    capabilities: []

  - id: python-contributor-guide
    display_name: Python Contributor Guide
    group: foundations
    path: foundations/python-api/contributor-guide/
    summary: "Generate AGENT.md, CONTRIBUTING.md, PR template, and CI workflow from project state."
    status: active
    tags: [python, documentation, contributing, ci]
    triggers:
      - "generate python contributor docs"
      - "python contributing guide"
      - "python ci workflow setup"
    skill_sets: [executor]
    capabilities: []
```

**Swift macOS children (6 entries):**

```yaml
  - id: swift-scaffold-package
    display_name: Swift Scaffold Package
    group: foundations
    path: foundations/swift-macos-app/scaffold-package/
    summary: "Scaffold a Swift macOS package with Package.swift, source targets, typed config, and logging."
    status: active
    tags: [swift, scaffold, package, macos]
    triggers:
      - "scaffold swift package"
      - "create swift macos project"
      - "swift package setup"
    skill_sets: [executor]
    capabilities: []

  - id: swift-data-layer
    display_name: Swift Data Layer
    group: foundations
    path: foundations/swift-macos-app/data-layer/
    summary: "Generate SQLite persistence layer with GRDB.swift: database actor, migrations, record types."
    status: active
    tags: [swift, grdb, sqlite, database]
    triggers:
      - "swift data layer setup"
      - "grdb database actor"
      - "swift sqlite persistence"
    skill_sets: [executor]
    capabilities: []

  - id: swift-cli-interface
    display_name: Swift Cli Interface
    group: foundations
    path: foundations/swift-macos-app/cli-interface/
    summary: "Generate CLI with swift-argument-parser: subcommands, typed options, shell completions."
    status: active
    tags: [swift, cli, argument-parser, commands]
    triggers:
      - "swift cli setup"
      - "argument parser commands"
      - "swift command line interface"
    skill_sets: [executor]
    capabilities: []

  - id: swift-daemon-service
    display_name: Swift Daemon Service
    group: foundations
    path: foundations/swift-macos-app/daemon-service/
    summary: "Generate background daemon with actor isolation, intent queue, FSEvents watcher, LaunchAgent plist."
    status: active
    tags: [swift, daemon, launchagent, fsevents]
    triggers:
      - "swift daemon service"
      - "launchagent daemon setup"
      - "swift background service"
    skill_sets: [executor]
    capabilities: []

  - id: swift-test-harness
    display_name: Swift Test Harness
    group: foundations
    path: foundations/swift-macos-app/test-harness/
    summary: "Generate XCTest suites, in-memory database fixtures, mock actors, and CI workflow."
    status: active
    tags: [swift, xctest, testing, fixtures]
    triggers:
      - "swift test harness setup"
      - "xctest scaffolding"
      - "swift test fixtures"
    skill_sets: [executor]
    capabilities: []

  - id: swift-contributor-guide
    display_name: Swift Contributor Guide
    group: foundations
    path: foundations/swift-macos-app/contributor-guide/
    summary: "Generate CLAUDE.md, CONTRIBUTING.md, architecture overview, PR template, and CI config."
    status: active
    tags: [swift, documentation, contributing, ci]
    triggers:
      - "swift contributor docs"
      - "swift contributing guide"
      - "swift ci workflow setup"
    skill_sets: [executor]
    capabilities: []
```

#### A3c. Add 12 entries to `registry.yml`

Follow the pattern of existing child skills (e.g., `react-best-practices` at line 441). Each entry needs `version`, `commands`, `parameters`, `requires`, `depends_on`, `io`.

**Pattern for each child skill:**

```yaml
  <child-id>:
    version: "1.0.0"
    commands:
      - /<child-id>
    parameters:
      - name: project_name
        type: text
        required: true
        description: "Project name for scaffolding"
      # Additional stack-specific parameters per skill
    requires:
      context: []
    depends_on:
      - <parent-foundation-id>
    io:
      inputs: []
      outputs:
        - name: run_log
          path: "logs/<child-id>/{{run_id}}.md"
          kind: file
          format: markdown
          determinism: unique
          description: "Execution log"
        - name: log_index
          path: "logs/<child-id>/index.yml"
          kind: file
          format: yaml
          determinism: variable
          description: "Index of all <child-id> runs"
```

**Dependency chains (from parent SKILL.md cross-references):**

Python API:

- `python-scaffold-package` → depends_on: `[python-api]`
- `python-contract-first-api` → depends_on: `[python-api, python-scaffold-package]`
- `python-test-harness` → depends_on: `[python-api, python-scaffold-package]`
- `python-dev-toolchain` → depends_on: `[python-api, python-scaffold-package]`
- `python-infra-manifest` → depends_on: `[python-api, python-scaffold-package]`
- `python-contributor-guide` → depends_on: `[python-api]` (runs last, reads all other outputs)

Swift macOS:

- `swift-scaffold-package` → depends_on: `[swift-macos-app]`
- `swift-data-layer` → depends_on: `[swift-macos-app, swift-scaffold-package]`
- `swift-cli-interface` → depends_on: `[swift-macos-app, swift-scaffold-package]`
- `swift-daemon-service` → depends_on: `[swift-macos-app, swift-scaffold-package]`
- `swift-test-harness` → depends_on: `[swift-macos-app, swift-scaffold-package]`
- `swift-contributor-guide` → depends_on: `[swift-macos-app]`

#### A3d. Update parent SKILL.md child skill tables

Update the command references in both parent foundations to use the new namespaced IDs.

**File:** `.octon/capabilities/skills/foundations/python-api/SKILL.md` (line 43-50 area)

Change child skill table commands from `/scaffold-package` to `/python-scaffold-package`, etc.

**File:** `.octon/capabilities/skills/foundations/swift-macos-app/SKILL.md` (line 46-55 area)

Change child skill table commands from `/scaffold-package` to `/swift-scaffold-package`, etc.

#### A3e. Update validator: fail on unscoped Bash in active skills

**File:** `.octon/capabilities/skills/scripts/validate-skills.sh`

Add a check: if an active skill's `allowed-tools` contains bare `Bash` (not `Bash(...)` with a scope), emit an error. This prevents future regressions.

---

## Batch B: Operational Hygiene

### B1. Normalize audit-migration logs to FORMAT.md contract (D10-1)

**Why:** Existing logs lack YAML frontmatter, violating the log format spec.

**Files:**

- `.octon/capabilities/skills/logs/audit-migration/2026-02-08-workspace-to-harness.md`
- `.octon/capabilities/skills/logs/audit-migration/2026-02-08-workspace-to-harness-rerun.md`

**Changes:**

Prepend YAML frontmatter to each file following the FORMAT.md template. Reconstruct metadata from existing log body content:

```yaml
---
run:
  id: "2026-02-08-workspace-to-harness"
  skill_id: "audit-migration"
  skill_version: "1.1.0"
  timestamp: "2026-02-08T00:00:00Z"
  duration_ms: null

status:
  outcome: "success"
  exit_code: 0
  error_code: null
  error_message: null

input:
  source: ". (entire repository)"
  type: "directory"
  size_bytes: null
  parameters:
    mappings: 7
    exclusions: 13
    scope: "."

output:
  path: null
  format: "markdown"
  size_bytes: null
  sections_count: null

context:
  workspace: ".octon/"
  cwd: null
  agent: "Claude Code"
  invocation: "command"

metrics: null
---
```

Use `null` for values not recoverable from the existing log body. The rerun log gets a similar frontmatter with id `2026-02-08-workspace-to-harness-rerun`.

### B2. Clean stale `research-synthesizer` directories (D9-2)

**Why:** Naming drift — the skill was renamed from `research-synthesizer` to `synthesize-research` but runtime directories weren't updated.

**Changes:**

1. Rename `runs/research-synthesizer/` → `runs/synthesize-research/`
2. Rename `configs/research-synthesizer/` → `configs/synthesize-research/`

If either directory contains active state, preserve contents. If empty, the rename is trivial.

**Commands:**

```bash
mv .octon/capabilities/skills/runs/research-synthesizer .octon/capabilities/skills/runs/synthesize-research
mv .octon/capabilities/skills/configs/research-synthesizer .octon/capabilities/skills/configs/synthesize-research
```

### B3. Refresh stale `metadata.updated` dates (D9-1)

**Why:** 14 skills have `metadata.updated` dates older than their last git-modified date, making staleness tracking unreliable.

**Files:** All SKILL.md files with `metadata.updated` that predates the most recent git commit touching the file.

**Changes:**

For each affected SKILL.md, update `metadata.updated` to `"2026-02-10"` (today, the date of remediation).

**Affected skills (14):**

- `synthesize-research`
- `refine-prompt`
- `spec-to-implementation`
- `refactor`
- `audit-migration`
- `audit-ui`
- `resolve-pr-comments`
- `triage-ci-failure`
- `build-mcp-server`
- `create-skill`
- `react-best-practices`
- `react-native-best-practices`
- `react-composition-patterns`
- `postgres-best-practices`

---

## Batch C: Documentation and Policy

### C1. Update README.md (D11-1)

**Why:** README references deprecated `skill_mappings` key and shows a duplicated directory structure diagram.

**File:** `.octon/capabilities/skills/README.md`

**Change 1 — Quick create checklist (lines 47-48):**

Current:

```
│  4. HARNESS REGISTRY (.octon/capabilities/skills/registry.yml)                      │
│     □ Add I/O mapping under `skill_mappings:`:                              │
```

Change to:

```
│  4. REGISTRY (.octon/capabilities/skills/registry.yml)                     │
│     □ Add skill entry under the `skills:` key with:                         │
│       - io.inputs: [{path, kind, required, description}]                    │
│       - io.outputs: [{name, path, kind, format, determinism, description}]  │
```

**Change 2 — Directory structure diagram (lines 143-160):**

The current diagram shows two separate blocks both pointing to `.octon/capabilities/skills/` as if they were distinct directories ("Shared skill definitions" and "Harness-specific configuration"). Merge into a single accurate tree:

```text
.octon/capabilities/skills/
├── manifest.yml                    # Tier 1 discovery index
├── capabilities.yml                # Capability schema & skill set definitions
├── registry.yml                    # Extended metadata, I/O paths (single source of truth)
├── _scaffold/template/                      # Scaffolding for new skills
├── <group>/<skill-id>/SKILL.md     # Core instructions (<500 lines)
├── runs/                           # Execution state (checkpoints) for session recovery
├── configs/                        # Per-skill configuration overrides
├── resources/                      # Per-skill input materials
├── logs/                           # Execution logs
└── scripts/                        # Validation & maintenance scripts

.octon/output/                    # Deliverables (final products)
├── prompts/                        # Refined prompts
├── drafts/                         # Synthesis documents
└── reports/                        # Analysis reports
```

**Change 3 — Creation flow text (lines 150-152):**

Remove or update references to the "extends shared" concept. The current architecture uses a single registry, not shared + harness-specific.

### C2. Document section requirements by skill class (D11-2)

**Why:** 10 active skills (foundation parents + best-practices variants) lack canonical body sections like "Core Workflow" and "When to Escalate", but these sections don't make sense for non-invocable context skills.

**File:** `.octon/capabilities/skills/README.md` (add new section)

**Add a "Skill Classes" section** distinguishing:

| Class | Required Sections | Example |
|-------|------------------|---------|
| **Invocable** (has `commands` in registry) | When to Use, Quick Start, Core Workflow, Boundaries, When to Escalate, References | `synthesize-research`, `refactor` |
| **Foundation context** (`user-invocable: false`) | Stack Assumptions, Child Skills, When Not to Suggest | `python-api`, `swift-macos-app` |
| **Specialist ruleset** (best-practices, patterns) | Categories, Rules/Patterns, Boundaries | `react-best-practices`, `postgres-best-practices` |

This legitimizes the existing divergence rather than forcing a single template on all skill classes.

### C3. Document optional-reference policy (D4-1)

**Why:** 16 skills include reference files not required by their declared capabilities (e.g., `io-contract.md` or `safety.md` without the corresponding capability). The policy is ambiguous about whether this is acceptable.

**File:** `.octon/capabilities/skills/capabilities.yml` (add comment block)

**Add after the `capability_refs` section:**

```yaml
# Reference File Policy:
#   - REQUIRED references: dictated by skill_sets + capabilities via capability_refs above.
#     Validator enforces existence of these files.
#   - OPTIONAL references: skills MAY include additional reference files beyond
#     what their capabilities require. Common cases:
#     - io-contract.md: useful for any skill with structured I/O, even without
#       the `contract-driven` capability
#     - safety.md: useful for any skill with filesystem access, even without
#       the `safety-bounded` capability
#     - examples.md / errors.md: broadly useful across skill types
#   - Validator treats extra references as informational, not errors.
```

---

## Execution Order

| Step | Batch | Item | Dependencies | Files touched |
|------|-------|------|-------------|---------------|
| 1 | A | A1 | None | `build-mcp-server/SKILL.md` |
| 2 | A | A2 | None | `registry.yml` (4 lines) |
| 3 | A | A3a | None | 12 child `SKILL.md` files |
| 4 | A | A3b | A3a | `manifest.yml` |
| 5 | A | A3c | A3a | `registry.yml` |
| 6 | A | A3d | A3b | 2 parent `SKILL.md` files |
| 7 | A | A3e | A1 | `validate-skills.sh` |
| 8 | B | B1 | None | 2 log files |
| 9 | B | B2 | None | 2 directory renames |
| 10 | B | B3 | None | 14 `SKILL.md` files |
| 11 | C | C1 | None | `README.md` |
| 12 | C | C2 | None | `README.md` |
| 13 | C | C3 | None | `capabilities.yml` |

Steps 1-3 are independent and can run in parallel. Steps 4-5 depend on 3. Step 7 depends on 1. Steps 8-10 are independent. Steps 11-13 are independent.

## Validation

After all steps, run:

```bash
bash .octon/capabilities/skills/scripts/validate-skills.sh
```

Expected: all checks pass (including the new unscoped-Bash check from A3e). Then spot-check:

1. All 12 new child skill IDs appear in both manifest and registry
2. `build-mcp-server` has scoped `Bash` in SKILL.md
3. `create-skill` and `build-mcp-server` directory outputs have `format` and `determinism`
4. Both audit-migration logs have valid YAML frontmatter
5. `runs/` and `configs/` no longer contain `research-synthesizer`
6. README quick-create checklist references `skills:` key, not `skill_mappings:`
