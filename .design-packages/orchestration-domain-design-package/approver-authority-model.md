# Approver Authority Model

## Purpose

Define how the system determines whether an approval artifact is issued by an
authorized approver with valid scope.

This document is normative for approver-authority verification.

## Canonical Registry

Canonical governance-owned artifact:

```text
orchestration/governance/approver-authority-registry.json
```

## Registry Fields

Each approver entry MUST declare:

| Field | Required | Notes |
|---|---|---|
| `approver_id` | yes | canonical stable id |
| `role` | yes | governance role name |
| `approved_scopes[]` | yes | scope entries defined below |
| `issued_at` | yes | ISO timestamp |
| `expires_at` | yes | ISO timestamp |
| `revoked` | yes | boolean |

### Scope Entry

Each `approved_scopes[]` entry MUST declare:

- `action_class`
- `surfaces[]`
- optional `workflow_groups[]`
- optional `coordination_key_globs[]`

## Approval Verification Algorithm

When verifying an approval artifact:

1. locate `approved_by` in the approver authority registry
2. reject if the entry is missing
3. reject if the entry is expired or `revoked=true`
4. compare the approval artifact scope to the registry scopes:
   - `action_class` must match
   - target surface must be included
   - if `workflow_group` is present in the approval scope, it must be allowed
   - if `coordination_key` is present in the approval scope, it must match one
     of the allowed globs
5. only then treat the approval artifact as valid

## Authority Sufficiency Rule

If multiple scopes could match, the narrowest matching scope wins. Broader
authority must not be inferred from a partial match.

## Expiry Rules

- approval verification fails if either the approval artifact or approver
  registry entry is expired
- revoked approvers are invalid immediately

## Invariants

- No privileged action is valid without both a valid approval artifact and a
  valid approver authority entry.
- Revocation always wins over otherwise valid scope.
