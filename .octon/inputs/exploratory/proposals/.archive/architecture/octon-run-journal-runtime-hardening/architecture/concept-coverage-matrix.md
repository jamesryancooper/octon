# Concept Coverage Matrix

| Concept implicated by this step | Existing Octon coverage | Coverage quality | Proposal action | Adopt/reuse/defer |
|---|---|---:|---|---|
| Canonical Run event ledger | Runtime constitutional contracts already define run event ledger surfaces. | Partial | Strengthen to v2 and align engine/runtime surfaces. | Reuse + strengthen |
| Runtime event stream | Engine runtime spec already has `runtime-event-v1`. | Partial | Normalize to canonical Run Journal event family. | Reuse + align |
| Run lifecycle state machine | Runtime spec already defines run lifecycle and fail-closed transitions. | Partial | Tie transitions to event IDs, sequence, and derived runtime-state. | Reuse + harden |
| State reconstruction | Constitution contract already states ledger wins over runtime-state. | Strong concept, thin enforcement | Add validator and replay-store implementation. | Strengthen |
| Evidence closeout | Evidence-store and evidence obligations already exist. | Strong concept, needs journal snapshot rule | Require snapshot/hash match and closeout event. | Strengthen |
| Authorization boundary | `authorize_execution` contract and boundary coverage exist. | Strong | Require journal refs for all material authorization/receipt events. | Reuse + enforce |
| Generated read-model non-authority | Architecture spec and operator-read-models spec already enforce. | Strong | Add journal-derived source refs and negative tests. | Strengthen |
| Support-target admission | Support targets require runtime-event-ledger for certain surfaces. | Partial | Add admission test pack requiring valid journal/reconstruction. | Strengthen |
| Capability invocation evidence | Execution receipts and capability packs exist. | Partial | Require capability event pairs with lease/grant/effect refs. | Strengthen |
| Replay and lab regression | Replay/lab surfaces exist. | Partial | Derive replay and trace-to-lab candidates from journal. | Strengthen |
| Browser/API/MCP expansion | Stage-only/non-live. | Correctly deferred | No admission in this packet. | Defer |
| Multi-agent orchestration | Orchestration surfaces exist. | Not directly required | Do not implement; only journal future subagent events if later admitted. | Defer |
