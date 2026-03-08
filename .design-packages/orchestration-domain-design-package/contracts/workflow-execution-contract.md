# Workflow Execution Contract

## Purpose

Define the canonical workflow metadata and execution interface used by the
orchestration controller to launch workflows deterministically.

This contract is normative for workflow execution metadata, launch requests,
executor acknowledgements, and workflow state mapping.

## Required Workflow Artifacts

```text
workflows/
├── manifest.yml
├── registry.yml
└── <group>/<workflow-id>/
    ├── WORKFLOW.md
    ├── 01-*.md
    ├── ...
    └── NN-verify.md
```

## Workflow Syntax

### `WORKFLOW.md`

`WORKFLOW.md` MUST contain YAML frontmatter with:

- `name`
- `description`
- `steps[]` for multi-file workflows

Each `steps[]` entry MUST declare:

- `id`
- `file`
- optional `description`

### Step Files

Step files are numbered, ordered Markdown instructions. The orchestrator does
not parse step internals as executable code, but it relies on the workflow
metadata and ordered step list to resolve the correct entrypoint and verify that
the workflow shape is canonical.

## Workflow Metadata Schema

The workflow registry metadata consumed by orchestration MUST provide:

| Field | Required | Notes |
|---|---|---|
| `workflow_group` | yes | canonical workflow group |
| `workflow_id` | yes | canonical workflow id |
| `version` | yes | semantic version for the executable workflow definition |
| `entrypoint_ref` | yes | relative path to `WORKFLOW.md` or single-file workflow |
| `side_effect_class` | yes | `none`, `read_only`, `mutating`, `destructive` |
| `execution_controls.cancel_safe` | yes | explicit boolean |
| `coordination_key_strategy` | yes | strategy object defined below |
| `required_inputs[]` | yes | input contract |
| `produced_outputs[]` | yes | declared output contract |
| `executor_interface_version` | yes | currently `workflow-executor-v1` |

### `coordination_key_strategy`

```yaml
coordination_key_strategy:
  kind: "none" | "workflow-target" | "mission-target" | "incident-target" | "explicit-input"
  source_fields:
    - "target_path"
  format: "target:{target_path}"
```

Rules:

- `kind=none` is allowed only when `side_effect_class` is `none` or `read_only`
- all other kinds require `source_fields[]` and `format`
- `format` is a deterministic string template over declared source fields only
- missing required source fields block launch

## Required Inputs

Each `required_inputs[]` entry MUST declare:

- `name`
- `value_type`: `string`, `integer`, `number`, `boolean`, `object`, `array`
- `required`
- optional `default`

Required inputs ignore defaults. Missing required inputs block launch.

## Produced Outputs

Each `produced_outputs[]` entry MUST declare:

- `name`
- `value_type`
- `required`

This is the contract for workflow result publication into run evidence or
downstream orchestration state.

## Workflow Execution Interface

The orchestration controller launches workflows through the conceptual request:

```text
launch_workflow(
  workflow_ref,
  workflow_version,
  run_id,
  decision_id,
  coordination_key?,
  parameters,
  execution_context
)
```

### Launch Request Fields

| Field | Required | Notes |
|---|---|---|
| `workflow_ref` | yes | canonical workflow reference |
| `workflow_version` | yes | resolved executable version |
| `run_id` | yes | canonical active run id |
| `decision_id` | yes | routing basis |
| `coordination_key` | required when side effects are possible | derived before launch |
| `parameters` | yes | validated input map |
| `execution_context` | yes | may include `mission_id`, `automation_id`, `incident_id`, `event_id`, `queue_item_id` |

### Launch Response

The executor MUST return one of:

| Response | Meaning |
|---|---|
| `accepted` | executor accepted ownership and returns `executor_id` |
| `rejected` | executor refused before work began; include reason code |

`accepted` response MUST include:

- `executor_id`
- `accepted_at`

`rejected` response MUST cause the run to enter recovery or failure handling per
the run-liveness and failure contracts.

## Execution State Model

Executor-local workflow execution states are:

- `pending`
- `accepted`
- `running`
- `succeeded`
- `failed`
- `cancelled`
- `recovery_pending`

### Mapping To Run States

| Executor State | Run State |
|---|---|
| `pending` | run exists, `status=running`, no executor acknowledgement yet |
| `accepted` | run `status=running`, `executor_acknowledged_at` present |
| `running` | run `status=running` |
| `succeeded` | run `status=succeeded` |
| `failed` | run `status=failed` |
| `cancelled` | run `status=cancelled` |
| `recovery_pending` | run `status=running`, `recovery_status=recovery_pending` |

## Coordination-Key Derivation

The orchestration controller derives the coordination key from
`coordination_key_strategy` plus launch context:

1. resolve strategy
2. resolve each source field from launch inputs or context
3. apply deterministic `format`
4. emit the resulting `coordination_key`

If any required source field is missing or ambiguous, launch MUST `block`.

## Invariants

- Every workflow advertises `side_effect_class`.
- Every workflow advertises `cancel_safe`.
- Every side-effectful workflow advertises a non-`none`
  `coordination_key_strategy`.
- Orchestration never launches a workflow without a resolved `workflow_version`.

## Relationship To Existing Workflow Docs

This package does not redefine the human-readable workflow authoring model
outside the fields above. It defines the minimum executable contract the
orchestration controller requires.
