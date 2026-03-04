---
title: Principles Charter Overrides
description: Append-only ledger for explicit human-authorized direct edits to the principles charter.
status: Active
---

# Principles Charter Overrides

Use this append-only ledger to record every direct edit to
`/.harmony/cognition/governance/principles/principles.md` made under explicit
human override.

## Record Format (Required Fields)

Every record must include:

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
- `break_glass` (`true` or `false`)
- `status` (`active`, `closed`, or `retired`)

## Records (Append-Only)

### OVR-2026-02-24-001

- date: 2026-02-24
- rationale: Align principles governance to human-override-controlled direct edits and retire successor-file sprawl.
- responsible_owner: "@you"
- review_date: 2026-05-31
- override_scope: Charter change-control framing, discovery-surface alignment, and successor retirement.
- review_and_agreement_evidence: Explicit human override instructions in Codex session on 2026-02-24.
- exception_log_ref: ADR-042 (`/.harmony/cognition/runtime/decisions/042-principles-charter-human-override-direct-edit-policy.md`)
- authorized_by: repository policy author
- authorization_source: explicit human override request in active session
- break_glass: false
- status: active

### OVR-2026-03-04-001

- date: 2026-03-04
- rationale: Explicitly encode Convivial constraints in the authoritative charter and bind them to enforceable governance controls.
- responsible_owner: "@you"
- review_date: 2026-06-30
- override_scope: Direct charter clarification adding normative Convivial constraints language and canonical control references.
- review_and_agreement_evidence: Explicit human override instruction in Codex session on 2026-03-04 ("I am giving you human-override change control to explicitly call out Convivial constraints.").
- exception_log_ref: OVR-2026-03-04-001 (this append-only record), authorized under ADR-042 (`/.harmony/cognition/runtime/decisions/042-principles-charter-human-override-direct-edit-policy.md`)
- authorized_by: repository policy author
- authorization_source: explicit human override request in active session
- break_glass: false
- status: active
