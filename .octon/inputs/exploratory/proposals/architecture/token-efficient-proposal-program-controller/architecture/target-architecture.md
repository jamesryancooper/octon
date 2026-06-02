# Target Architecture

## Summary

Introduce a **Token-Efficient Proposal Program Controller** layered on Octon's existing governed runtime.

The controller does not replace the lifecycle engine, proposal standards, context-pack builder, authorization boundary, evidence store, generated/read-model rules, or child proposal lifecycle ownership. It adds compact, digest-bound, source-class-preserving runtime surfaces that reduce model-visible context while preserving replay and support proof.

## Architectural Components

### 1. Proposal Control Spine

A compact generated/read-model representation of proposal/program state.

Fields:

- `schema_version: octon-proposal-program-spine-v1`
- `proposal_id`
- `target`
- `status`
- `child_registry_digest`
- `source_lineage_digest`
- `promotion_target_digest`
- `authority_boundary`
- `child_status_table`
- `gate_states`
- `receipt_digests`
- `blockers`
- `evidence_refs`
- `context_pack_ref`
- `model_visible_context_sha256`
- `freshness`
- `invalidation_state`

Authority status: generated/read-model only. It must not replace `proposal.yml`, subtype manifests, state/control journals, retained evidence, or generated freshness validators.

### 2. Child Run Context Handoff

A `child-handoff-capsule.yml` carries compact parent-to-child state:

- parent objective capsule;
- child-specific scope;
- source lineage digest;
- parent contract digest;
- dependency vector;
- target write-scope map;
- validator matrix;
- evidence refs;
- current context-pack hash;
- omission manifest ref.

It prevents child runs from rereading full parent docs, sibling packets, raw logs, generated trees, or full prompt bundles by default.

### 3. Stage-Specific Context Packs

Proposal-program parent and child routes use context-pack policies with `full`, `excerpt`, `summary`, `handle-only`, `digest-only`, and `omitted` inclusion modes.

Every pack must retain source manifest, omission manifest, redaction manifest when applicable, invalidation events, token estimates, model-visible serialization, model-visible hash, and replay refs.

### 4. Compiled Instruction Capsules

Stable prompt assets become digest-bound capsules:

- `prompt-pack-capsule-v1`
- `route-instruction-capsule-v1`
- `compiled-governance-capsule-v1`
- `prompt-expansion-policy-v1`

Default model-visible prompt: route header, target, policy digest, prompt asset digests, short visible rules, expansion rules, retained full prompt packet refs, and model-visible context hash.

Full prompt text expands only on digest drift, mutation-sensitive work, gate dispute, authority conflict, support-proof ambiguity, or audit request.

### 5. Artifact Indexes And Graphs

Generated/read-model indexes:

- `proposal-artifact-index.yml`;
- `repo-authority-graph.yml`;
- `promotion-target-index.yml`;
- `write-scope-index.yml`;
- `validator-result-manifest.yml`;
- `publication-freshness-manifest.yml`.

These prevent repo re-learning and broad generated-state rereads.

### 6. Structured Evidence

Machine-readable evidence comes first: `evidence-index.yml`, `raw-log-summary.yml`, `failing-slice-manifest.yml`, `planner-state.yml`, `program-context-capsule.yml`, `blocker-ledger.yml`, `route-decision-receipt.yml`, `model-routing-receipt.yml`, `token-budget-ledger.json`, `closeout-projection.yml`, and `publication-summary.yml`.

Human-readable summaries are capped by default; expanded reports are generated only on demand from retained evidence.

### 7. Deterministic-First Routing

The controller classifies lifecycle work as deterministic, small-model, medium-model, high-reasoning, or high-reasoning-on-escalation.

High-reasoning is reserved for authority ambiguity, architecture decisions, rollback conflicts, support-proof interpretation, promotion evidence conflicts, archive/recovery failures, and unexplained test failures.

### 8. Cache Invalidation

Every compact artifact has hash-bound invalidation. Fail closed when stale or unverified: prompt capsules, proposal spines, semantic summaries, generated freshness handles, repo authority graphs, artifact indexes, context packs, and child handoff capsules.

## Child Boundary Policy

Separate child proposal boundaries remain mandatory for runtime workflow safety, closeout/change handoff governance, promotion evidence binding, archive observation and recovery, terminal integration tests, and authority-affecting architecture changes.

Deterministic preflight is preferred for publication freshness, generated registry freshness, run-health manifest generation, zero-blocker aggregation, dependency satisfaction vectors, child manifest completeness, proposal registry projection validation, stdout/stderr indexing, closeout receipt schema validation, worktree cleanliness classification, and parent-review-churn digest checks.

## Non-Goals

This architecture does not remove evidence, replace raw logs with summaries, make proposal inputs authoritative, make generated/read-model artifacts source of truth, let model routing bypass authorization, skip validators, silently rebuild invalid context packs, or weaken closeout/archive requirements.
