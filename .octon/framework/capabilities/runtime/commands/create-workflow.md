---
title: Create Workflow
description: Scaffold a canonical workflow and its workflow README.
access: agent
argument-hint: <workflow-id>
---

# Create Workflow `/create-workflow`

Create a new canonical workflow under
`/.octon/framework/orchestration/runtime/workflows/` and generate the corresponding
workflow README under `/.octon/framework/orchestration/runtime/workflows/`.

## Usage

```text
/create-workflow <workflow-id>
/create-workflow <workflow-id> --domain <domain>
```

## Implementation

Execute the canonical workflow at:

- `/.octon/framework/orchestration/runtime/workflows/meta/create-workflow/`

The workflow should:

1. Validate the requested id and target group.
2. Gather inputs for the canonical workflow contract.
3. Scaffold `workflow.yml` and `stages/`.
4. Fill guide metadata.
5. Generate the workflow README.
6. Validate workflow contract and guide integrity.

## Outputs

- New canonical workflow directory
- Generated workflow README surface
- Updated manifest and registry entries as required
