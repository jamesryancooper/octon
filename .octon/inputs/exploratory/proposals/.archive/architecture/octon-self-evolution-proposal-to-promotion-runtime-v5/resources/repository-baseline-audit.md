# Repository Baseline Audit

Repository grounding used by this packet:

- `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md` defines proposal packets as temporary, non-canonical artifacts under `/.octon/inputs/exploratory/proposals/**`; durable outputs must promote into long-lived `.octon/` or repo-native surfaces.
- `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` requires `architecture-proposal.yml`, `architecture/target-architecture.md`, `architecture/implementation-plan.md`, and `architecture/acceptance-criteria.md` for architecture proposals.
- `/.octon/framework/cognition/_meta/architecture/specification.md` defines the five-root authority model: `framework/**` and `instance/**` are authored authority; `state/control/**` is operational truth; `state/evidence/**` is retained proof; `state/continuity/**` is resumable context; `generated/**` is derived only; `inputs/**` is non-authoritative.
- `/.octon/instance/governance/contracts/evidence-distillation-workflow.yml` already declares evidence distillation as `proposal_gated`, `auto_promote: false`, and generated summaries as non-authoritative.
- `/.octon/framework/constitution/obligations/evidence.yml` already requires retained lab/replay/scenario/shadow-run evidence before consequential behavioral claims and requires promotion receipts for authority/control/runtime-facing generated-effective changes.
- `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` requires material execution through `authorize_execution(...)`, grant bundles, typed authorized effects, verified effect tokens, receipts, and run evidence.

## Baseline conclusion

The repository already prevents proposal packets, generated summaries, and evidence distillation from becoming authority. The gap is not conceptual awareness; it is the absence of a runtime/control pipeline that manages evidence-backed evolution through candidate, simulation, lab gate, proposal, decision, promotion, and recertification.
