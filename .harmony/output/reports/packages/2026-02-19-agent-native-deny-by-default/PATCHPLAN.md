# PATCHPLAN

## Scope

Implement full **agent-native deny-by-default** for Harmony so agents can move fast on low-risk work while high-risk actions remain deterministic, auditable, and fail-closed.

Program root assumptions:

- Repository root: `/Users/jamesryancooper/Projects/harmony`
- Capability roots:
  - `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/`
  - `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/skills/`
  - `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/`

## Outcomes

1. One policy decision engine for runtime and validation.
2. Preflight-first execution with machine-remediable deny diagnostics.
3. Ephemeral least-privilege grants for routine agent work.
4. Tiered controls for medium/high risk without human bottlenecks for low risk.
5. Scoped, expiring kill-switches with explicit owner/reason metadata.
6. Friction SLOs and observability that prevent policy regressions.

## Non-Goals

1. Do not remove deny-by-default.
2. Do not introduce fail-open fallbacks.
3. Do not replace all existing scripts in one cutover; use staged migration.

## Delivery Strategy

Use phased migration with strict backward compatibility:

1. Stabilize current path and remove known false-deny causes.
2. Introduce policy contract v2 and shared engine in parallel.
3. Migrate validators and runtime wrappers to shared engine.
4. Add agent-native grant broker and preflight loop.
5. Roll out with shadow mode -> soft enforce -> hard enforce.

## Locked Decisions

1. Policy enforcement remains mandatory deny-by-default.
2. Low-risk automation is optimized via auto-grants, not broad permanent permissions.
3. Runtime and validation use one decision engine implementation.
4. Agent-only mode keeps separation-of-duties and quorum controls for high risk.
5. Kill-switches must be scoped and expiring.
6. CI/release remains strict hard-enforce.

## Phase Plan

## Phase 0 - Stabilize Existing Runtime Guard

Goal: Remove current false-deny behavior and make shell runtime guard predictable under `set -euo pipefail` entrypoints.

Tasks:

1. Replace `errexit`-sensitive arithmetic in token split/parser logic.
2. Add regression tests for `Bash(...)` and `Write(...)` parsing with nested/space tokens.
3. Add active shell service smoke suite that verifies valid scoped permissions never deny.
4. Add focused tests for known failure signatures and required deny conditions.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/scripts/validate-services.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh`

Validation:

- `bash -n` on modified scripts
- `.harmony/capabilities/services/_ops/scripts/validate-services.sh --profile strict`
- `.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict`
- Runtime smoke test over all active shell entrypoints

Exit criteria:

- No false denies for valid `Bash(...)` scopes in active shell services.
- Strict validators pass with zero errors.

## Phase 1 - Define Policy Contract v2

Goal: Establish a canonical machine contract used by all deny decisions.

Tasks:

1. Create v2 policy schema with explicit reason-code taxonomy.
2. Define grant schema (subject, scope, permissions, ttl, provenance, risk tier).
3. Define kill-switch schema (scope, owner, reason, created, expires, state).
4. Define stable deny reason codes and remediation hints.
5. Publish migration notes from current YAML policy artifacts.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/deny-by-default.v2.schema.json`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/deny-by-default.v2.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/reason-codes.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/migration-v1-to-v2.md`

Validation:

- Schema validation script for v2 policy files
- Backward compatibility check that existing policy semantics map deterministically

Exit criteria:

- v2 schema accepted and validated in CI.
- Reason codes frozen and referenced by validators/runtime.

## Phase 2 - Build Shared Policy Engine

Goal: Replace duplicated policy logic with a single execution path.

Tasks:

1. Implement shared policy engine crate with deterministic evaluation.
2. Implement CLI commands:
   - `policy preflight`
   - `policy enforce`
   - `policy grant-eval`
   - `policy doctor`
3. Add fixtures and golden tests for allow/deny parity.
4. Add compatibility adapter that reads current manifests and `SERVICE.md`/`SKILL.md` declarations.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/Cargo.toml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/src/lib.rs`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/src/bin/policy.rs`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/tests/`

Validation:

- Unit tests + fixture tests for all reason codes.
- Snapshot/golden tests for runtime-vs-validator parity.

Exit criteria:

- Same input context yields identical allow/deny across runtime and validator paths.

## Phase 3 - Migrate Validators and Runtime Wrappers

Goal: Make scripts thin orchestrators calling the shared engine.

Tasks:

1. Refactor service validator to call `policy preflight`/`policy enforce` instead of local parsing.
2. Refactor skill validator to call the same decision path for permission checks.
3. Refactor runtime shell wrapper to delegate decision to shared engine.
4. Keep legacy checks behind temporary fallback flag for one rollout window only.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/scripts/validate-services.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/skills/_ops/scripts/validate-skills.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh`

Validation:

- Full strict runs for services/skills.
- Parity tests against old catalogs before removing fallback.

Exit criteria:

- No duplicated decision parser remains in script layer.
- Cross-lane strict validation remains green.

## Phase 4 - Agent-Native Preflight and Auto-Remediation

Goal: Agents self-resolve most low-risk denies in one loop.

Tasks:

1. Add preflight call before execution in agent runtime path.
2. Return structured deny payload: `code`, `missing_scope`, `expected_token`, `remediation_hint`.
3. Add auto-remediation loop for low-risk denies:
   - synthesize minimal additional scope
   - re-run preflight
   - continue on allow
4. Add retry guardrails (max attempts, no silent scope widening).

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/execution/agent/impl/agent.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/execution/agent/SERVICE.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/reason-codes.md`

