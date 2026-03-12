# FILES

Planned file map for full agent-native deny-by-default implementation.

## New Artifacts

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/deny-by-default.v2.schema.json`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/deny-by-default.v2.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/reason-codes.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/migration-v1-to-v2.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/Cargo.toml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/src/lib.rs`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/src/bin/policy.rs`
- `/Users/jamesryancooper/Projects/harmony/.harmony/runtime/crates/policy_engine/tests/`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-grant-broker.sh` (or Rust CLI replacement)
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-kill-switch.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-profile-resolve.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/policy-rollout-mode.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/run-harmony-policy.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/state/grants/`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/state/kill-switches/`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/profiles/refactor.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/profiles/scaffold.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/profiles/tests.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/profiles/docs.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/profiles/release-readiness.yml`

## Existing Files to Modify

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/scripts/validate-services.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/skills/_ops/scripts/validate-skills.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/scripts/validate-agent-only-governance.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/policy/agent-only-governance.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/execution/agent/impl/agent.sh`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/execution/agent/SERVICE.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/README.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/skills/README.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/README.md`
- `/Users/jamesryancooper/Projects/harmony/.github/workflows/` policy validation workflows

## Generated/Operational State

- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/services/_ops/state/deny-by-default-policy.catalog.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/skills/_ops/state/deny-by-default-policy.catalog.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/capabilities/_ops/state/logs/deny-by-default-decisions.jsonl`

## Report Package

- `/Users/jamesryancooper/Projects/harmony/.harmony/output/reports/packages/2026-02-19-agent-native-deny-by-default/PATCHPLAN.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/output/reports/packages/2026-02-19-agent-native-deny-by-default/FILES.md`
- `/Users/jamesryancooper/Projects/harmony/.github/workflows/deny-by-default-gates.yml`
