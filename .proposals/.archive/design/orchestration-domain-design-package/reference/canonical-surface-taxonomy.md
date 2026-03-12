# Canonical Surface Taxonomy

## Taxonomy Summary

| Surface | Class | Time Horizon | Current Status In Harmony | Primary Question It Answers |
|---|---|---|---|---|
| `campaigns` | Strategic portfolio | long-lived | proposed | Which set of missions serves one larger objective? |
| `missions` | Initiative state | bounded multi-session | current | What bounded initiative is active, who owns it, and what remains? |
| `workflows` | Procedure definition | bounded run | current | What sequence of bounded steps should happen? |
| `automations` | Launch policy | recurring or event-driven | proposed | When should a workflow run without manual initiation? |
| `runs` | Execution instance | per invocation | mixed; evidence exists today | What happened during a concrete execution? |
| `incidents` | Operational override | until stabilized and closed | governance exists today | What abnormal condition is active, and how are we containing it? |
| `watchers` | Event detector | long-lived | proposed | Did a monitored condition cross a threshold or match a rule? |
| `queue` | Intake buffer | transient but durable | proposed | Which pending machine-ingest work items await claiming or retry? |

## Hierarchical Order

The most useful hierarchy is by responsibility layer rather than a single
linear inheritance chain.

### Strategic Layer

- `campaigns`

### Initiative Layer

- `missions`

### Trigger Layer

- `watchers`
- `queue`
- `automations`

### Execution Layer

- `workflows`
- `runs`

### Override Layer

- `incidents`

## Canonical Parent/Child Relationships

| Parent | Child | Relationship |
|---|---|---|
| `campaigns` | `missions` | Campaigns group and prioritize missions |
| `missions` | `workflows` | Missions often invoke workflows to advance initiative work |
| `watchers` | `queue` | Watchers emit events into a queue |
| `queue` | `automations` | Automations claim or consume queued events |
| `automations` | `workflows` | Automations launch workflows |
| `workflows` | `runs` | Each material execution should produce a run |
| `incidents` | `workflows`, `missions`, `runs` | Incidents reference and redirect normal execution surfaces |

## Surface Ownership Rules

### `campaigns`

- Own portfolio grouping
- Do not own execution steps

### `missions`

- Own bounded multi-session intent and progress
- Do not replace workflows

### `workflows`

- Own procedure definition
- Do not own recurrence or portfolio logic

### `automations`

- Own recurrence, trigger policy, and unattended launch behavior
- Do not own procedure content

### `runs`

- Own execution identity and result state
- Do not own future intent

### `incidents`

- Own abnormal-condition state and response timeline
- Do not become normal task planning

### `watchers`

- Own detection
- Do not own procedure orchestration

### `queue`

- Own pending intake and claim/ack state
- Do not own long-term initiative planning

## Canonical Maturity Position

Harmony's mature taxonomy should explicitly treat:

- `workflows`, `missions`, and `runs` as core
- `automations` as the first autonomy extension
- `watchers` and `queue` as event-scale extensions
- `incidents` as an override and containment surface
- `campaigns` as an optional portfolio surface
