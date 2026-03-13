---
title: RA/ACP Glossary
description: Canonical terminology for reversible autonomy governance across principles and policy.
status: Active
---

# RA/ACP Glossary

Use these terms consistently across principles, policy, receipts, and validators.

## Durable State Verbs

- `stage`: apply changes to a reversible, non-durable surface (branch, overlay, canary, tombstone layer).
- `promote`: commit staged changes to durable state after ACP gate evaluation.
- `apply`: interpreted as `promote` for durable state unless explicitly marked read-only or stage-only.
- `finalize`: irreversible completion step (for example hard-delete after recovery window); ACP-4 by default.
- `contraction`: glossary alias of `finalize` for durable-state cleanup semantics; it does not introduce a separate gate outcome.

## Governance Actors and Decisions

- `approval`: human authorization decision. Not a default runtime dependency in RA/ACP.
- `attestation`: signed machine-verifiable assertion bound to plan/evidence hashes.
- `quorum`: minimum attestation set required by policy for ACP-2+ operations.
- `owner attestation`: owner-role attestation sourced from machine-attestable ownership metadata; quorum input only.
- `exception`: capability/permission elevation under deny-by-default.
- `waiver`: governance requirement relaxation (for example threshold override) that remains time-boxed and receipt-linked.

## Risk and Control Levels

- `risk tier`: policy-level risk classification (`low`, `medium`, `high`) used for capability and ACP defaults.
- `ACP level`: promotion-control level (`ACP-0`..`ACP-4`) with escalating requirements.
- canonical mapping source: `.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.risk_tier_mapping`.

## Evidence and Audit Terms

- `receipt`: append-only decision artifact containing ACP outcome, evidence refs, reasons, and rollback handles.
- `evidence bundle`: required artifacts for promotion (policy + matrix driven).
- `PR projection`: optional presentation of receipt evidence in PR context; never the canonical source.
- `material_side_effect`: canonical governance trigger predicate for evidence, telemetry, and receipt enforcement.
- aliases of `material_side_effect`: `material side-effect`, `meaningful behavior change`, `durable effect`, `promotion` (when used as governance trigger).
- `telemetry_profile`: policy-evaluated profile class recorded in receipts (`minimal`, `sampled`, `full`), enforced by ACP level mapping.
