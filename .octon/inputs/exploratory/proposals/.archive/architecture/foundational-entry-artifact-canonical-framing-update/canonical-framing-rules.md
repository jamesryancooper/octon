# Canonical Framing Rules

_Status: In-review proposal packet artifact_


## Rule 1 — Product-facing framing

The linked root README companion may use product framing:

> Put agents to work without putting them in charge.

and:

> Octon turns agent-assisted software work into deterministic, governed workflows with authorization, evidence, replay, rollback, and human intervention built in.

Avoid implying that agents themselves are inherently reliable. Reliability comes from the workflow/runtime harness.

## Rule 2 — Technical framing

Architecture-facing and agent-facing artifacts must prefer:

> Octon is a governed workflow runtime for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes.

## Rule 3 — Workflow control

> Workflow state owns control flow. Agents do not.

## Rule 4 — Agent-node boundary

Agents may produce:
- candidate artifacts;
- summaries;
- reviews;
- classifications;
- patches;
- repair suggestions;
- exception recommendations.

Agents may not:
- authorize effects;
- own workflow state;
- schedule themselves indefinitely;
- mutate control truth;
- admit connectors;
- close work.

## Rule 5 — Connector/tool boundary

> Connector and tool availability is not permission. Connectors are admitted operations, not ambient capabilities.

## Rule 6 — Durable coordination boundary

Durable Objects may be mentioned only as possible future live coordination adapters.

> Durable Objects may coordinate live work in a future adapter, but Octon must still decide, authorize, evidence, replay, rollback, and close work. Durable Object state must never become Octon authority, control truth, or evidence.

## Rule 7 — Non-authority surfaces

Generated projections, raw inputs, chat, labels, issue bodies, comments, host UI affordances, model memory, external dashboards, MCP servers, and Durable Object state must not be described as authority, permission, runtime policy, or closeout truth.