Validation:

- Integration tests for agent loop: deny -> remediate -> allow.
- Negative tests for forbidden widening.

Exit criteria:

- Majority of low-risk denies auto-remediated without human intervention.

## Phase 5 - Ephemeral Grant Broker

Goal: Remove manual permission churn for routine work while preserving bounded privilege.

Tasks:

1. Implement grant broker with deterministic policy evaluation.
2. Create grant lifecycle commands: create, inspect, renew, revoke, expire sweep.
3. Enforce default TTL and scope minimization.
4. Add provenance fields (`request_id`, `agent_id`, `plan_step_id`, `reason_code`).
5. Restrict medium/high grants by policy tier requirements.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-grant-broker.sh` or Rust CLI equivalent
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/state/grants/`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/deny-by-default.v2.yml`

Validation:

- TTL expiry tests.
- No-grant persistence beyond expiry.
- Medium/high rejection without required review/quorum evidence.

Exit criteria:

- Low-risk workflow uses ephemeral grants by default.
- Grant audit trail is complete and queryable.

## Phase 6 - Kill-Switch Redesign

Goal: Replace opaque flag behavior with explicit, scoped operational controls.

Tasks:

1. Replace single flag with scoped records (`global`, `service:<id>`, `category:<id>`).
2. Require owner, reason, created, expires, and optional incident id.
3. Add commands: `set`, `status`, `clear`, `sweep-expired`.
4. Maintain backward compatibility with existing kill-switch path during migration.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/agent-only-governance.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/state/kill-switches/`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/validate-agent-only-governance.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-kill-switch.sh`

Validation:

- Scoped disable tests by service/category/global.
- Expiry and stale-detection tests.

Exit criteria:

- No manual `rm` required for normal operations.
- Stale switches detected and reported automatically.

## Phase 7 - Golden Path Permission Profiles

Goal: Make common agent workflows one-command policy selections.

Tasks:

1. Define profile templates:
   - `refactor`
   - `scaffold`
   - `tests`
   - `docs`
   - `release-readiness`
2. Map profiles to minimal scoped permission bundles.
3. Add profile resolver in preflight path.
4. Add policy lint rule that blocks broad profile drift.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/profiles/*.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-profile-resolve.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/README.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/skills/README.md`

Validation:

- Profile expansion tests.
- Least-privilege drift tests.

Exit criteria:

- Most agent operations run via profile selection instead of custom permission tuning.

## Phase 8 - Observability, SLOs, and Rollout

Goal: Turn deny-by-default into an operationally managed control plane.

Tasks:

1. Emit structured decision logs with reason codes and remediation path.
2. Track friction SLOs:
   - false-deny rate
   - median deny-to-unblock time
   - auto-remediation success rate
3. Build rollout modes:
   - shadow mode
   - soft enforce
   - hard enforce (CI/release)
4. Add release gates based on friction and safety SLO thresholds.

Primary files:

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/state/logs/deny-by-default-decisions.jsonl`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-rollout-mode.sh`
- `/Users/jamesryancooper/Projects/harmony/.github/workflows/*` (policy gate integration)

Validation:

- Rollout mode integration tests.
- CI gate tests for strict mode.

Exit criteria:

- Hard-enforce stable in CI/release with tracked low-friction metrics.

## Dependency Order

1. Phase 0
2. Phase 1
3. Phase 2
4. Phase 3
5. Phase 4 and Phase 5
6. Phase 6
7. Phase 7
8. Phase 8

## Risk Controls

1. Keep one compatibility window between parser migration and fallback removal.
2. Run shadow mode before hard enforce for each lane.
3. Require parity reports when replacing existing logic.
4. Use feature flags for each phase-level runtime behavior change.
5. Keep rollback plan IDs mandatory for medium/high tier execution.

## Friction SLO Targets

1. False-deny rate: `< 0.5%` of total policy decisions.
2. Median deny-to-unblock: `< 60s` for low-risk workflows.
3. Auto-remediation success: `>= 90%` for low-risk denies.
4. Stale kill-switch count: `0` in strict CI.
5. Expired exception/grant count: `0` in strict CI.

## Acceptance Criteria

1. Runtime and validation decisions are parity-tested from one engine.
2. Active shell service runtime path has no known false-deny regression.
3. Low-risk agent workflows run with auto-grants and no manual approvals.
4. Medium/high workflows enforce review/quorum/rollback requirements.
5. Kill-switch controls are scoped, expiring, and observable.
6. CI strict gates and local dev-fast profiles both pass on representative changes.

## Execution Checklist

- [x] Phase 0 implemented and validated
- [x] Phase 1 implemented and validated
- [x] Phase 2 implemented and validated
- [x] Phase 3 implemented and validated
- [x] Phase 4 implemented and validated
- [x] Phase 5 implemented and validated
- [x] Phase 6 implemented and validated
- [x] Phase 7 implemented and validated
- [x] Phase 8 implemented and validated
- [x] Final strict gate run passes locally (`validate-deny-by-default --all --profile strict`)
- [x] Post-rollout friction SLOs observed via `policy-rollout-mode.sh slo-report`

## Initial Implementation Slice (Recommended First PR)

1. Land Phase 0 + Phase 1 together.
2. Include regression tests for the current false-deny failure class.
3. Add reason-code contract and deny payload shape.
4. Keep all behavior backward compatible except the false-deny fix.

This establishes a stable base for engine migration without slowing current development.
