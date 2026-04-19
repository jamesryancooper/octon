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
| `DDB002_POLICY_INVALID` | Policy exists but fails schema/semantic validation. | Run `octon-policy doctor` and fix reported fields. |
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
| `DDB013_AGENT_ID_MISSING` | Required agent identity metadata missing. | Set `OCTON_AGENT_ID` and provenance fields. |
| `DDB014_DISTINCT_AGENT_QUORUM_NOT_MET` | Distinct agent threshold not satisfied for risk tier. | Add distinct reviewer/agents according to tier policy. |
| `DDB015_REVIEW_AGENT_REQUIRED` | Tier requires review agent but none provided. | Set `OCTON_REVIEW_AGENT_ID`. |
| `DDB016_REVIEWER_NOT_DISTINCT` | Reviewer matches actor where separation is required. | Use a distinct reviewer identity. |
| `DDB017_QUORUM_TOKEN_REQUIRED` | High-risk action missing quorum token. | Attach valid quorum artifact token. |
| `DDB018_ROLLBACK_PLAN_REQUIRED` | Medium/high tier action missing rollback plan id. | Provide `OCTON_ROLLBACK_PLAN_ID`. |
| `DDB019_KILL_SWITCH_ACTIVE` | Scoped/global kill-switch currently active. | Clear or expire kill-switch record for requested scope. |
| `DDB020_GRANT_EXPIRED` | Grant exists but TTL has elapsed. | Renew or request new ephemeral grant. |
| `DDB021_GRANT_SCOPE_TOO_BROAD` | Requested grant scope exceeds policy constraints. | Request minimal path/command scope only. |
| `DDB022_GRANT_TIER_REVIEW_REQUIRED` | Medium/high grant requested without required review evidence. | Attach required review/quorum metadata or lower risk scope. |
| `DDB023_PROFILE_NOT_FOUND` | Requested profile id is unknown. | Use one of supported profiles or add profile definition. |
| `DDB024_REMEDIATION_ATTEMPTS_EXCEEDED` | Auto-remediation loop hit retry cap. | Stop, surface deny payload, and require explicit scope change. |
| `DDB025_RUNTIME_DECISION_ENGINE_ERROR` | Policy engine failed to evaluate deterministically. | Treat as deny; inspect diagnostics and fix engine/policy input. |

## ACP / RA Codes

