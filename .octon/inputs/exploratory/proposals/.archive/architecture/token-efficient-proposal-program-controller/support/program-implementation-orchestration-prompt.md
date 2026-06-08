# Program Implementation Orchestration Prompt

prompt_id: token-efficient-proposal-program-controller-implementation-orchestration-prompt
generator: octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt
program_packet_path: .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller
verdict: ready-for-program-implementation-orchestration

This prompt runs the accepted `token-efficient-proposal-program-controller`
proposal program. It is an orchestration prompt for implementation of the
program and its child packets. It is not a promotion receipt, child receipt,
runtime authority, or evidence that implementation has completed.

## Role

Act as the single accountable Octon orchestrator and runtime engineer for a
proposal-program implementation run.

Operate under:

- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`

## Mandatory Gate Revalidation

Before planning or editing, run both gates against the parent package:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller
```

Continue only when both gates return `errors=0 warnings=0`.

Refuse implementation orchestration if either gate fails, if a review digest is
stale, if clarification is required, if any required non-deferred child packet
is blocked, if child metadata is missing, or if predecessor/cutover constraints
are incoherent.

## Objective

Implement the accepted Token-Efficient Proposal Program Controller by
sequencing the required child packets in `gated-parallel` mode while preserving:

- engine-owned authorization boundaries;
- child-owned implementation authority and receipts;
- proposal input non-authority;
- generated/read-model non-authority;
- retained evidence completeness;
- replayability of exact model-visible context;
- rollback posture;
- support-proof preservation;
- validation and negative-control coverage.

Token efficiency must be achieved by reducing model-visible context through
digest-bound, evidence-preserving indirection. Do not delete, hide, or weaken
required evidence.

## Profile Selection Receipt

Before implementation, emit a receipt in the run notes:

```yaml
profile_selection_receipt:
  release_state: pre-1.0
  selected_change_profile: atomic
  rationale: Parent and all required child packets declare pre-1.0 atomic implementation. No transitional exception is authorized by this prompt.
  transitional_exception_note: none
```

## Parent Package Read Set

Read the parent files in this order:

1. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/proposal.yml`
2. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture-proposal.yml`
3. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/resources/child-packet-index.yml`
4. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/packet-sequence.md`
5. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/child-packet-contract.md`
6. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/target-architecture.md`
7. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/implementation-plan.md`
8. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/context-pack-policy.md`
9. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/model-routing-policy.md`
10. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/token-budget-policy.md`
11. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/evidence-and-replay-model.md`
12. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/acceptance-criteria.md`
13. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/architecture/rollback-posture.md`
14. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/validation-plan.md`
15. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/navigation/source-of-truth-map.md`
16. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/support/proposal-review.md`
17. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/support/implementation-grade-completeness-review.md`

For each child, read the child `proposal.yml`, `architecture-proposal.yml`,
`support/proposal-review.md`, `support/implementation-grade-completeness-review.md`,
`support/executable-implementation-prompt.md`, and the child architecture files
needed for its declared target.

## Child Program Sequence

Use `resources/child-packet-index.yml` and `architecture/packet-sequence.md` as
the sequencing contract. Dependent children wait for dependency implementation,
conformance, drift verification, retained evidence, rollback posture, and
relevant receipts. Proposal acceptance alone is not a dependency-satisfaction
gate.

### Phase 0

- `token-efficiency-token-measurement-ledger`

### Phase 1

- `token-efficiency-evidence-index-raw-log-summaries`
- `token-efficiency-planner-state-program-context-capsule`

### Phase 2

- `token-efficiency-prompt-pack-instruction-capsules`
- `token-efficiency-lifecycle-context-pack-integration`
- `token-efficiency-proposal-artifact-index-spine`

### Phase 3

- `token-efficiency-blocker-ledger-recovery-deltas`
- `token-efficiency-validator-manifests-generated-freshness`
- `token-efficiency-structured-receipts-concise-publication`

### Phase 4

- `token-efficiency-model-routing-action-slice-budgets`

### Phase 5

- `token-efficiency-repo-authority-write-scope-index`
- `token-efficiency-semantic-cache-context-reuse`

## Child Authority Boundary

Each child owns its own:

- durable promotion targets;
- implementation plan;
- validators;
- evidence requirements;
- rollback posture;
- `support/implementation-conformance-review.md`;
- `support/post-implementation-drift-churn-review.md`;
- closeout and archive evidence.

Parent summaries, ledgers, capsules, spines, or orchestration receipts may
summarize child outcomes but must not satisfy child receipts, child promotion
targets, child validation verdicts, child archive metadata, or child rollback
evidence.

Fail closed if a parent handoff capsule is stale, unverifiable, or appears to
widen child authority.

## Promotion Envelope

Write durable implementation only inside the parent and child manifest promotion
targets. Parent-level approved targets include:

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/cognition/_meta/architecture/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`
- `.octon/instance/governance/policies/context-packing.yml`
- `.octon/instance/governance/policies/model-routing.yml`
- `.octon/instance/governance/policies/token-budgets.yml`

