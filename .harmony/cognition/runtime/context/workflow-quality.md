---
title: Workflow Quality Criteria
description: Shared scoring rubric for directory and single-file workflows.
---

# Workflow Quality Criteria

This document defines the shared workflow scoring rubric used by `/evaluate-workflow`
and the Workflow System Audit.

## Supported Workflow Formats

- **Directory workflow:** a directory with `WORKFLOW.md` plus declared step files
- **Single-file workflow:** one `.md` file with workflow frontmatter and inline flow

Both formats score on the same 100-point scale. Checks differ by format where the
contract differs.

## Grading Rubric

| Grade | Score | Description |
|-------|-------|-------------|
| **A** | 90-100 | Strong contract, clear execution path, low drift |
| **B** | 80-89 | Good workflow with minor gaps |
| **C** | 70-79 | Usable but notable gaps or drift |
| **D** | 60-69 | Weak workflow needing focused remediation |
| **F** | <60 | Failing workflow contract or poor execution safety |

## Evaluation Categories

### 1. Discovery and Routing (10 points)

| Criterion | Points | Notes |
|-----------|--------|-------|
| Clear summary/description | 4 | Explains what the workflow does and when to use it |
| Discovery triggers or local usage guidance | 6 | Manifest triggers for registered workflows, or explicit Usage/Context guidance for direct-path evaluation |

### 2. Contract Integrity (20 points)

| Criterion | Points | Notes |
|-----------|--------|-------|
| Valid workflow entrypoint | 5 | `WORKFLOW.md` for directory workflows, workflow `.md` for single-file |
| Declared step/file parity | 5 | Directory workflows only; single-file gets full credit when inline format is valid |
| Required frontmatter present | 5 | `name`, `description`, access/version as applicable to current workflow contract |
| Manifest/registry parity | 5 | Registered workflows align across manifest, registry, and workflow artifact |

### 3. Quality and Gap Coverage (25 points)

| Criterion | Points | Notes |
|-----------|--------|-------|
| Prerequisites documented | 5 | Or explicit context for human-initiated workflows |
| Failure conditions documented | 5 | Actionable stop/fail guidance |
| Actions/flow are actionable | 5 | Concrete ordered steps or inline flow |
| Gap controls documented | 5 | Idempotency, checkpoints, dependencies, versioning, branching, or parallel guidance |
| Version history present | 5 | For actively maintained workflows |

### 4. Execution Safety and Verification (20 points)

| Criterion | Points | Notes |
|-----------|--------|-------|
| Explicit verification gate or required outcome | 8 | Must be reachable from the documented flow |
| Target/output described | 4 | What the workflow affects or produces |
| Step graph/inline flow is coherent | 4 | No unreachable or contradictory structure |
| Execution profile is honest | 4 | `core` vs `external-dependent` matches documented behavior |

### 5. Maintainability (10 points)

| Criterion | Points | Notes |
|-----------|--------|-------|
| Naming and structure are consistent | 5 | File naming and step layout follow repo conventions |
| Workflow is focused | 5 | Steps and content have one clear reason to change |

### 6. Documentation and References (15 points)

| Criterion | Points | Notes |
|-----------|--------|-------|
| Local references resolve | 7 | Broken links reduce trust and operator throughput |
| Usage/target guidance exists | 4 | Reader can tell how to invoke the workflow |
| Description is helpful | 4 | Description is informative, not placeholder text |

## Format-Specific Notes

### Directory Workflows

- `WORKFLOW.md` is the contract entrypoint
- The `steps` array is the source of truth for step files
- A wrapper style that delegates to `00-overview.md` is valid if `WORKFLOW.md` declares it

### Single-File Workflows

- Frontmatter should identify the workflow directly
- Inline `Flow`, `Steps`, or equivalent execution guidance must replace step files
- `Required Outcome` or an equivalent verification section should be explicit

## Quick Checklist

### Blocking Checks

- [ ] Workflow artifact parses successfully
- [ ] Registered workflow path resolves on disk
- [ ] Entry/frontmatter identity is coherent
- [ ] Verification or required outcome is present
- [ ] No dependency cycle or command collision is introduced

### Non-Blocking but Important

- [ ] Version history exists
- [ ] Gap controls are explicit
- [ ] Local links resolve
- [ ] Usage and target guidance are clear

## Output Expectations

The shared scorer should be able to emit:

- machine-readable score data for system audits
- human-readable workflow reports for `/evaluate-workflow`
- stable issue metadata suitable for bounded finding generation
