# Current-State Gap Map

_Status: In-review proposal packet artifact_


| Current artifact / concept | Current framing | Risk | Proposed correction | Implementation file |
|---|---|---|---|---|
| `README.md` | "Octon helps AI agents build software..." | Agent-first entry point | Route through linked repo-local companion proposal; open with governed workflow/runtime framing there | `readme-edit-plan.md` |
| `AGENTS.md` | "Enable reliable agent execution..." | Agent execution appears primary | Route through linked repo-local companion proposal; preserve adapter parity there | `agents-edit-plan.md` |
| `.octon/AGENTS.md` | Same adapter framing | Same | Update octon-internal adapter framing and coordinate root parity through companion scope | `agents-edit-plan.md` |
| `.octon/README.md` | Super-root with agents getting room to work | Agent-first phrase before workflow/state | Add governed workflow runtime statement before agent room | `proposed-entry-artifact-edits.md` |
| `.octon/instance/ingress/AGENTS.md` | Reliable agent execution | Agent-first behavioral contract | Add "workflow state owns control flow; agents operate inside admitted harnesses" | `ingress-entry-artifact-edit-plan.md` |
| `.octon/instance/bootstrap/START.md` | Good authority map and runtime helper language | Minor: no canonical workflow runtime phrase | Add one sentence naming governed workflow runtime orientation | `ingress-entry-artifact-edit-plan.md` |
| Architecture specification | Strong class-root model | Needs explicit target framing | Add companion paragraph; no topology change | `architecture-meta-edit-plan.md` |
| Terminology glossary | Defines Governed Agent Runtime | Agent runtime remains canonical only term | Add Governed Workflow Runtime and bounded agent node; mark GAR compatibility | `terminology-map.md` |
| Support-target governance | Referenced as live support boundary | None | Preserve; mention support-target admission in README | `readme-edit-plan.md` |
| Run lifecycle references | Strong deterministic state machine | Under-highlighted at entry layer | Mention workflow state and run lifecycle earlier | `readme-edit-plan.md` |
| Execution authorization references | Strong engine-owned boundary | Under-highlighted at entry layer | Mention authorization before material effects | `readme-edit-plan.md` |
| Context-pack references | Strong deterministic context proof | Under-highlighted at entry layer | Mention deterministic context packs | `readme-edit-plan.md` |
| Generated/input non-authority | Strong in `.octon/README` and spec | Must persist | Preserve and echo in linked root README companion | `canonical-framing-rules.md` |
| Connector/MCP references | Connector admission surfaces exist | Tool availability confusion | Explicit "tool availability is not permission" rule | `canonical-framing-rules.md` |
| Durable Objects | No current entry-artifact surface observed | Future live coordination may be mistaken for authority | Only mention as possible future coordination adapter, never authority | `durable-coordination-framing-note.md` |
