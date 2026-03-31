# Constitutional Kernel Alignment

## Problem

The charter manifest already describes the live model correctly:

- `release_state: pre-1.0`
- `change_profile: atomic`
- `atomic_mode: clean-break`
- `profile_selection_receipt_ref: .octon/instance/cognition/context/shared/migrations/2026-03-30-unified-execution-constitution-atomic-cutover/plan.md`

But several active constitutional family files still point `profile_selection_receipt_ref` at March 28 or March 29 phase receipts. That leaves two conflicting readings available to maintainers and tooling:

1. the charter says the live model was selected on March 30 as one atomic clean-break
2. some active family files look like the current live selector is still a phase receipt

That ambiguity is constitutionally unnecessary after a clean-break cutover.

## Target rule

For every **active** constitutional family:

- `profile_selection_receipt_ref` names the **current live model-selection receipt**
- earlier phase receipts move to an explicitly historical lineage field such as `activation_lineage_refs`
- no active family uses a stale phase receipt as the only obvious model-selection reference

## Affected files

- `/.octon/framework/constitution/contracts/objective/family.yml`
- `/.octon/framework/constitution/contracts/authority/family.yml`
- `/.octon/framework/constitution/contracts/runtime/family.yml`
- `/.octon/framework/constitution/contracts/assurance/family.yml`
- `/.octon/framework/constitution/contracts/retention/family.yml`

## Reference implementation already present at HEAD

`/.octon/framework/constitution/contracts/disclosure/family.yml` already points `profile_selection_receipt_ref` at the March 30 atomic cutover receipt.

That file should become the reference implementation for the rest of the active constitutional families.

## Required atomic edit pattern

### 1. Rebind the live selector

Replace the current phase receipt with:

```text
.octon/instance/cognition/context/shared/migrations/2026-03-30-unified-execution-constitution-atomic-cutover/plan.md
```

### 2. Preserve phase lineage explicitly

Add an explicit lineage field for historical phase activation, for example:

- `activation_lineage_refs`
- `phase_activation_receipts`
- or another validator-backed equivalent

The important point is **semantic separation**:

- one field says what is live now
- another field says how we got there historically

### 3. Preserve family-specific content

Only the receipt semantics change. Objective, authority, runtime, assurance, and retention family-specific payloads stay intact.

## Why clean-break requires this

A staged rollout can legitimately keep multiple live-state selectors in flight. A clean-break model cannot. Once the repo declares that the live model is one atomic cutover, every active family must either:

- agree on that selector, or
- explicitly say why it is not using the global selector

This packet assumes the former because the current repo state already behaves like the former.

## Validator contract

Add a fail-closed validator with these checks:

1. read `/.octon/framework/constitution/charter.yml#live_model.profile_selection_receipt_ref`
2. read every active `contracts/*/family.yml`
3. fail if:
   - `change_profile` is not `atomic` for an active family in the live model
   - `profile_selection_receipt_ref` differs from the charter live selector
   - a family points only at a phase receipt without explicit historical lineage semantics

## Expected end state

After promotion:

- every active family points at the March 30 atomic receipt as its live selector
- March 28–29 phase receipts remain visible only as historical lineage
- no reviewer or validator can mistake an old phase receipt for the current live model again
