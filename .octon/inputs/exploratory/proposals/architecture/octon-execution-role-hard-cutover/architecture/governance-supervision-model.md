# Governance and Supervision Model

## Core model

Human supervision is keyed to:

- reversibility
- irreversibility
- external effect
- data exposure
- materiality
- support-target class
- capability pack
- rollback/compensation posture

It is not keyed to arbitrary step count.

## Supervision postures

| Posture | Meaning |
|---|---|
| observe | The system may inspect/read and retain trace without side effects. |
| notify | The system proceeds but records and notifies according to policy. |
| feedback window | The system pauses or waits for feedback before continuing beyond a boundary. |
| approve | Governance or authorized policy authority must approve before action. |
| escalate | The system cannot decide locally; it routes to human/policy authority. |
| revoke | A live grant/lease/capability is withdrawn through canonical control state. |
| override | A human governance owner intentionally supersedes a default control decision, with evidence. |
| break-glass | Emergency override under strict owner and evidence rules. |
| audit-after-the-fact | Low-risk admitted work can be reviewed after completion from retained evidence. |

## Reversibility classes

| Class | Definition | Default |
|---|---|---|
| reversible | Can be reverted within the run envelope using ordinary rollback. | notify or feedback window |
| compensable | Cannot be directly reverted but has documented compensation. | approval or escalate |
| irreversible | Cannot be reliably reverted or compensated. | approval required |

## Materiality classes

- repository-local non-material
- repository-consequential
- boundary-sensitive
- external-effecting
- data-exposing
- legal/financial/public
- irreversible/destructive

## Accountability

- Orchestrator owns run accountability.
- Specialist owns only scoped output.
- Verifier owns independent assessment only.
- Composition profile owns no execution.
- Engine owns authorization enforcement.
- Humans own support widening, break-glass, revocation, external commitments, and irreversible approvals.

## Control artifact rule

Approvals, exceptions, revocations, overrides, break-glass actions, and
interventions must be canonical control artifacts under `state/control/**` with
retained evidence under `state/evidence/**`. Labels, comments, checks, UI clicks,
or chat messages may project but never mint authority.
