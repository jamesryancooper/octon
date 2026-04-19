# Reconciliation Verdict Matrix

| Current repo state | Target-state requirement | Final adjudication | Repository consequence |
|---|---|---|---|
| Agency subsystem with agents/assistants/teams | Execution-role subsystem | Replace | Delete `framework/agency/**`; add `framework/execution-roles/**`. |
| Agents are accountable execution roles | Orchestrator/verifier roles | Rename/collapse | Promote orchestrator/verifier under execution roles. |
| Assistants are focused specialists | Specialists | Replace noun | Promote specialists; delete assistant family. |
| Teams are composition artifacts | Composition profiles | Rename | Promote composition profiles; delete teams. |
| Subagent runtime term only | Runtime-only subagent | Keep as glossary only | No durable subagent surface. |
| Actor taxonomy language | Execution role canonical noun | Replace | Rename `actor_ref` to `execution_role_ref`. |
| Mission continuity and transitional mission-only execution | Mission continuity only; run-contract execution | Remove transitional path | Delete mission-only execution language. |
| Workflow catalog broad and token-routed | Governance-critical workflows only | Reduce | Delete/demote thinking-only workflows. |
| Capability packs exist | Governance-grade envelopes | Keep/strengthen | Require pack admission per support tuple. |
| Support targets finite | Dossier-backed finite live tuples | Keep/harden | Align charter/schema and live claims. |
| Runtime services lack browser/API | Browser/API live only runtime-real | Demote or build | No live browser/API claim until services/proof exist. |
| Generated cognition derived-only | Derived context only | Keep/harden | Add context-pack provenance/freshness rules. |
| Lab/observability exist | Proof-producing gates | Keep/harden | Add scenarios, benchmarks, replay, RunCard/HarnessCard gates. |
