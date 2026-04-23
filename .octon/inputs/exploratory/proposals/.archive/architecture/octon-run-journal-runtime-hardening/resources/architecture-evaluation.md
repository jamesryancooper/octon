# Architectural Evaluation

## Why this is the single highest-leverage next step

The Run Journal hardening step is highest leverage because it touches the exact
surface where Octon's Constitutional Engineering Harness becomes real execution:
the Governed Agent Runtime's Run.

Octon already has strong constitutional posture:

- engine-owned authorization,
- deny-by-default support-target routing,
- retained evidence,
- generated/read-model non-authority,
- explicit run roots,
- fail-closed obligations,
- bounded support targets.

What remains is to make every consequential runtime transition reconstructable,
causal, replayable, validated, and evidence-backed. A canonical Run Journal does
that without widening Octon's action surface.

## Why this comes before other improvements

| Candidate next step | Why it is lower leverage right now |
|---|---|
| Browser/API/MCP admission | Stage-only surfaces need Run Journal proof before safe admission. |
| More memory | Durable memory writes need event/evidence/revocation substrate first. |
| Multi-agent orchestration | Subagent evidence stitching depends on causal journals. |
| Better operator UI | Operator views must derive from canonical journal/evidence roots. |
| More benchmarks | Lab regressions need replayable traces and evidence bundles. |
| Model-adapter expansion | Adapter conformance depends on runtime event/lifecycle semantics. |

## What current constraints make it necessary

1. **Split schemas** — constitutional run events and engine runtime events are
   not yet fully aligned.
2. **Mutable-state risk** — runtime-state can drift unless reconstruction is
   enforced.
3. **Replay risk** — replay without canonical causal events can be incomplete or
   unsafe.
4. **Evidence risk** — retained evidence can look complete without proving it
   matches live control truth.
5. **Generated-view risk** — operator projections can become de facto authority
   unless tied to canonical journal/evidence refs and rejected as runtime input.
6. **Support-target realism** — support claims are only credible if supported
   tuples produce valid journal evidence.

## Surfaces that already partially cover the step

- Runtime constitutional contracts: ledger, event, state, reconstruction.
- Engine runtime specs: authorization, event, lifecycle, evidence, operator
  read models, authorization-boundary coverage.
- Runtime crate layout: runtime bus, replay store, telemetry sink, authority
  engine, policy engine, assurance tools.
- Governance: support targets, mission autonomy, fail-closed, evidence
  obligations.
- Assurance/lab: validators, replay, scenarios, proof planes.

## What remains missing

- A v2 typed event envelope strong enough for causal replay.
- A ledger manifest strong enough for tamper-evidence and closeout.
- A single canonical append path.
- A deterministic reconstruction algorithm enforced by validators.
- Event-driven lifecycle state transitions.
- Evidence snapshot/hash relationship between `state/control` and
  `state/evidence`.
- Support-target admission checks requiring journal proof.
- Negative tests for generated authority, side-effect bypass, and replay abuse.

## Why this preserves Octon's constitutional identity

The proposal does not move authority into the runtime. It makes the runtime prove
that it is obeying authority. The Constitutional Engineering Harness retains the
rules; the Governed Agent Runtime records and reconstructs execution under those
rules.
