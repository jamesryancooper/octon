# Current-State Gap Map

| Current surface | Current coverage | Gap | Required change |
|---|---|---|---|
| `run-lifecycle-v1.md` | Defines normative states, canonical files, transition rules, and closeout requirements. | Needs executable transition validator, state reconstruction, and negative tests. | Implement transition gate and validator suite. |
| `run-journal-v1.md` | Defines canonical append-only journal and runtime_bus sole append path. | Needs lifecycle-state reconstruction and runtime-state drift detection as a first-class validator. | Add reconstruction contract and assurance test. |
| `runtime-event-v1.schema.json` | Compatibility-only envelope; dot events normalized before canonical journal. | Existing compatibility events cannot be lifecycle authority. | Ensure lifecycle transition gate emits/consumes canonical hyphenated run-event-v2 events only. |
| `authorized-effect-token-v1.md` | Defines typed effect tokens and `VerifiedEffect` requirement. | Needs lifecycle gating to ensure token consumption only occurs in valid `running` posture. | Make effect verification state-aware. |
| `context-pack-builder-v1.md` | Defines deterministic context evidence and authorization validation. | Needs lifecycle gating around context binding, rebuild, compaction, invalidation, and resume. | Bind context lifecycle events to `bound`, `authorized`, `paused`, and `running` transitions. |
| `evidence-store-v1.md` | Defines minimum consequential run evidence and closeout snapshot rule. | Needs closeout gate to verify evidence completeness before `closed`. | Add closeout validator and close command enforcement. |
| Runtime README | Documents run-first CLI and canonical run roots. | Needs CLI behavior to be tied to lifecycle transition gate. | Route run commands through lifecycle validator. |
| `support-targets.yml` | Requires admitted repo-consequential tuples to prove Run Journal conformance and deterministic state reconstruction. | Needs executable state-reconstruction proof. | Add support-target proof hook and retained assurance evidence. |
| Assurance README | Defines structural, functional, behavioral, governance, recovery, evaluator proof planes. | Needs lifecycle-specific runtime validator and regression fixtures. | Add `validate-run-lifecycle-v1.sh` and tests. |
| Operator read models | May summarize lifecycle state. | Need explicit refresh/drift semantics when lifecycle changes. | Regenerate read models from journal-derived state only. |

## Blocking factors

1. Lifecycle states are authored but not yet necessarily enforced as the sole runtime path.
2. Runtime-state materialization may exist, but the packet requires deterministic reconstruction proof and mismatch handling.
3. CLI/operator actions need explicit mapping to lifecycle transitions.
4. Closeout criteria need blocking validation, not just documentation.
5. Assurance needs negative tests for illegal transitions and direct state mutation drift.
