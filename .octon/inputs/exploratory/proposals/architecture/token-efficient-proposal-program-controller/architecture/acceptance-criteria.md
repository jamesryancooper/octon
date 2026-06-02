# Acceptance Criteria

## Token Efficiency Metrics

Minimal target:

- total tokens per parent lifecycle run reduced by at least 30-50%;
- tokens per child run reduced by at least 25-40%;
- repeated-context percentage reduced by at least 50%;
- prompt boilerplate share below 25% of model-visible context;
- raw-log rereads avoided by default;
- generated tree rereads avoided by default;
- full prompt asset expansion avoided by default;
- `program-plan.yml` model-visible use replaced by `planner-state.yml` for ordinary planning;
- closeout receipt consumption replaced by concise closeout projection.

Mature target:

- total tokens per repeated proposal-program run reduced by 60-80%;
- repeated context reduced by at least 75%;
- prompt boilerplate share below 10-15%;
- high-reasoning calls reduced and justified by routing receipts;
- context-pack layer reuse verified by retained hashes;
- semantic cache hits produce ≤2k additional model-visible context overhead.

## Governance Criteria

- Evidence completeness preserved.
- Replay completeness preserved.
- Rollback posture preserved.
- Source-hash invalidation works.
- Stale prompt capsules fail closed.
- Stale generated handles fail closed.
- Missing child receipts block parent completion.
- Invalid context pack blocks authorization.
- Missing authorization receipt blocks material execution.
- Raw input and generated artifacts never become authority.
- Child authority boundary preserved.
- Archive and closeout correctness preserved.

## Required Negative Controls

- stale prompt capsule;
- stale generated freshness handle;
- raw proposal input accidentally treated as authority;
- generated registry replacing proposal manifest;
- missing child receipt;
- missing rollback evidence;
- missing context-pack hash;
- missing authorization receipt;
- model route bypass attempt;
- raw-log summary mismatch;
- blocker fingerprint drift.

## Completion Criteria

This program is complete only when each child packet has passing implementation-grade completeness review, concrete durable promotion targets, validator list, evidence and rollback plan, support-proof preservation statement, closeout refusal criteria, and post-implementation conformance/drift-churn gate requirements.
