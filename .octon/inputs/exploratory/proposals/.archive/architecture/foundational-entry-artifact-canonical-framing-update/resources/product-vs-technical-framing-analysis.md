# Product vs Technical Framing Analysis

_Status: In-review proposal packet artifact_


## Product-facing

Audience should understand:
- Octon helps make agent-assisted work safer and more reliable.
- Reliability comes from the governed workflow, not agent magic.
- Agents can work without being in charge.

## Technical-facing

Architecture readers should understand:
- workflow state owns control;
- task-specific execution harnesses bind execution;
- agents are bounded activity nodes;
- material effects require authorization and typed effect tokens;
- evidence/replay/rollback/closeout are required.

## Agent-facing

Agents should understand:
- read order and authority roots;
- workflow state first;
- no self-authorization;
- no control truth mutation without authorized effect token;
- no connector/tool ambient permission;
- generated and input surfaces are non-authority.
