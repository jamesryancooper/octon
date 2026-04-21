# ADR 099: Promotion Semantics Hardening

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json`
  - `/.octon/framework/engine/runtime/spec/promotion-activation-v1.md`
  - `/.octon/instance/governance/contracts/promotion-receipts.yml`
  - `/.octon/instance/governance/policies/promotion-semantics.yml`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-promotion-receipts.sh`

## Context

Octon already had strong receipt-backed publication semantics for several
generated/effective surfaces, but there was still no generalized architectural
rule preventing quiet promotion from `inputs/**` or `generated/**` into
authored authority, mutable control truth, or runtime-facing effective state.

## Decision

Require explicit promotion or publication receipts for class-boundary moves
from `inputs/**` or `generated/**` into canonical authority, control, or
runtime-facing effective surfaces.

Rules:

1. Quiet authority creation is forbidden.
2. Human-authored direct edits remain legal, but must retain authority basis,
   validator coverage, and rollback posture in adjacent evidence or decision
   surfaces.
3. Promotion receipts are validation-covered closure artifacts, not optional
   administrative metadata.

## Consequences

- Promotion semantics become explicit and auditable.
- The repo keeps `inputs/**` and `generated/**` non-authoritative by
  construction instead of convention only.
- Closure can distinguish supported promotion from accidental authority leaks.
