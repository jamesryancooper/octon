# Deny-by-Default Reason Codes (v2)

Stable deny reasons returned by validators, runtime wrappers, and the shared
policy engine.

## Contract

- Codes are stable identifiers and must not be repurposed.
- Message text can evolve, but `code` semantics must remain compatible.
- Remediation hints should be machine-actionable when possible.

## Codes

| Code | Meaning | Typical Remediation |
|---|---|---|
| `DDB001_POLICY_FILE_MISSING` | Required policy file does not exist. | Restore policy file path or regenerate from canonical template. |
| `DDB002_POLICY_INVALID` | Policy exists but fails schema/semantic validation. | Run `harmony-policy doctor` and fix reported fields. |
| `DDB003_UNKNOWN_TOOL_TOKEN` | `allowed-tools` includes unknown token. | Replace with approved token or scoped variant. |
| `DDB004_UNSCOPED_BASH` | Bare `Bash`/`Shell` used for active artifact. | Replace with `Bash(<scoped-command>)`. |
| `DDB005_UNSCOPED_WRITE` | Bare `Write` used for active artifact. | Replace with `Write(<scoped-path>)`. |
| `DDB006_BASH_SCOPE_MISSING` | Shell entrypoint has no `Bash(...)` scope. | Add at least one scoped command token. |
| `DDB007_BASH_SCOPE_DENIED` | Runtime invocation does not match declared bash scopes. | Narrow command or add minimal matching scope. |
| `DDB008_WRITE_SCOPE_BROAD` | Broad write scope (`**`) detected. | Narrow scope or obtain temporary exception lease. |
| `DDB009_EXCEPTION_MISSING` | Required exception/grant lease not found. | Create bounded lease with owner/reason/expiry. |
| `DDB010_EXCEPTION_EXPIRED` | Exception/grant lease is expired. | Renew or remove dependency on lease. |
| `DDB011_FAIL_CLOSED_FALSE_REQUIRES_EXCEPTION` | `fail_closed: false` without active lease. | Restore fail-closed or add temporary exception. |
| `DDB012_AGENT_ONLY_POLICY_DISABLED` | Agent-only policy is disabled in the active v2 policy. | Set `agent_only.enabled: true` in `deny-by-default.v2.yml`. |
| `DDB013_AGENT_ID_MISSING` | Required agent identity metadata missing. | Set `HARMONY_AGENT_ID` and provenance fields. |
| `DDB014_DISTINCT_AGENT_QUORUM_NOT_MET` | Distinct agent threshold not satisfied for risk tier. | Add distinct reviewer/agents according to tier policy. |
| `DDB015_REVIEW_AGENT_REQUIRED` | Tier requires review agent but none provided. | Set `HARMONY_REVIEW_AGENT_ID`. |
| `DDB016_REVIEWER_NOT_DISTINCT` | Reviewer matches actor where separation is required. | Use a distinct reviewer identity. |
| `DDB017_QUORUM_TOKEN_REQUIRED` | High-risk action missing quorum token. | Attach valid quorum artifact token. |
| `DDB018_ROLLBACK_PLAN_REQUIRED` | Medium/high tier action missing rollback plan id. | Provide `HARMONY_ROLLBACK_PLAN_ID`. |
| `DDB019_KILL_SWITCH_ACTIVE` | Scoped/global kill-switch currently active. | Clear or expire kill-switch record for requested scope. |
| `DDB020_GRANT_EXPIRED` | Grant exists but TTL has elapsed. | Renew or request new ephemeral grant. |
| `DDB021_GRANT_SCOPE_TOO_BROAD` | Requested grant scope exceeds policy constraints. | Request minimal path/command scope only. |
| `DDB022_GRANT_TIER_REVIEW_REQUIRED` | Medium/high grant requested without required review evidence. | Attach required review/quorum metadata or lower risk scope. |
| `DDB023_PROFILE_NOT_FOUND` | Requested profile id is unknown. | Use one of supported profiles or add profile definition. |
| `DDB024_REMEDIATION_ATTEMPTS_EXCEEDED` | Auto-remediation loop hit retry cap. | Stop, surface deny payload, and require explicit scope change. |
| `DDB025_RUNTIME_DECISION_ENGINE_ERROR` | Policy engine failed to evaluate deterministically. | Treat as deny; inspect diagnostics and fix engine/policy input. |

## Deny Payload Shape

```json
{
  "code": "DDB007_BASH_SCOPE_DENIED",
  "message": "Command invocation not permitted by declared Bash scopes",
  "scope": "service",
  "target": "agent",
  "missing_scope": "Bash(bash execution/agent/impl/agent.sh *)",
  "expected_token": "Bash(bash execution/agent/impl/agent.sh *)",
  "remediation_hint": "Add a minimal Bash scope covering this command or use a matching profile",
  "risk_tier": "low"
}
```
