# Child Packet Contract

## Purpose

Define the parent-to-child authority and context contract for this proposal program.

## Child-Owned Truth

Each child owns its own `proposal.yml`, `architecture-proposal.yml`, implementation-grade completeness review, implementation prompt, conformance and drift/churn receipts after implementation, validation evidence, promotion evidence, rollback posture, archive evidence, and closeout evidence.

Parent summaries, spines, ledgers, or capsules may reference child evidence but must not satisfy child-owned gates.

## Parent-To-Child Handoff

The parent may provide a compact handoff capsule containing parent objective capsule, child-specific scope, source lineage digest, parent contract digest, dependency vector, target write-scope map, validator matrix, evidence refs, and context-pack hash.

The child must fail closed if the capsule is stale, unverifiable, or appears to widen authority.

## Required Child Fields

Every child packet must define durable promotion targets outside proposal workspace, target architecture, implementation plan, rollback posture, validators and evidence, acceptance criteria, closeout refusal criteria, support-proof preservation, context-pack inclusion defaults, model-routing default, and escalation triggers.

## Separate Governance Boundaries

The following child scopes must remain separate unless a future accepted architecture proposal explicitly changes the boundary: runtime workflow safety, closeout/change handoff governance, promotion evidence binding, archive observation and recovery, terminal integration tests, and authority-affecting architecture changes.

## Deterministic Preflight Candidates

The following may become deterministic gates or be collapsed into parent preflight when schema, validation, and evidence receipts exist: publication freshness, generated registry freshness, run-health manifest generation, blocker aggregation when blocker count is zero, dependency satisfaction vector, child manifest completeness, proposal registry projection validation, stdout/stderr indexing, closeout receipt schema validation, worktree cleanliness classification, and parent-review-churn digest detection.
