# Executive Summary

_Status: In-review proposal packet artifact_


## Decision

Implement an octon-internal foundational entry-artifact framing update before deeper workflow-statechart, harness-compilation, agent-node, replay, connector, cost-routing, or durable-coordination packets.

## Core correction

The current repository already supports deterministic-governed execution as an architectural reality. The entry artifacts should now say that plainly:

> Octon turns agent-assisted software work into deterministic, governed workflows with authorization, evidence, replay, rollback, and human intervention built in.

The preferred product line for the repo-root README companion scope is:

> Put agents to work without putting them in charge.

The preferred technical framing is:

> Octon is a governed workflow runtime for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes.

## Why now

The root README currently opens with "Octon helps AI agents build software..." and describes Octon as a Constitutional Engineering Harness with a Governed Agent Runtime. This remains directionally true, but it centers agents more strongly than the runtime architecture itself does.

The live runtime contracts already center deterministic control:
- Run Lifecycle v1 defines a fail-closed state machine and canonical run journal.
- Execution Authorization v1 defines engine-owned authorization before material effects.
- Authorized Effect Token v1 requires typed tokens and `VerifiedEffect` guards.
- Context Pack Builder v1 deterministically assembles retained context evidence.
- Evidence Store v1 separates live control truth from retained evidence.
- The architecture registry keeps generated projections and proposal inputs non-authoritative.

## Scope

This packet updates octon-internal framing and signposting only. It does not implement deeper runtime capabilities. Repo-root `README.md` and `AGENTS.md` remain linked companion scope because active proposal packets may not mix `.octon/**` and non-`.octon/**` promotion targets.

## Outcome

After promotion, Octon's first-contact artifacts should make it difficult to misread Octon as:
- an orchestrator of agents;
- a generic agent framework;
- a prompt-governance system;
- a model memory/control plane;
- a meta-harness around rival control planes;
- an MCP/tool permission system;
- a Durable Object-backed authority plane.