Generated proposal registry outputs under `.octon/generated/proposals/` are
affected read-model artifacts only. They are not promotion targets and must not
be treated as authority.

## Implementation Loop

For each phase:

1. Confirm all dependency gates for the child are satisfied.
2. Run the child review gate with implementation authorization before child
   implementation.
3. Run child packet standard and architecture validators before editing.
4. Produce a minimal implementation plan for the child, including impact map,
   evidence plan, validation plan, rollback plan, and dependency receipt.
5. Search existing runtime specs, validators, policies, scripts, skills, and
   crates before creating any new surface.
6. Implement the smallest robust durable change that satisfies the child.
7. Add or update validators, tests, schemas, fixtures, specs, and policies in
   the same change slice when behavior or authority boundaries change.
8. Run targeted validation plus any parent-level validators affected by the
   change.
9. Produce child `support/implementation-conformance-review.md`.
10. Produce child `support/post-implementation-drift-churn-review.md`.
11. Re-check child rollback posture and retained evidence refs before allowing
    downstream children to proceed.

Do not close out a child, start dependent work, or mark parent progress complete
until the child conformance and drift/churn reviews pass.

## Context And Token Discipline

Use the parent context-pack policy:

- proposal manifests are lifecycle sources, not authority;
- raw logs are retained evidence and handle-only by default;
- generated/read-model artifacts are digest-only or selected-entry by default;
- full prompt assets are expanded only under explicit policy triggers;
- compact artifacts must retain source refs, omission records, invalidation
  state, model-visible serialization, and hashes;
- authorization fails closed on missing, stale, invalid, or unverifiable required
  context.

Use the parent model-routing policy:

- deterministic parsing, indexing, hashing, graphing, schema checks, and
  validator execution before model reasoning;
- small/medium models only for summaries, ordinary classification, or failure
  explanation;
- high-reasoning only for architecture, authority, safety, rollback,
  support-proof, promotion, archive/recovery, or unexplained failure reasoning;
- every model-route escalation requires a route-decision receipt;
- missing required evidence, stale capsules, stale generated handles, authority
  ambiguity, or model-route bypass attempts fail closed.

Track lifecycle, parent, child, stage, source, model, prompt, context,
completion, tool-output, repeated-context, prompt-boilerplate, generated-reread,
raw-log-reread, and high-reasoning-call accounting as proposed in
`architecture/token-budget-policy.md`.

## Required Evidence

Retain or cite evidence for:

- context-pack receipt;
- model-visible context JSON and hash;
- source manifest;
- omission manifest;
- invalidation events;
- authorization decision and grant refs;
- execution receipts;
- evidence index;
- token-budget ledger;
- raw stdout/stderr refs;
- validator result manifests;
- generated freshness handles;
- route-decision receipts;
- model-routing receipts;
- rollback refs;
- closeout receipts and concise closeout projections;
- disclosure or RunCard refs when required;
- child conformance and drift/churn reviews.

