# Final Execution Role System Specification

## 1. Canonical noun

The canonical durable noun is **execution role**.

Rejected canonical nouns:

- agent
- assistant
- team
- actor
- persona
- identity

## 2. Final role model

### Orchestrator

The orchestrator is the single accountable execution role for each consequential
run. It owns planning, sequencing, integration, delegation decisions, escalation,
and closeout evidence. Exactly one orchestrator is allowed per consequential run.

### Specialist

A specialist is a bounded stateless scoped helper. It may perform focused work
inside the orchestrator's granted envelope. It may not own mission lifecycle,
expand capabilities, authorize execution, mutate durable continuity directly, or
delegate recursively.

### Verifier

A verifier is an optional independent execution role used only when materiality,
separation of duties, weak deterministic proof, or support-claim proof requires
independent judgment.

### Composition profile

A composition profile is reusable routing/handoff configuration. It is not a
runtime actor and does not execute.

## 3. Execution hierarchy

```text
objective -> mission -> run-contract -> workflow instance -> stage-attempt
```

- `objective` defines durable intent.
- `mission` carries continuity/autonomy only.
- `run-contract` is the atomic consequential execution unit.
- `workflow instance` exists only for governance/evidence/recovery sequencing.
- `stage-attempt` is local procedural execution.

## 4. Registry model

The execution-role registry must define:

- `role_id`
- `role_kind`: `orchestrator | specialist | verifier | composition_profile`
- `path`
- `contract_file`
- `authority_posture`
- `continuity_posture`
- `delegation_posture`
- `allowed_capability_packs`
- `support_target_constraints`
- `activation_criteria`
- `evidence_obligations`
- `escalation_policy`

## 5. Deletion of old ontology

The final system removes:

- `framework/agency/**`
- `runtime/agents/**`
- `runtime/assistants/**`
- `runtime/teams/**`
- durable `subagents/**`
- persona or identity authority surfaces

No compatibility bridge is retained.

## 6. Mission/run/workflow relationship

A mission may bind many runs. A run is the unit of consequential execution.
A workflow is a procedural authority/evidence sequence within a run. A workflow
must not substitute for a run contract.

## 7. Specialist behavior

Specialists:

- are bounded by the orchestrator's grant;
- receive only context-pack slices permitted by the run envelope;
- return structured, evidence-linked outputs;
- may not mutate mission continuity except through orchestrator-mediated closeout;
- may not invoke browser/API/multimodal capabilities unless the run tuple and grant explicitly allow it.

## 8. Verifier behavior

Verifiers:

- must be independent of the generating specialist or orchestrator work product;
- evaluate against objective criteria, run contract, support target, and evidence obligations;
- may recommend approve, revise, escalate, or deny closeout;
- may not override engine authorization.

## 9. Rejected concepts

The following are rejected as final durable concepts:

- agent teams
- assistant hierarchies
- durable subagent trees
- persona networks
- SOUL or identity files
- roleplay-based planner/generator/evaluator as default system shape