| Code | Meaning | Typical Remediation |
|---|---|---|
| `ACP_ALLOW_POLICY_PASS` | ACP decision passed with all required controls satisfied. | Preserve receipt and evidence artifacts; continue governed promotion flow. |
| `ACP_RULE_NO_MATCH` | No ACP rule matched the operation class/target/phase. | Add a policy rule for the operation class or normalize wrapper taxonomy. |
| `ACP_PROFILE_CEILING_EXCEEDED` | Active profile ACP ceiling is below required ACP. | Use a higher profile, or split action into lower-risk reversible operations. |
| `ACP_PROTECTED_TARGET` | Target is protected and requires elevated ACP requirements. | Provide required evidence and quorum, or route through staged promotion. |
| `ACP_PHASE_REQUIRED` | `operation.phase` was omitted for a mutating operation class. | Set explicit phase (`stage`, `promote`, `finalize`) before invoking ACP enforcement. |
| `ACP_PHASE_INVALID` | `operation.phase` had an unsupported value for ACP enforcement. | Use only supported phase values (`stage`, `promote`, `finalize`). |
| `ACP_IRREVERSIBLE_BLOCKED` | Irreversible primitive is blocked outside break-glass posture. | Use reversible primitive or enable audited, time-boxed break-glass posture. |
| `ACP_REVERSIBILITY_REQUIRED` | Required reversible primitive details were missing. | Provide `reversibility` metadata with approved primitive and rollback handle. |
| `ACP_ROLLBACK_HANDLE_MISSING` | Rollback handle required for promotion was absent. | Attach rollback handle (`git revert`, restore manifest, deployment rollback id). |
| `ACP_ROLLBACK_PROOF_MISSING` | Rollback proof required (ACP-2+) but missing. | Run rollback validation in staging and attach proof evidence. |
| `ACP_RECOVERY_WINDOW_MISSING` | Recovery TTL/window required for destructive-adjacent action. | Set `recovery_window` (or rely on policy default when allowed). |
| `ACP_EVIDENCE_MISSING` | Required evidence bundle entries are missing. | Attach required evidence refs + hashes (diff/tests/plan/etc.). |
| `ACP_DOCS_EVIDENCE_MISSING` | Required docs-gate evidence (`docs.spec`, `docs.adr`, `docs.runbook`) is missing for promote evaluation. | Attach docs evidence refs/hashes or keep action staged. |
| `ACP_MATERIAL_SIDE_EFFECT_INVALID` | Materiality trigger fields are invalid or conflicting. | Normalize aliases to canonical `material_side_effect` with boolean-compatible values. |
| `ACP_TELEMETRY_PROFILE_MISSING` | ACP telemetry profile is required for this promote action but was missing. | Provide `telemetry_profile` (`minimal`/`sampled`/`full`) per ACP mapping. |
| `ACP_TELEMETRY_PROFILE_INVALID` | Receipt/request telemetry profile does not match ACP-allowed values. | Use an allowed telemetry profile for the effective ACP level. |
| `ACP_FLAG_METADATA_EVIDENCE_MISSING` | Flag-changing promotion is missing `flags.metadata` evidence. | Attach validated flag metadata evidence before promote. |
| `ACP_FLAG_METADATA_INVALID` | Flag metadata validity marker is missing/false for flag-changing promotion. | Run flag metadata validator and set `flag_metadata_valid=true` only on pass. |
| `ACP_EVIDENCE_INVALID` | Evidence present but malformed or hash mismatch. | Regenerate evidence artifact and ensure canonical hash binding. |
| `ACP_ATTESTATION_FIELD_MISSING` | One or more required attestation fields were absent/blank. | Include all policy-required attestation fields before retrying quorum checks. |
| `ACP_ATTESTATION_INVALID` | Attestation payload format was invalid (unsupported required field, invalid timestamp, or malformed record). | Regenerate attestations with schema-compliant field values. |
| `ACP_ATTESTATION_ROLE_MISMATCH` | Attestation roles did not satisfy required role constraints. | Supply attestations from required roles (`proposer`, `verifier`, `recovery`) as policy requires. |
| `ACP_QUORUM_MISSING` | Required quorum roles/signatures were missing. | Gather required attestations and resubmit gate request. |
| `ACP_QUORUM_INVALID` | Attestations do not bind to shared plan/evidence hashes. | Re-issue attestations for the same plan/evidence identity. |
| `ACP_OWNER_ATTESTATION_MISSING` | Boundary owner attestation was required by policy but not present. | Source owner signal from CODEOWNERS/registry/manifest and retry within policy window. |
| `ACP_OWNER_ATTESTATION_TIMEOUT` | Owner attestation retry/time window was exhausted. | Escalate per policy and keep operation staged until owner signal is resolved. |
| `ACP_BUDGET_SET_MISSING` | Required budget set is missing or unknown. | Fix budget set reference in policy or request payload. |
| `ACP_BUDGET_EXCEEDED` | Runtime counters exceeded configured budget thresholds. | Reduce scope, split into smaller promotions, or request temporary exception. |
| `ACP_CIRCUIT_BREAKER_TRIPPED` | Circuit breaker trigger fired for this operation. | Investigate trigger, rollback when possible, and rerun after remediation. |
| `ACP_CIRCUIT_BREAKER_INVALID_ACTION` | Circuit breaker configuration referenced unsupported action token(s). | Correct action tokens in policy/schema and rerun policy doctor/enforcement. |
| `ACP_KILLSWITCH_ACTIVE` | Kill-switch blocks ACP promotion/finalization. | Clear or expire kill-switch only after safety checks. |
| `ACP_RECEIPT_REQUIRED` | Receipt emission required for this decision but missing. | Fix receipt writer/config and retry promotion gate. |
| `ACP_RECEIPT_INVALID` | Receipt exists but missing required fields/hash consistency. | Regenerate receipt with required fields and bound hashes. |
| `ACP_STAGE_ONLY_REQUIRED` | Requirements not satisfied; operation may continue only as stage. | Gather missing requirements then re-run promote phase. |
| `ACP_ESCALATE_POLICY` | Policy requires escalation for unresolved high-risk conditions. | Escalate with digest/receipt and keep artifacts staged. |
| `RA_BREAK_GLASS_REQUIRED` | ACP-4 request attempted without break-glass posture. | Convert to reversible path or use explicit emergency break-glass mode. |

## Intent-Layer Codes

| Code | Meaning | Typical Remediation |
|---|---|---|
| `INTENT_MISSING` | Autonomous request omitted required `intent_ref`. | Bind run to a valid intent contract id/version before policy enforcement. |
| `INTENT_REF_INVALID` | Referenced intent contract is invalid, unknown, or incompatible. | Use an existing approved intent contract version and rerun. |
| `BOUNDARY_UNRESOLVED` | Boundary route could not be resolved for decision class/context. | Provide boundary id/set version and decision class fields. |
| `BOUNDARY_BLOCKED` | Decision matched a boundary route of `block`. | Redesign the action or obtain explicit governance exception. |
| `BOUNDARY_ESCALATION_REQUIRED` | Decision matched a boundary route of `escalate`. | Escalate to owner/policy authority and wait for approval signal. |
| `MODE_VIOLATION_AUTONOMY_NOT_ALLOWED` | Autonomous execution attempted for non-`execution-role-ready` workflow classification. | Re-run in `role-mediated` or `human-only` mode, or reclassify workflow through governance process. |

## Authority Engine Codes

| Code | Meaning | Typical Remediation |
|---|---|---|
| `OWNERSHIP_UNRESOLVED` | No canonical owner could be resolved for the requested execution scope. | Publish or tighten ownership registry entries before retrying material execution. |
| `SUPPORT_TIER_UNSUPPORTED` | The requested support tier is not declared or not supported for this route. | Use a declared support tier or publish the required support-target declaration. |
| `SUPPORT_TIER_ROUTE_BLOCKED` | The support-tier declaration routed this execution away from `ALLOW`. | Keep the work staged/escalated or widen the declaration through governance. |
| `AUTHORITY_GRANT_REVOKED` | A canonical revocation blocks the current approval grant or request. | Clear the revocation through the canonical revocation surface or request a new grant. |

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