Compact evidence artifacts are projections over retained evidence. They cannot
authorize execution and cannot replace raw evidence.

## Validation Floor

Run the minimum credible validation needed for each child plus impacted parent
surfaces. The program validation floor includes:

- parent proposal review gate;
- parent program child-readiness gate;
- child proposal review gates;
- proposal standard validators for parent and children;
- architecture proposal validators for parent and children;
- lifecycle runner tests;
- lifecycle interaction receipt tests;
- context-pack builder tests;
- publication freshness gate tests;
- run-health read-model tests;
- closeout worktree wrapper tests;
- closeout-change lifecycle alignment validation;
- proposal registry validation;
- generated freshness validation;
- schema validation for every new compact artifact;
- replay validation;
- rollback validation;
- CI token regression checks where implemented.

New or updated validators must cover prompt-pack capsule generation, stale
capsule fail-closed behavior, evidence index generation, raw-log summary hash
matching, failing-slice reconstruction, planner-state reconstruction,
program-context capsule digest verification, blocker-ledger fingerprinting,
validator-result manifest generation, generated freshness handle validation,
model-routing receipt emission, token-budget ledger accounting,
context-pack omission manifests, child-handoff capsule correctness, and a
proposal-program mock run as applicable to implemented children.

## Required Negative Controls

Preserve or add negative controls for:

- stale prompt capsule;
- stale generated freshness handle;
- raw proposal input treated as authority;
- generated registry replacing proposal manifest;
- missing child receipt;
- missing rollback evidence;
- missing context-pack hash;
- missing authorization receipt;
- model route bypass attempt;
- raw-log summary mismatch;
- blocker fingerprint drift.

## Closeout Refusal Criteria

Refuse successful parent or child closeout if any of the following remain:

- stale prompt capsule;
- stale generated freshness handle;
- missing child receipt;
- missing rollback evidence;
- missing context-pack hash;
- missing authorization receipt;
- raw proposal input treated as authority;
- generated artifact treated as source of truth;
- model route bypass detected;
- raw-log summary mismatch;
- blocker fingerprint drift;
- generated/read-model projection stale;
- child `support/implementation-conformance-review.md` missing or failing;
- child `support/post-implementation-drift-churn-review.md` missing or failing;
- parent-local `support/program-implementation-orchestration-run.md` missing.

## Parent Orchestration Run Receipt

After implementation orchestration, create or update:

`/.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/support/program-implementation-orchestration-run.md`

The receipt must include at minimum:

```yaml
verdict: pass | blocked | fail
implemented_at: <RFC3339 timestamp or n/a when blocked before implementation>
promotion_evidence_count: <integer>
child_authority_preserved: yes | no
```

It must also summarize:

- gate commands and outcomes;
- child packets implemented;
- child packets blocked or deferred;
- child conformance review refs;
- child drift/churn review refs;
- promotion targets changed;
- validation commands and outcomes;
- negative controls exercised;
- retained evidence refs;
- rollback refs;
- token-efficiency evidence;
- generated/read-model outputs refreshed or intentionally not refreshed;
- cleanup pass result;
- remaining blockers or `none`.

The parent orchestration receipt may summarize child outcomes only. It never
satisfies child receipts, child promotion evidence, child validation verdicts,
child archive metadata, child rollback evidence, or generated freshness
receipts.

## Final Response Contract

Report structured receipts before prose:

1. Profile Selection Receipt.
2. Repository Reconnaissance Receipt.
3. Implementation Plan and Impact Map.
4. Child Execution Matrix.
5. Validation Evidence Receipt.
6. Minimality / Anti-Bloat Receipt.
7. Cleanup Pass Receipt.
8. Exceptions and Escalations.
9. Parent Orchestration Run Receipt path and verdict.

Keep the human narrative concise. State what was implemented, what validation
ran, what evidence was retained, what remains blocked, and whether child
authority was preserved.
