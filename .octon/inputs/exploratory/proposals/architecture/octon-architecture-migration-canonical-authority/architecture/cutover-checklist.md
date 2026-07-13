# Cutover Checklist

- [ ] RP-00 containment and inventories pass.
- [ ] The accepted ROD-003 epoch-zero inventory, one-time human trust anchor,
      and exact activation-preauthorization boundary are bound.
- [ ] The versioned semantic interface and all identities are frozen.
- [ ] Every launch call site is behind the exact guard.
- [ ] UE-001 and UE-002 adversarial evidence passes on the implementation commit.
- [ ] Legacy authority writers and launch bypasses are disabled, not shadowed.
- [ ] SI-01 and rollback rehearsal pass before RP-03 starts persistence mutation.
- [ ] Promotion and implementation receipts reference exact artifacts and commit.

An unchecked item blocks cutover; it is not waivable by parent prose.
