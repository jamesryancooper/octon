# Scope

_Status: In-review proposal packet artifact_


## In scope

- `.octon` entry and agent-facing adapter framing.
- `.octon/README.md` super-root orientation wording.
- `.octon/instance/ingress/**` framing language.
- `.octon/instance/bootstrap/START.md` orientation language.
- Terminology glossary updates for Governed Workflow Runtime, task-specific execution harness, bounded agent node, and compatibility status for Governed Agent Runtime.
- Architecture specification companion wording that signposts the canonical runtime framing.
- Validation and acceptance criteria for wording changes.
- Proposal-local handling of root `README.md` and `AGENTS.md` as linked
  repo-local companion scope.

## Out of scope

- New runtime behavior.
- Workflow statechart schemas.
- Task-specific execution harness schemas.
- Agent-node contract schemas.
- Workflow history/replay implementation.
- Idempotency/retry/compensation implementation.
- Connector operation admission implementation.
- Durable Object adapter implementation.
- MCP integration.
- External workflow-engine integration.
- Runtime crate behavior changes.
- Direct promotion of repo-root `README.md` or `AGENTS.md` from this
  octon-internal active proposal.
