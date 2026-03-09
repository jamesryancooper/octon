---
title: Create Workflow
description: Scaffold a canonical pipeline and its workflow projection.
access: agent
argument-hint: <workflow-id>
---

# Create Workflow `/create-workflow`

Create a new canonical pipeline under
`/.harmony/orchestration/runtime/pipelines/` and generate the corresponding
workflow projection under `/.harmony/orchestration/runtime/workflows/`.

## Usage

```text
/create-workflow <workflow-id>
/create-workflow <workflow-id> --domain <domain>
```

## Implementation

Execute the canonical pipeline at:

- `/.harmony/orchestration/runtime/pipelines/meta/create-workflow/`

The pipeline should:

1. Validate the requested id and target group.
2. Gather inputs for the canonical pipeline contract.
3. Scaffold `pipeline.yml` and `stages/`.
4. Fill projection metadata.
5. Generate the workflow projection.
6. Validate pipeline and projection integrity.

## Outputs

- New canonical pipeline directory
- Generated workflow projection surface
- Updated manifest and registry entries as required
