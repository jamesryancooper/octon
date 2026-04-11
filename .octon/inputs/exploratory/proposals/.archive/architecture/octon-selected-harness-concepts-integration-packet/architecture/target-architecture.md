# Target architecture

## Target state summary

The target state is **not** a new harness subsystem. The target state is a sharper, more explicit version of the live Octon architecture in which:

1. existing cognition/ingress/context indexing remains the canonical progressive-disclosure surface;
2. mission/run control remains the sole live control plane;
3. evidence/disclosure remains the sole retained proof plane;
4. structured review, failure hardening, adapter output compaction, evidence distillation, and proposal-first mission classification are added as **extensions of current surfaces**, not as new architectural roots.

## Architecture shape after promotion

### Already-covered surfaces retained as-is

- Progressive-disclosure context map stays in existing ingress + cognition/context roots.
- Reversible work-item state machine stays in mission/run objective + control/continuity roots.
- Evidence bundles and disclosure stay in evidence/disclosure/generated read-model roots.

### Refined surfaces

#### 1. Assurance review refinement
- Add `review-finding` and `review-disposition` contracts.
- Materialize active disposition state in run control.
- Keep raw findings in run evidence.
- Let progression validators read only canonical dispositions, not free-form comments.

#### 2. Failure-to-hardening refinement
- Add a canonical failure-class model and hardening recommendation model.
- Keep raw failures as retained evidence.
- Add a repo-specific distillation workflow contract that turns repeated failures into proposal-gated hardening candidates.
- Promote accepted hardenings into existing authority surfaces (policies, contracts, skills, context), never into runtime from raw evidence directly.

#### 3. Adapter/output refinement
- Keep native-first adapter posture.
- Add a compact output envelope contract plus repo-specific budget profile.
- Offload full raw payloads to retained evidence while exposing concise machine-usable envelopes to the agent/runtime.

#### 4. Evidence distillation refinement
- Add a governed distillation bundle contract and workflow.
- Read retained evidence, cluster recurring patterns, and emit proposal-ready recommendations.
- Allow optional generated summaries, but never treat them as authority.

#### 5. Mission classification refinement
- Extend current mission-autonomy policy rather than replacing it.
- Add per-mission classification control records for ambiguity/novelty/proposal requirements.
- Fail closed when proposal-first classes lack proposal references.

## Target control/evidence split

| Need | Canonical surface |
|---|---|
| Durable policy/contract meaning | `framework/**` and `instance/**` |
| Live blocking review disposition | `state/control/execution/runs/**` |
| Live per-mission classification | `state/control/execution/missions/**` |
| Failure/distillation bundles | `state/evidence/validation/**` |
| Review findings | `state/evidence/runs/**/assurance/**` |
| Compact human-readable summaries | `generated/cognition/**` or `generated/effective/**`, derived only |

## What the target architecture explicitly avoids

- no second mission control plane
- no proposal-local truth
- no chat/session/comment truth
- no shadow memory or self-modifying authority from raw logs
- no net-new top-level architectural categories
