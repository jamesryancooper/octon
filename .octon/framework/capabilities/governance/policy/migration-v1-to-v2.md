# Deny-by-Default v1 -> v2 Migration Notes

This document maps existing deny-by-default artifacts to the canonical v2
policy contract.

## Goal

- Keep existing safety semantics intact.
- Remove parser/evaluator drift by centralizing decisions in `octon-policy`.
- Complete strict cutover to the v2 policy engine with no legacy fallback paths.

## Source Artifacts (v1)

- `.octon/state/control/capabilities/deny-by-default-exceptions.yml`
- `.octon/framework/capabilities/governance/policy/agent-only-governance.yml`
- Service and skill `allowed-tools` declarations in `SERVICE.md` / `SKILL.md`
- Shell runtime guard: `services/_ops/scripts/enforce-deny-by-default.sh`
- Validators: `services/_ops/scripts/validate-services.sh`,
  `skills/_ops/scripts/validate-skills.sh`

## Contract Mapping

| v1 Source | v2 Field |
|---|---|
| `agent_only.enabled` | `agent_only.enabled` |
| `risk_tiers.<tier>.min_distinct_agents` | `agent_only.risk_tiers.<tier>.min_distinct_agents` |
| `risk_tiers.<tier>.require_review` | `agent_only.risk_tiers.<tier>.require_review` |
| `risk_tiers.<tier>.require_quorum_token` | `agent_only.risk_tiers.<tier>.require_quorum_token` |
| implicit medium/high rollback requirement | `agent_only.risk_tiers.<tier>.require_rollback_plan` |
| exceptions lease file path | `exceptions.state_file` |
| exception expiry enforcement | `exceptions.require_expires` + engine checks |
| broad write policy | `defaults.deny_unscoped_write` + reason `DDB008_*` |
| fail-closed exception on services | reason `DDB011_*` + exception checks |

## Behavioral Equivalence Notes

- `deny_unknown_tokens`, `deny_unscoped_bash`, and `deny_unscoped_write` remain
  hard requirements for active services/skills.
- Runtime command-scope checks in v1 shell guard map to `octon-policy enforce`
  with identical deny behavior.
- Existing exception leases remain valid if owner/reason/created/expires fields
  are present and unexpired.

## Strict Cutover

- Legacy parser fallback has been removed from validators and runtime entrypoints.
- Legacy kill-switch flag compatibility has been removed; scoped kill-switch records
  under `kill_switch.state_dir` are authoritative.
- Agent-only guardrails are always evaluated for service `enforce` requests.

## Cutover Criteria

1. `octon-policy doctor` passes for v2 policy and governance files.
2. `octon-policy preflight/enforce` parity tests pass against v1 wrappers.
3. Strict validation passes with no legacy fallback paths.
4. Runtime deny logs include reason codes and remediation hints.
