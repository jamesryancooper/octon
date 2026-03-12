# Workflow Execution Contract

## Purpose

Define the schema-backed workflow definition artifact and execution interface
used by orchestration to launch workflows deterministically.

This contract is normative for `workflow.yml`, subordinate stage assets,
registry projection rules, launch requests, executor acknowledgements, and
workflow state mapping.

## Required Workflow Artifacts

```text
workflows/
├── manifest.yml
├── registry.yml
└── <group>/<workflow-id>/
    ├── workflow.yml
    ├── stages/
    │   ├── 01-*.md
    │   ├── ...
    │   └── 99-verify.md
    └── README.md
```

`README.md` is optional for execution and may be generated. It is not the
canonical execution contract.

## Workflow Authority Model

- `manifest.yml`
  - discovery identity, trigger hints, and path projection
- `registry.yml`
  - routing metadata, commands, access, dependency projections, and optional
    summaries derived from `workflow.yml`
- `workflow.yml`
  - authoritative machine-readable workflow definition consumed by orchestration
- `stages/*.md`
  - executor-facing stage assets resolved only through `workflow.yml`
- run and evidence context outside the workflow tree
  - `runtime/runs/` plus `continuity/runs/`

`workflow_group` and `workflow_id` are resolved from `manifest.yml`,
`registry.yml`, and canonical pathing. They do not need to be duplicated inside
`workflow.yml`.

## `workflow.yml` Required Fields

| Field | Required | Notes |
|---|---|---|
| `schema_version` | yes | currently `workflow-contract-v1` |
| `name` | yes | human-readable workflow name |
| `description` | yes | bounded procedure summary |
| `version` | yes | semantic version for the executable workflow definition |
| `entry_mode` | yes | invocation posture declared by the workflow author |
| `execution_profile` | yes | `core` or `external-dependent` |
| `side_effect_class` | yes | `none`, `read_only`, `mutating`, `destructive` |
| `execution_controls.cancel_safe` | yes | explicit boolean used by automation `replace` |
| `coordination_key_strategy` | yes | strategy object defined below |
| `inputs[]` | yes | input contract for runtime launch parameters |
| `stages[]` | yes | ordered stage graph and asset references |
| `artifacts[]` | yes | declared workflow-produced files or directories |
| `done_gate.checks[]` | yes | explicit verification obligations |
| `constraints.fail_closed` | yes | must remain `true` |
| `constraints.require_relative_local_assets` | yes | must remain `true` |
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

## Workflow Inputs

Each `inputs[]` entry MUST declare:

- `name`
- `type`
- `required`
- optional `default`
- optional `description`

Missing required inputs block launch. Optional defaults are resolved before the
workflow is handed to the executor.

## Workflow Stages

Each `stages[]` entry MUST declare:

- `id`
- `asset`
- `kind`
- `consumes[]`
- `produces[]`
- `mutation_scope[]`

Rules:

- `asset` must point to a local Markdown file under `stages/`
- stage assets are subordinate to `workflow.yml`
- stage assets may elaborate execution instructions, but they must not redefine
  inputs, artifacts, side-effect classification, or coordination semantics
- `README.md` may summarize stages, but it must not outrank `workflow.yml`

## Workflow Artifacts And Done Gate

`artifacts[]` declare workflow-produced files or directories that downstream
operators, missions, or automation consumers may expect.

`done_gate.checks[]` declare the verification obligations required before a run
can be considered complete.

Both belong in `workflow.yml`, not in registry projections or prose guidance.

## Registry Projection Rules

`registry.yml` may project selected workflow facts for routing or UX, including:

- commands
- access mode
- dependency references
- summarized input or artifact information

If the registry projects fields that also exist in `workflow.yml`, the
`workflow.yml` value is authoritative.

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
| `workflow_version` | yes | resolved `workflow.yml` version |
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

1. resolve strategy from `workflow.yml`
2. resolve each source field from launch inputs or context
3. apply deterministic `format`
4. emit the resulting `coordination_key`

If any required source field is missing or ambiguous, launch MUST `block`.

## Invariants

- Every workflow has one schema-backed `workflow.yml`.
- Every workflow advertises `side_effect_class`.
- Every workflow advertises `execution_controls.cancel_safe`.
- Every side-effectful workflow advertises a non-`none`
  `coordination_key_strategy`.
- Orchestration never launches a workflow without a resolved `workflow_version`.
- `README.md` and registry projections never outrank `workflow.yml`.

## Relationship To Existing Workflow Docs

This package does not redefine the executor-facing Markdown authoring model. It
defines the machine-readable workflow contract that those assets must obey.
