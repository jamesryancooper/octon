---
title: Waivers and Exceptions
description: Canonical taxonomy and required fields for governance waivers and deny-by-default exceptions.
status: Active
---

# Waivers and Exceptions

Use this document as the single source of truth for waiver/exception semantics.

## Type Semantics

- `exception`: capability or permission elevation under deny-by-default.
- `waiver`: temporary relaxation of a governance requirement while remaining
  receipt-linked and fail-closed by default.

Exceptions do not grant promotion authority. Waivers do not bypass non-waivable
controls.

## Required Fields

Both `exception` and `waiver` records require:

- `id`
- `owner`
- `reason_code`
- `scope`
- `target`
- `created`
- `expires`
- `evidence_refs`
- `receipt_required`
- `risk_tier`
- `acp`

## Principles Charter Override Records

Direct edits to
`/.octon/cognition/governance/principles/principles.md` under
`change_policy: human-override-only` require an append-only record in:

- `.octon/cognition/governance/exceptions/principles-charter-overrides.md`

Required override fields:

- `id` (`OVR-YYYY-MM-DD-NNN`)
- `date`
- `rationale`
- `responsible_owner`
- `review_date`
- `override_scope`
- `review_and_agreement_evidence`
- `exception_log_ref`
- `authorized_by`
- `authorization_source`
- `break_glass`
- `status`

## Enforcement Contract

- Policy contract source:
  `.octon/capabilities/governance/policy/deny-by-default.v2.yml#governance_overrides`
- Schema source:
  `.octon/capabilities/governance/policy/deny-by-default.v2.schema.json#/$defs/governanceOverrides`
- Governance lint source:
  `.octon/cognition/_ops/principles/scripts/lint-principles-governance.sh`

If a principle introduces waiver/exception behavior without referencing this
SSOT, governance lint must fail before merge.
