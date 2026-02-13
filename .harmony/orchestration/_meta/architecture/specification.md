---
title: Specification Compliance
description: Conformance to the Agent Workflow Specification, extensions, and validation.
spec_refs:
  - HARMONY-SPEC-301
  - HARMONY-SPEC-003
  - HARMONY-SPEC-006
---

# Specification Compliance

This document defines the Agent Workflow Specification and describes how the Harmony workflows implementation conforms to it. It parallels the [Agent Skills specification](https://agentskills.io/specification) but addresses the distinct needs of multi-step coordinated procedures.

---

## Core Specification

### Overview

A workflow is an ordered sequence of steps that an agent follows to complete a coordinated, multi-step procedure. Workflows differ from skills in three ways:

1. **Ordered steps** — Execution follows a defined sequence of separate files
2. **Execution model** — Steps may run sequentially, in parallel, or conditionally
3. **Verification gates** — A final step validates that the workflow achieved its objectives

The specification defines the minimum structure for portable, agent-readable workflows.

### When to Use Workflows

Workflows and skills serve different purposes:

| Dimension | Skill | Workflow |
| --------- | ----- | -------- |
| Scope | Single bounded capability | Multi-step coordinated procedure |
| Executor | One agent runs the whole thing | May coordinate multiple agents or sessions |
| State | Stateless or internally managed | Explicit inter-step state via Input/Output |
| Verification | Acceptance criteria in the skill | Dedicated verification step file |
| File structure | `SKILL.md` + `references/` | `WORKFLOW.md` + numbered step files |

**Use a skill when:** The task is a single bounded capability that one agent can execute end-to-end without coordination (e.g., "audit this codebase," "refine this prompt").

**Use a workflow when:** The task requires multiple distinct phases that benefit from separate files, explicit state passing between steps, or coordination across agents (e.g., "scaffold a harness," "partition and distribute an audit across agents").

A workflow may invoke skills as part of its steps. A skill should not invoke workflows.

### Not in Scope

This specification does not define:

- **Runtime execution engines** — How agents are launched or scheduled
- **Persistence mechanisms** — How checkpoint data is stored or recovered
- **Inter-agent communication** — How parallel agents exchange data
- **Authentication or authorization** — Access control beyond the `access` field convention

These concerns are left to implementation frameworks.

### Directory Structure

A workflow is a directory containing at minimum a `WORKFLOW.md` file:

```
workflow-name/
├── WORKFLOW.md          # Required (entry point)
├── 01-step-name.md      # Step files (loaded during execution)
├── 02-step-name.md
├── ...
└── NN-verify.md         # Final verification step (convention)
```

### WORKFLOW.md Format

The `WORKFLOW.md` file must contain YAML frontmatter followed by Markdown content.

#### Frontmatter (required fields)

```yaml
---
name: deploy-pipeline
description: >
  Build, test, and deploy a service to the staging environment.
  Use when a feature branch is ready for integration testing.
steps:
  - id: validate
    file: 01-validate.md
    description: Check prerequisites and environment.
  - id: build
    file: 02-build.md
    description: Compile source and run unit tests.
  - id: deploy
    file: 03-deploy.md
    description: Push artifacts to staging.
  - id: verify
    file: 04-verify.md
    description: Confirm deployment succeeded.
---
```

| Field | Required | Constraints |
| ----- | -------- | ----------- |
| `name` | Yes | 1-64 characters. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen. Must match the parent directory name. |
| `description` | Yes | 1-1024 characters. Non-empty. Describes what the workflow does and when to use it. |
| `steps` | Yes | Ordered array of step definitions. At least one step required. |

#### Frontmatter (optional fields)

| Field | Constraints |
| ----- | ----------- |
| `license` | License name or reference to a bundled license file. |
| `compatibility` | Max 500 characters. Environment requirements (intended product, system packages, etc.). |
| `metadata` | Arbitrary key-value mapping for additional metadata (author, version, etc.). |

#### Steps array items

Each entry in the `steps` array defines one step:

| Field | Required | Constraints |
| ----- | -------- | ----------- |
| `id` | Yes | Step identifier. Lowercase letters, numbers, and hyphens only. Unique within the workflow. |
| `file` | Yes | Relative path to the step file from the workflow directory. |
| `description` | No | Max 160 characters. Brief description of what the step does. |

#### `name` field

The required `name` field follows the same rules as the Agent Skills `name` field:

- Must be 1-64 characters
- May only contain lowercase alphanumeric characters and hyphens (`a-z`, `0-9`, `-`)
- Must not start or end with `-`
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

#### `description` field

The required `description` field:

- Must be 1-1024 characters
- Should describe both what the workflow does and when to use it
- Should include keywords that help agents identify relevant procedures

Good example:

```yaml
description: >
  Build, test, and deploy a service to the staging environment.
  Use when a feature branch is ready for integration testing.
```

Poor example:

```yaml
description: Deploys stuff.
```

#### Body content

The Markdown body after frontmatter contains the workflow overview. There are no format restrictions. Write whatever helps agents understand the workflow before executing individual steps.

Recommended sections:

- Usage examples (command syntax)
- Prerequisites (what must be true before starting)
- Failure conditions (when to stop)
- Step summary (brief description of each step with links)
- Verification gate (completion criteria)

Keep `WORKFLOW.md` under 500 lines. Detailed step instructions belong in step files.

### Single-File Workflows

When a procedure is simple enough to fit in one document (typically 3 or fewer logical steps), a single-file workflow is valid:

```text
promote-from-scratchpad.md
```

Single-file workflows use the same frontmatter as directory-based workflows, with one difference: the `steps` field is omitted (since there are no separate step files) and all instructions appear inline in the body.

**Frontmatter for single-file workflows:**

```yaml
---
name: promote-from-scratchpad
description: >
  Publish distilled insights from a scratchpad to agent-facing artifacts.
  Use when scratchpad notes are ready to become permanent documentation.
---
```

| Field | Required | Constraints |
| ----- | -------- | ----------- |
| `name` | Yes | Same rules as directory-based workflows. Must match the filename (without `.md`). |
| `description` | Yes | Same rules as directory-based workflows. |
| `steps` | No | Omitted. All steps are inline in the body. |

**When to use single-file format:**

- The procedure has 3 or fewer logical steps
- No step requires its own detailed instructions file
- The entire workflow fits comfortably under 500 lines

**When to use directory format:**

- The procedure has 4 or more steps
- Individual steps are complex enough to warrant separate files
- The workflow benefits from idempotent step-level checkpointing

### Step File Format

Each step file must contain YAML frontmatter followed by Markdown content.

#### Step file naming

Step files follow the naming convention `NN-kebab-case-name.md`:

- `NN` is a two-digit zero-padded sequence number (`01`, `02`, ..., `99`)
- The name portion uses kebab-case (lowercase letters, numbers, hyphens)
- The final step should be named `NN-verify.md` (convention)

Valid examples: `01-validate.md`, `02-build-artifacts.md`, `07-verify.md`

Invalid examples: `1-validate.md` (not zero-padded), `01_validate.md` (underscores), `step-1.md` (number not prefix)

#### Step frontmatter

```yaml
---
name: validate
description: Check prerequisites and confirm the environment is ready.
---
```

| Field | Required | Constraints |
| ----- | -------- | ----------- |
| `name` | Yes | Must match the `id` of the corresponding entry in the `steps` array. |
| `description` | Yes | 1-1024 characters. Describes what this step does. |

#### Step body content

The Markdown body contains the step instructions. Recommended sections:

- **Input** — What this step reads or requires from previous steps
- **Purpose** — Why this step exists
- **Actions** — Numbered list of concrete actions to perform
- **Output** — What this step produces for subsequent steps
- **Proceed When** — Conditions that must be true before moving to the next step

### Execution Model

#### Step ordering

Steps execute in the order defined by the `steps` array. Agents should:

1. Read `WORKFLOW.md` first (metadata + overview) to understand the full workflow
2. Load step files one at a time during execution
3. Complete each step's "Proceed When" criteria before advancing
4. Execute the final step as a verification gate (convention)

The core spec defines sequential execution only. Parallel execution, branching, and checkpointing are implementation extensions.

#### Inter-step data flow

Data flows between steps through the **Input** and **Output** sections of each step file. These are prose-based contracts: the Output section of step N describes what it produces, and the Input section of step N+1 describes what it consumes. There is no structured data format required — agents interpret the prose.

This design is intentional. Workflows are agent-readable instructions, not machine-executable pipelines. The prose contract is sufficient because:

- The same agent (or coordinating agent) reads both the Output and Input sections
- Agents can resolve ambiguity by re-reading prior step outputs
- Structured data contracts would add complexity without proportional benefit for prose-based workflows

When a workflow needs structured inter-step data (e.g., a partition plan passed from step 2 to step 3), the step's Output section should specify where the data is written (file path, format) so the next step can read it.

#### Failure handling

The core spec does not prescribe a single failure model. Instead, each workflow defines its failure semantics in two places:

1. **WORKFLOW.md body** — A "Failure Conditions" section lists conditions that should halt the workflow entirely (e.g., "Invalid manifest -> STOP, report validation error").

2. **Step files** — Each step's "Proceed When" criteria define what must be true to advance. If criteria are not met, the agent should not proceed.

Common failure patterns (for workflow authors to choose from):

| Pattern | Behavior | When to use |
| ------- | -------- | ----------- |
| **Stop** | Halt the workflow, report the failure | Unrecoverable errors (missing prerequisites, invalid input) |
| **Retry** | Re-execute the failed step | Transient failures (network errors, tool timeouts) |
| **Return** | Go back to an earlier step and re-execute from there | Verification failures that require rework |
| **Skip** | Mark the step as incomplete and continue | Non-critical steps where partial results are acceptable |

The verification gate (final step) is the ultimate failure handler: if it fails, the workflow is not complete regardless of how individual steps were handled.

### Progressive Disclosure

Workflows follow the same progressive disclosure principle as skills:

1. **Metadata** (~100 tokens): `name`, `description`, and `steps` array from WORKFLOW.md frontmatter. Loaded at discovery time.
2. **Instructions** (<5000 tokens): WORKFLOW.md body (overview, usage, prerequisites). Loaded when the workflow is activated.
3. **Step details** (as needed): Individual step files loaded one at a time during execution.

---

## Spec Compliance

This implementation follows the Agent Workflow Specification defined above:

| Spec Requirement | Implementation |
| ---------------- | -------------- |
| Required frontmatter: `name`, `description`, `steps` | In `WORKFLOW.md` |
| Optional: `license`, `compatibility`, `metadata` | In `WORKFLOW.md` |
| Directory structure: `WORKFLOW.md` + step files | Per spec |
| Single-file variant: `name`, `description` only | Per spec (2 single-file workflows) |
| `WORKFLOW.md` < 500 lines | Details in step files |
| Name matches directory | Enforced by `create-workflow` workflow |
| Step naming: `NN-kebab-case.md` | Per spec |
| Progressive disclosure | Three-tier model (manifest, WORKFLOW.md, steps) |
| Sequential execution model | Default; parallel extensions available |

---

## Extensions Beyond Spec

This implementation extends the core specification with:

| Extension | Purpose |
| --------- | ------- |
| Progressive disclosure layers | Manifest + registry for centralized discovery |
| `display_name` field | Human-readable workflow name |
| Execution extensions | Parallel steps, checkpoints, access control |
| Step file extensions | Idempotency markers, error messages |
| Quality rubric integration | 100-point grading rubric for workflow quality |

### Progressive Disclosure Layers

**Why:** The core spec defines workflows as self-contained directories. For repositories with many workflows, loading every WORKFLOW.md at session start is expensive. The manifest/registry split provides:

- **Token efficiency** — manifest.yml is ~50 tokens/workflow vs ~100+ tokens reading WORKFLOW.md frontmatter
- **Centralized routing** — All workflow triggers and commands in one file
- **Separation of concerns** — WORKFLOW.md contains identity and instructions; manifest/registry contains routing

**Implementation:**

| Layer | File | Contains |
| ----- | ---- | -------- |
| **Tier 1** | `manifest.yml` | Workflow index (id, name, summary, triggers) |
| **Tier 2** | `registry.yml` | Extended metadata, parameters, I/O mappings |
| **Tier 3** | `WORKFLOW.md` | Full workflow definition, overview, prerequisites |
| **Tier 4** | Step files | Detailed step instructions, loaded during execution |

**Single source of truth principle:**

| Metadata | Source of Truth | NOT Duplicated In |
| -------- | --------------- | ----------------- |
| `name`, `description` | WORKFLOW.md frontmatter | -- |
| `summary`, `triggers`, `tags`, `display_name` | `manifest.yml` | WORKFLOW.md |
| `version`, `commands`, `parameters`, `depends_on` | `registry.yml` | WORKFLOW.md |

### Execution Extensions

Additional WORKFLOW.md frontmatter fields for Harmony workflows:

| Field | Purpose |
| ----- | ------- |
| `access` | `human` or `agent` — who can invoke this workflow |
| `checkpoints.enabled` | Enable checkpoint/resume for long-running workflows |
| `checkpoints.storage` | Directory path for checkpoint files |
| `parallel_steps` | Groups of steps that can run concurrently |
| `verification_gate` | Boolean — marks the final step as a mandatory pass/fail gate |

**Parallel steps syntax:**

```yaml
parallel_steps:
  - group: "partition-audits"
    steps: ["03-dispatch"]
    join_at: "04-merge"
```

This declares that step `03-dispatch` can launch parallel work, and step `04-merge` waits for all parallel work to complete before proceeding.

### Step File Extensions

Additional frontmatter fields for Harmony step files:

| Field | Purpose |
| ----- | ------- |
| `idempotency.marker` | Checkpoint file path for skip detection |
| `error_messages` | Structured error codes and messages |

**Idempotency pattern:** Each step can declare a checkpoint marker. If the marker exists, the step was already completed and can be skipped:

```yaml
---
name: configure
description: Parse manifest and enumerate scope.
---

## Idempotency

**Check:** Was configuration already completed?

- [ ] Checkpoint file exists at `checkpoints/workflow-id/01-configure.complete`

**If Already Complete:**

- Skip to next step
- Re-run if inputs have changed

**Marker:** `checkpoints/workflow-id/01-configure.complete`
```

### Quality Rubric Integration

Harmony workflows are assessed against a 100-point quality rubric defined in `.harmony/cognition/context/workflow-quality.md`:

- **Structure** (25 pts): WORKFLOW.md, numbered steps, verification gate, naming
- **Frontmatter** (20 pts): Required fields, version, dependencies
- **Content** (25 pts): Prerequisites, failure conditions, actionable steps, verification
- **Gap Coverage** (20 pts): Idempotency, checkpoints, versioning, parallel
- **Maintainability** (10 pts): Focused steps, valid references, consistent formatting

---

## Validation

### Manual Validation Checklist

#### Core Spec

Structure:

- [ ] `WORKFLOW.md` exists in workflow directory (or single-file `workflow-name.md` exists)
- [ ] `name` in frontmatter matches directory name (or filename for single-file)
- [ ] `description` is 1-1024 characters
- [ ] `steps` array has at least one entry (directory-based only)
- [ ] Every `file` in `steps` references an existing step file
- [ ] Every step `id` is unique within the workflow
- [ ] Body is under 500 lines

Naming:

- [ ] Name is 1-64 characters
- [ ] Only lowercase letters, numbers, hyphens
- [ ] Does not start or end with hyphen
- [ ] No consecutive hyphens

Steps (directory-based only):

- [ ] Each step file has `name` and `description` in frontmatter
- [ ] Step file `name` matches corresponding `id` in `steps` array
- [ ] Step files follow `NN-kebab-case.md` naming convention
- [ ] Final step serves as verification gate

#### Harmony Extensions

Discovery:

- [ ] Workflow is listed in `.harmony/orchestration/workflows/manifest.yml`
- [ ] `id` matches directory name and WORKFLOW.md `name`
- [ ] `display_name` is present
- [ ] `summary` is present for routing
- [ ] `triggers` are defined (if using natural language activation)
- [ ] Workflow entry exists in `.harmony/orchestration/workflows/registry.yml`
- [ ] `version` is defined in registry
- [ ] `commands` includes at least one slash command (if invocable)

Execution:

- [ ] Workflow produces output at designated location
- [ ] Verification gate has clear pass/fail criteria
- [ ] Idempotency markers defined for each step (if checkpoints enabled)

---

## See Also

- [Agent Skills Specification](/.harmony/capabilities/_meta/architecture/specification.md) -- Skills format specification
- [Skills Architecture](/.harmony/capabilities/_meta/architecture/architecture.md) -- Skills implementation architecture
- [Workflow Template](/.harmony/orchestration/workflows/_scaffold/template/) -- Canonical workflow template
- [Workflow Quality Rubric](/.harmony/cognition/context/workflow-quality.md) -- 100-point grading rubric
