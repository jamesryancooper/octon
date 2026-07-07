# Acceptance Criteria

- Proposal-program runs record a start baseline before recovery dispatch.
- Mutating routes declare route write leases with include and exclude path sets.
- Foreign/manual, protected, generated-only, and ambiguous paths block mutation.
- Isolated worktree gating is selected when current worktree ownership cannot be proven.
- Child-owned receipts remain outside parent route write authority.
- Negative controls prove a stale or missing lease fails closed.
