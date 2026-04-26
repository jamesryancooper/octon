# Cutover Checklist

## Before promotion

- [ ] Proposal packet validates under proposal-standard rules.
- [ ] Architecture proposal validates under architecture subtype rules.
- [ ] Current support truth inventory is captured.
- [ ] Current material side-effect inventory is captured.
- [ ] Current run-health source inventory is captured.
- [ ] No generated, input, archive, or proposal surface is listed as authority.
- [ ] Promotion targets are outside the proposal tree.
- [ ] Rollback owner and rollback commit are identified.

## Phase 1 checks

- [ ] Reconciliation schema promoted.
- [ ] Reconciliation generator promoted.
- [ ] Reconciliation validator promoted.
- [ ] Positive and negative reconciliation fixtures promoted.
- [ ] Generated reconciliation output produced.
- [ ] Mismatched support states fail deterministically.

## Phase 2 checks

- [ ] Full token metadata implemented.
- [ ] `VerifiedEffect<T>` implemented.
- [ ] Material APIs require verified effects.
- [ ] Token consumption receipts emitted.
- [ ] Revocation/expiry/scope/route/run/tuple checks enforced.
- [ ] Positive token tests pass.
- [ ] Negative bypass tests fail for expected reasons.

## Phase 3 checks

- [ ] Run-health schema promoted.
- [ ] Run-health generator promoted.
- [ ] Run-health validator promoted.
- [ ] Health fixtures cover all required statuses.
- [ ] Generated health includes source refs and non-authority marker.
- [ ] Generated health cannot authorize anything.

## Closure checks

- [ ] Architecture conformance passes.
- [ ] Runtime-effective-state validation passes.
- [ ] Evidence completeness passes.
- [ ] No-generated-authority validation passes.
- [ ] No-input-authority validation passes.
- [ ] Closure certification retained.
- [ ] Final disclosure states admitted support envelope accurately.
