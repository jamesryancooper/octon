# Follow-On Packet Sequence

_Status: In-review proposal packet artifact_


1. **Workflow Statechart + Task-Specific Execution Harness** — make workflow statecharts and execution harness schemas explicit.
2. **Agent Node Contract** — formalize bounded agent-node inputs, outputs, model calls, tools, evidence, budgets, and no-authority rules.
3. **Workflow History / Replay** — extend run-level reconstruction into workflow-level replay.
4. **Idempotency, Retry, and Compensation** — make retry and rollback semantics explicit.
5. **Effect-Token Enforcement Coverage** — prove all material side-effect APIs require verified typed tokens.
6. **Connector Operation Admission** — mature connector/tool/MCP operation admission without treating availability as permission.
7. **Evidence / Provenance Hardening** — add model-call, agent-node, connector, workflow-transition, and provenance receipts.
8. **Cost-Aware Model Routing** — enforce small-model eligibility, cost envelopes, context budgets, retry budgets, and model-call receipts.
9. **Durable Coordination Adapter Evaluation** — evaluate Durable Objects only after prerequisites, and only as live coordination adapters.
10. **Migration, Cutover, Rollback, and Compatibility Retirement** — remove shims and retire compatibility surfaces after proof.

These are future packets. This foundational framing packet does not implement them.
