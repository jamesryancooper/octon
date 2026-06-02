# Implementation Plan

## Program Roadmap

This parent coordinates six phases. Each phase is implemented by one or more child packets listed in `resources/child-packet-index.yml`.

### Phase 0 — Measurement And Token Ledger

Child: `token-efficiency-token-measurement-ledger`

Implement `token-budget-ledger.json`, source-token accounting, repeated-source accounting, prompt/context/completion/tool-output split, provider usage capture when available, lifecycle/parent/child/stage/source/model accounting, baseline measurement scripts, and CI token regression fixtures.

### Phase 1 — Quick Wins

Children: `token-efficiency-evidence-index-raw-log-summaries`, `token-efficiency-planner-state-program-context-capsule`.

Implement `evidence-index.yml`, raw-log summaries, failing-slice summaries, `planner-state.yml`, `program-context-capsule.yml`, compact completion capsule, concise closeout projection reader preference, and evidence-index reader preference over raw logs.

### Phase 2 — Context Pack And Instruction Capsules

Children: `token-efficiency-prompt-pack-instruction-capsules`, `token-efficiency-lifecycle-context-pack-integration`, `token-efficiency-proposal-artifact-index-spine`.

Implement prompt-pack handles, route capsules, compiled governance capsules, retained full prompt packet refs, prompt expansion policy, lifecycle executor context-pack-backed prompts, stage-specific context-pack policy, source manifests, omission manifests, hash-bound invalidation, proposal artifact index, and proposal spine.

### Phase 3 — Structured Evidence And Output

Children: `token-efficiency-blocker-ledger-recovery-deltas`, `token-efficiency-validator-manifests-generated-freshness`, `token-efficiency-structured-receipts-concise-publication`.

Implement `blocker-ledger.yml`, recovery delta summaries, validator result manifests, generated freshness manifests, publication freshness handles, structured receipt schemas/templates, concise closeout projections, concise final reports, and expanded on-demand reports.

### Phase 4 — Routing And Child-Loop Changes

Child: `token-efficiency-model-routing-action-slice-budgets`.

Implement model-routing policy, token ceilings, route decision receipts, deterministic preflights, action-slice loops, high-reasoning escalation triggers, failure fallback behavior, parent-review-churn deterministic preflight, publication-freshness deterministic gate, and aggregate-terminal-blockers deterministic aggregator.

### Phase 5 — Mature Architecture

Children: `token-efficiency-repo-authority-write-scope-index`, `token-efficiency-semantic-cache-context-reuse`.

Implement proposal semantic cache, source-hash invalidation, context-pack layer reuse, generated graph/index reuse, repo authority graph, promotion-target/write-scope graph, lifecycle-level token budgets, CI token regression tests, and support-proof-preserving evidence compression.

## Implementation Sequence

1. Land additive measurement and evidence indexes.
2. Route planner/recovery to compact state while retaining full audit plan and raw logs.
3. Add schema validation and negative controls for compact artifacts.
4. Add prompt-pack handle mode behind a fail-closed feature/policy gate.
5. Bind lifecycle executor prompts to Context Pack Builder inclusion semantics.
6. Add deterministic model-routing receipts and action-slice loops.
7. Add generated graph/index reuse and semantic cache only after invalidation tests pass.

## Repository Placement

Durable code/spec/policy changes belong under declared promotion targets in `proposal.yml` and child packets. Generated/read-model outputs must be produced by durable scripts/specs and must not be treated as promotion targets or canonical source of truth.

## Implementation Constraints

Keep full evidence retained. Preserve child-owned receipts, exact model-visible context hashes, engine-owned authorization, and fail-closed behavior on stale capsules, stale generated handles, missing receipts, missing rollback evidence, missing context-pack hash, missing authorization receipt, model-route bypass, raw-log summary mismatch, or blocker fingerprint drift.
