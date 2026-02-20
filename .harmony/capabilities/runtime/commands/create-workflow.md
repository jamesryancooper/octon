---
title: Create Workflow
description: Scaffold a new workflow with gap-aware structure.
access: human
argument-hint: <workflow-id>
---

# Create Workflow `/create-workflow`

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

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `workflow-id` | Kebab-case workflow identifier (e.g., `code-review`) | Required |
| `--domain` | Subdirectory under `.harmony/orchestration/runtime/workflows/` | Prompts user |
| `--local` | Create in `.harmony/orchestration/runtime/workflows/` instead of `.harmony/` | false |

## Implementation

Execute the workflow in `.harmony/orchestration/runtime/workflows/meta/create-workflow/`.

Start with `00-overview.md`, then follow each step in sequence:

1. Validate ID - Check format and uniqueness
2. Analyze requirements - Gather purpose and steps
3. Select template - Choose template variant
4. Generate structure - Create directory and files
5. Customize steps - Fill in content
6. Integrate gap fixes - Add idempotency, checkpoints, etc.
7. Update references - Update catalog
8. Verify - Validate created workflow

## Output

New workflow directory with:
- `00-overview.md` with complete frontmatter and gap fix fields
- Numbered step files with idempotency sections
- Verification step as final step
- Version history initialized

## Key Features

- **Gap-Aware:** All generated workflows include gap remediation features
- **Template-Based:** Uses `.harmony/orchestration/runtime/workflows/_scaffold/template/` for consistency
- **Guided:** Prompts for requirements if not provided
- **Verified:** Final step validates structure and content

## References

- **Workflow:** `.harmony/orchestration/runtime/workflows/meta/create-workflow/`
- **Template:** `.harmony/orchestration/runtime/workflows/_scaffold/template/`
- **Gap Guide:** `.harmony/cognition/context/workflow-gaps.md`
- **Quality Criteria:** `.harmony/cognition/context/workflow-quality.md`
