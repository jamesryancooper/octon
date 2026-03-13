---
title: RA/ACP Promotion Inputs Matrix
description: Canonical promotion-input requirements by ACP level for reversible autonomy.
status: Active
---

# RA/ACP Promotion Inputs Matrix

Canonical source for ACP promotion input minimums.  
Policy source of truth: `.octon/capabilities/governance/policy/deny-by-default.v2.yml` (`acp`, `reversibility`, `budgets`, `quorum`, `attestations`, `receipts`).
Terminology source: [RA/ACP Glossary](./ra-acp-glossary.md).

## Enforcement Boundary

- Capability attempt authority: `Deny by Default`.
- Promotion/contraction authority: `Autonomous Control Points`.
- Receipt fields are canonical; PR artifacts are optional projections when PR context exists.

## Risk Tier Mapping (Canonical)

Risk tier to ACP mapping is defined only in policy:  
`.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.risk_tier_mapping`

| Risk tier | ACP level |
|---|---|
| low | ACP-1 |
| medium | ACP-2 |
| high | ACP-3 |

## Promotion Input Minimums by ACP Level

| ACP | Minimum evidence bundle | Reversibility minimum | Quorum minimum | Budgets / breakers | Receipt minimum fields | Optional projection |
|---|---|---|---|---|---|---|
| ACP-0 | n/a (observe/read-only) | n/a | n/a | n/a | no promotion receipt required | PR note if present |
| ACP-1 | `diff`, docs-gate evidence: `docs.spec`, `docs.adr`, `docs.runbook` | reversible primitive + rollback handle | none | required budget set + circuit breaker set | `run_id`, `operation`, `phase`, `effective_acp`, `decision`, `reason_codes`, `evidence`, `rollback_handle`, `budgets`, `counters` | PR may reference `receipt_id` + summary |
| ACP-2 | ACP-1 + class-specific tests/CI/canary/plan as policy requires | ACP-1 + rollback proof where rule requires | `quorum.acp2` + required attestation fields | required budget set + circuit breaker set | ACP-1 fields + `attestations` + `recovery_window` | PR may embed trace links and receipt digest |
| ACP-3 | ACP-2 + destructive-adjacent evidence as policy requires | ACP-2 + recovery window | `quorum.acp3` | stricter budgets + destructive breakers | ACP-2 fields, fully populated for recovery | PR may reference staged/final receipts |
| ACP-4 | break-glass only; out-of-band | irreversible by exception only | policy-specific | policy-specific | audited denial/escalation and break-glass receipt path | no routine PR projection |

## Material Side-Effect Predicate (Canonical)

Promotion-time governance checks in this matrix are keyed by canonical predicate
`material_side_effect`.

- Canonical predicate name: `material_side_effect`
- Canonical aliases: `material side-effect`, `meaningful behavior change`,
  `durable effect`, `promotion` (when used as governance trigger)
- Policy source: `.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.materiality`

## Telemetry Profile Gate (Canonical)

Telemetry profile enforcement is policy-driven and evaluated at ACP promote gate:
`.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.telemetry_gate`

| ACP | Required telemetry profile(s) | Additional evidence requirement | Receipt fields |
|---|---|---|---|
| ACP-0 | n/a | n/a | n/a |
| ACP-1 | `minimal`, `sampled`, or `full` | representative `trace_id` in evidence bundle | `telemetry_profile`, `reason_codes` |
| ACP-2 | `full` | representative `trace_id` + decision identity evidence | `telemetry_profile`, `reason_codes` |
| ACP-3 | `full` | ACP-2 + rollback/recovery telemetry signals | `telemetry_profile`, `reason_codes` |
| ACP-4 | policy-defined break-glass profile | policy-defined | break-glass audited receipt fields |

Failure behavior is fail-closed with reason codes:
`ACP_TELEMETRY_PROFILE_MISSING` or `ACP_TELEMETRY_PROFILE_INVALID`.

## Flag Metadata Gate (Canonical)

When operation target signals flag changes, ACP promotion requires
`flags.metadata` evidence and a valid metadata contract result.
Policy source:
`.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.flag_metadata_gate`.

Failure behavior is fail-closed with reason codes:
`ACP_FLAG_METADATA_EVIDENCE_MISSING` or `ACP_FLAG_METADATA_INVALID`.

## Docs-Gate Outcomes (Canonical)

Docs-gate is enforced at ACP evaluator runtime via policy:

- Missing `docs.spec` / `docs.adr` / `docs.runbook` adds reason code `ACP_DOCS_EVIDENCE_MISSING`.
- Outcome by ACP level is policy-defined at `acp.docs_gate.missing_action_by_acp`.

## Owner Attestation Outcomes (Canonical)

Owner attestation behavior is policy-defined at `attestations.owner_attestation`.

- Sources: `codeowners`, `ownership_registry`, `boundaries_manifest`.
- Missing required owner attestation: bounded `STAGE_ONLY` with reason code.
- Exhausted retry/timeout window: optional `ESCALATE` when configured.

## Waivers and Exceptions (Canonical)

Waiver/exception taxonomy is canonical at:
- Principles SSOT: [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md)
- Policy contract: `.octon/capabilities/governance/policy/deny-by-default.v2.yml#governance_overrides`

## Provenance Schema Pointer

Required receipt/provenance fields for promote decisions:  
`.octon/capabilities/governance/policy/acp-provenance-fields.schema.json`
