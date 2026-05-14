# Architecture Proposal

_Status: In-review proposal packet artifact_


## Proposal

Update Octon's foundational entry artifacts so the repository's first-contact framing matches the runtime architecture Octon is already building toward.

## Canonical framing to promote

> Octon is a governed workflow runtime for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes.

## Product framing to use carefully

The root README may use:

> Put agents to work without putting them in charge.

It may also use this explanatory sentence:

> Octon turns agent-assisted software work into deterministic, governed workflows with authorization, evidence, replay, rollback, and human intervention built in.

Use "Agents you can count on — because the workflow is in control" only as an optional explanatory line, not as the sole tagline, because reliability comes from governed workflow control rather than inherent agent dependability.

## Architectural claim

Octon should not be framed as:
- an orchestrator of agents;
- a generic agent framework;
- a prompt-governance system;
- an agent memory/control plane;
- an external workflow-engine wrapper;
- a meta-harness coordinating rival control planes.

Octon should be framed as:
- a Constitutional Engineering Harness as the whole-system identity;
- a Governed Workflow Runtime as the runtime/core identity;
- a compiler/enforcer of task-specific execution harnesses;
- a system that admits bounded agent nodes as evidenced activities.

## Evidence from current architecture

- Root README already says Octon binds consequential runs to objectives, run contracts, capabilities, authorization decisions, retained evidence, rollback posture, continuity state, and review/disclosure surfaces.
- Run Lifecycle v1 defines fail-closed lifecycle state and canonical run journal control.
- Execution Authorization v1 defines engine-owned authorization before material effects.
- Authorized Effect Token v1 requires typed tokens and verifier-produced guards before mutation.
- Context Pack Builder v1 deterministically produces retained context evidence and is subordinate to authorization.
- Evidence Store v1 separates live control truth from retained evidence.
- Architecture specification and registry define class-root boundaries and non-authority rules for generated and input surfaces.

## Scope boundary

This is not a runtime refactor. It is the framing foundation for later packets that will implement statecharts, harness compilation, agent-node contracts, replay, connector admission, and durable coordination evaluation.
