# Surface: Automations

## Status

- Proposed

## Core Purpose

`automations` are recurring or event-triggered launch surfaces that decide when
bounded workflows should run without manual initiation.

## Responsibilities

- define recurrence or event-trigger policy
- bind triggers to workflow targets and parameters
- handle pause, resume, enable, disable, and retry controls
- maintain operator-visible launch state and last-run metadata

## Differentiators

- launch policy rather than procedure definition
- unattended execution wrapper rather than work definition
- can be scheduled or event-driven without changing workflow content

## Complexity

- `High`

## Criticality And Ranking

- Criticality: `6/10`
- Usefulness rank: `4`
- Need rank: `5`

## Implementation Contract

See `../contracts/automation-execution-contract.md` and
`../contracts/cross-surface-reference-contract.md`.

## Canonical Authority Model

- discovery
  - `manifest.yml`
- routing and metadata
  - `registry.yml`
- definition
  - `automation.yml`, `trigger.yml`, `bindings.yml`, `policy.yml`
- mutable state
  - `state/status.json`, `state/last-run.json`, `state/counters.json`
- durable evidence
  - linked `decision_id`, run records, and continuity evidence outside the
    automation tree

The definition layer must remain machine-readable. Markdown may orient
operators, but it must not become the canonical launch contract.

## Example Use Cases

1. A weekly automation that runs `audit-release-readiness-workflow` against a
   target subsystem every Monday morning.
2. A nightly automation that launches a freshness or drift audit workflow and
   opens an incident only when severity crosses policy.

## Relationships

### Complements Or Supports

- `workflows`
- `runs`
- `queue`
- `incidents`

### Depends On

- `workflows`
- optionally `watchers`
- optionally `queue`
- `runs`

### Surfaces Depend On It

- operators who want unattended execution
- `missions` that need recurring checks

### Autonomy Posture

- functions autonomously within explicit policy
- not self-governing

### Overlap Risks

- overlaps `watchers` if detection and launch are mixed together
- overlaps `workflows` if procedure logic migrates into automation definitions
- overlaps CI or external schedulers if boundaries are left implicit

## Proposed Canonical Artifacts

```text
automations/
├── README.md
├── manifest.yml
├── registry.yml
└── <automation-id>/
    ├── automation.yml
    ├── trigger.yml
    ├── bindings.yml
    ├── policy.yml
    └── state/
        ├── status.json
        ├── last-run.json
        └── counters.json
```

`automation.yml` owns automation identity and workflow target.

`trigger.yml` owns schedule or event selection.

`bindings.yml` owns workflow defaults and event input mapping.

`policy.yml` owns overlap, idempotency, retry, and automation-local incident
policy.

## Non-Goals

- defining procedural steps
- owning portfolio or initiative planning
- silently authorizing policy exceptions

## Additional Boundary Rule

Event-trigger selection belongs in `trigger.yml`. It should not be split across
`bindings.yml` or `policy.yml`.
