---
title: Create Workflow
description: Scaffold a new workflow with gap-aware structure and verification gates.
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps:
  - group: "requirements-gathering"
    steps: ["02-analyze-requirements", "03-select-template"]
    join_at: "04-generate-structure"
---

# Create Workflow: Overview

Scaffold a new workflow directory with numbered step files, incorporating all gap remediation features (idempotency, dependencies, checkpoints, versioning, parallel support).

## Usage

```text
/create-workflow <workflow-id>
/create-workflow <workflow-id> --domain <domain>
/create-workflow <workflow-id> --local
```

**Examples:**
```text
/create-workflow code-review
/create-workflow deploy-staging --domain ci-cd
/create-workflow custom-build --local
```

## Target

- `.harmony/workflows/<domain>/<workflow-id>/` for shared workflows
- `.workspace/workflows/<workflow-id>/` for project-specific workflows (with `--local`)

## Prerequisites

- Workflow ID must be lowercase with hyphens (e.g., `code-review`)
- No existing workflow with the same ID in target location
- Template directory exists at `.harmony/workflows/_template/`

## Failure Conditions

- Invalid workflow ID format (not kebab-case) -> STOP, report format requirements
- Workflow ID already exists -> STOP, suggest `/update-workflow` or different ID
- Template directory missing -> STOP, report template not found error
- Cannot write to target directory -> STOP, check permissions

## Steps

1. [Validate ID](./01-validate-id.md) - Check format and uniqueness
2. [Analyze requirements](./02-analyze-requirements.md) - Gather workflow purpose and steps
3. [Select template](./03-select-template.md) - Choose base template variant
4. [Generate structure](./04-generate-structure.md) - Create directory and files
5. [Customize steps](./05-customize-steps.md) - Fill in step-specific content
6. [Integrate gap fixes](./06-integrate-gap-fixes.md) - Add idempotency, checkpoints, etc.
7. [Update references](./07-update-references.md) - Update catalog and index files
8. [Verify](./08-verify.md) - Validate created workflow

## Verification Gate

Create Workflow is NOT complete until:
- [ ] All step files have required sections (Actions, Output, Proceed When)
- [ ] Overview has complete frontmatter including version and gap fields
- [ ] At least one failure condition is defined
- [ ] Final step is a verification step
- [ ] Idempotency checks are present in each step

## Output

```text
.harmony/workflows/<domain>/<workflow-id>/
├── 00-overview.md       # Complete with frontmatter + gap fields
├── 01-<step-name>.md    # First step with idempotency section
├── 02-<step-name>.md    # Second step
├── ...
└── NN-verify.md         # Final verification step
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-14 | Initial version |

## References

- **Template:** `.harmony/workflows/_template/`
- **Gap fixes guide:** `.harmony/context/workflow-gaps.md`
- **Quality criteria:** `.harmony/context/workflow-quality.md`
- **Existing examples:** `.harmony/workflows/refactor/`, `.harmony/workflows/skills/create-skill/`
