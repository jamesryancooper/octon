---
title: Create Workspace
description: Scaffold a new .workspace directory in a target location.
access: human
version: "1.2.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps:
  - group: "validation"
    steps: ["01-validate-prerequisites", "02-validate-target"]
    join_at: "03-analyze-context"
---

# Create Workspace: Overview

Scaffold a new `.workspace` directory in a target location, customized to the directory's context.

## Target

Parent directory where `.workspace/` will be created.

## Prerequisites

- Exactly one parent directory reference provided
- `.workspace/templates/workspace/` exists

## Failure Conditions

- Target directory does not exist → STOP, report error
- `.workspace/` already exists in target → STOP, suggest `/update-workspace` instead
- Templates directory missing → STOP, report error

## Steps

1. [Validate prerequisites](./01-validate-prerequisites.md)
2. [Validate target](./02-validate-target.md)
3. [Analyze context](./03-analyze-context.md)
4. [Gather input](./04-gather-input.md)
5. [Copy templates](./05-copy-templates.md)
6. [Customize](./06-customize.md)
7. [Verify](./07-verify.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2025-01-14 | Added frontmatter and Idempotency sections to all step files |
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Templates:** `.workspace/templates/workspace/`
