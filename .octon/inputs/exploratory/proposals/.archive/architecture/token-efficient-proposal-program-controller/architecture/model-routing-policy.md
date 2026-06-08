# Model Routing Policy

## Principle

Routing reduces cost only after deterministic gates, evidence preservation, authorization, replay, rollback, and support proof are preserved. Model routing cannot widen authority or bypass gates.

## Categories

- `deterministic`: no LLM; parser, hasher, validator, indexer, graph builder, or schema checker.
- `small-model`: short classification or operator-facing concise summary.
- `medium-model`: ordinary completeness, conformance, failure explanation, or non-authority summary.
- `high-reasoning`: architecture, authority, safety, rollback, support-proof, promotion, archive/recovery, or unexplained failure reasoning.
- `high-reasoning-on-escalation`: deterministic/medium default with high-reasoning only under specified triggers.

## Stage Matrix

| Stage / Child Type | Default Route | Token Ceiling | Escalation Trigger | Evidence Receipt |
|---|---|---:|---|---|
| proposal manifest validation | deterministic | 0 | schema ambiguity | validator-result-manifest |
| parent spine generation | deterministic | 0 | inconsistent manifests | proposal-program-spine receipt |
| child registry parsing | deterministic | 0 | invalid dependencies | child registry validation receipt |
| terminal gap mapping | high-reasoning | 40k | architecture conflict | gap-map receipt |
| workflow retry ID safety | medium/high | 30k | runtime safety ambiguity | implementation receipt |
| change handoff checkpoint design | medium/high | 25k | authorization/cleanup ambiguity | handoff receipt |
| aggregate terminal blockers | deterministic/small | 2k zero-state; 8k nonzero | blocker conflict | blocker-ledger receipt |
| promotion evidence binding | high-reasoning-on-escalation | 30k | evidence ownership conflict | promotion-binding receipt |
| publication freshness | deterministic | 0-3k | stale handle | publication-freshness-manifest |
| parent review churn | deterministic/small | 2k-8k | semantic drift despite stable digest | churn receipt |
| archive observation recovery | deterministic; high on failure | 30k | recovery conflict | archive-recovery receipt |
| terminal routing tests | deterministic; medium on failure | 8k | unexplained test failure | test manifest |
| final parent completion | deterministic/small | 8k | missing child evidence | completion capsule |
| closeout summary | small/medium | 10k | cleanup authorization ambiguity | closeout projection |
| raw log indexing | deterministic | 0 | summary hash mismatch | raw-log-summary |
| validator failure classification | medium | 8k | authority/rollback impact | validator-result-manifest |
| generated freshness classification | deterministic | 0 | stale generated handle | generated freshness receipt |
| proposal artifact indexing | deterministic | 0 | manifest mismatch | artifact-index receipt |
| repo authority graph generation | deterministic/medium | 6k ambiguity report | source-of-truth ambiguity | repo-authority-graph receipt |

## Fallback Behavior

- Missing required evidence: fail closed.
- Stale capsule or generated handle: rebuild if permitted; otherwise fail closed.
- Lower-tier model uncertainty: escalate with route-decision receipt.
- Authority ambiguity: high-reasoning or human governance review.
- Model route bypass attempt: deny and retain denial receipt.
