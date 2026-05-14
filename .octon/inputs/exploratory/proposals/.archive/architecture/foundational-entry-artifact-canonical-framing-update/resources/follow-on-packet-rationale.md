# Follow-On Packet Rationale

_Status: In-review proposal packet artifact_


The framing update should precede deeper runtime packets so later proposals have a consistent canonical direction.

## Why statechart packet follows

Run Lifecycle v1 already defines a fail-closed state machine. A statechart packet turns this into explicit machine-readable workflow-state discipline across mission, action-slice, connector, human-task, and agent-node surfaces.

## Why harness packet follows

The README should introduce task-specific execution harnesses before a later packet defines their schema and compilation record.

## Why agent-node packet follows

Agent nodes must be defined after workflow state and execution harness boundaries are established.

## Why Durable Coordination comes later

Durable Objects are useful only after workflow history, PEP inventory, and evidence receipt rules exist. Otherwise they risk becoming hidden control truth.
