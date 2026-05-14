# Terminology Map

_Status: In-review proposal packet artifact_


| Term | Status | Definition / use |
|---|---|---|
| Constitutional Engineering Harness | canonical | Whole-system identity for Octon. Preserve. |
| Governed Workflow Runtime | canonical proposed | Runtime/core identity for deterministic workflow-first framing. |
| Harness-Compiled Workflow Runtime | canonical optional | More technical phrase for runtime that compiles task-specific execution harnesses. |
| deterministic governed workflow | canonical | Workflow whose state, authorization, evidence, and closeout are Octon-owned. |
| task-specific execution harness | canonical proposed | Compiled envelope binding objective, workflow state, support target, context, authorization, capabilities, evidence, rollback, cost, human intervention, and closeout. |
| bounded agent node | canonical proposed | Agent participation as typed/evidenced activity, not control owner. |
| evidenced activity node | canonical proposed | Stronger term for agent/tool/human activity with required receipts. |
| workflow state | canonical | Primary control surface. |
| control truth | canonical | Mutable operational truth under `state/control/**`. |
| retained evidence | canonical | Proof under `state/evidence/**`. |
| engine-owned authorization | canonical | Authorization boundary owned by runtime. |
| typed effect token | canonical | `AuthorizedEffect<T>` / `VerifiedEffect<T>` material-effect boundary. |
| deterministic context pack | canonical | Context evidence built by Context Pack Builder v1. |
| admitted connector operation | canonical | Connector action admitted by Octon, not ambient tool access. |
| generated projection | canonical | Rebuildable read model; never authority. |
| non-authoritative input | canonical | Raw/exploratory/additive inputs. |
| Governed Agent Runtime | compatibility | Existing term for runtime core; clarify as workflow runtime with bounded agent nodes. |
| agent runtime | compatibility | Avoid unless immediately clarified. |
| autonomy | compatibility | Use only with bounded/controlled/mission-continuation language. |
| orchestrator | compatibility | Valid only for role/component; not whole-system name. |
| harness | compatibility | Use only when defined; not synonym for prompt/model/orchestrator. |
| orchestrator of agents | discouraged | Centers agents as work owners. |
| autonomous agent worker | discouraged | Suggests agent-owned control. |
| prompt-governance system | discouraged | Under-describes runtime enforcement. |
| ambient tool access | discouraged | Conflicts with connector/capability admission. |
| Durable Object authority | forbidden | Durable Objects can only be future live coordination adapters. |
